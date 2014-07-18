# Phantom decorators
{ Deferred } = require 'promise.coffee'
Phantom = require 'phantom'
fs = require 'fs'
pathUtil = require 'path'
relpath = (path) ->
  pathUtil.resolve(__dirname, path)

module.exports =
  errorExit: (type) ->
    (error) =>
      console.error "#{type} onError", error
      # page errors may not be our fault
      if type is 'phantom'
        @ph.exit(1)
        @ph = null
  # Create phantom and page
  createPhantom: (options) ->
    @then =>
      def = new Deferred
      Phantom.create options, (@ph) =>
        ph.set 'onError', @errorExit('phantom')
        @ph.createPage (@page) =>
          page.set 'onError', @errorExit('page')
          def.resolve()
      def.promise
  # Exit phantom
  exitPhantom: ->
    @then =>
      @ph.exit()
  open: (url) ->
    @then (value) =>
      url ?= value
      def = new Deferred
      @page.set 'onLoadFinished', (success) =>
        # Inject fake jquery
        fs.readFile relpath('../scripts/_j.min.js'), 'utf8', (err, code) =>
          # Getters and setters for client side (So we don't have to send entire elems over comm)
          fn = """
          function () {
            window._g = {}
            window._s = function (data) {var key = Date.now(); _g[key] = data; return key}
            #{code}
          }
          """
          @page.evaluate fn, =>
            @onLoadFinished?.forEach (fn) =>
              fn.apply(@, [success])
      @page.open url, (status) =>
        def.resolve(status)
      def.promise
  injectJS: (path) ->
    @read path
    .alter (code) ->
      "function(){#{code}}"
  # .evaluate() evaluate String function or Function specified by originalValue
  # .evaluate(Function fn) evaluate String fn or Function fn
  # .evaluate(Function fn, args..) evaluate String fn or Function fn with following args
  # Resolves to return value of fn after running through page
  # Note that the originalValue is always appended to the arguments array
  evaluate: (fn) ->
    args = [].slice.call(arguments)
    @then (value) =>
      def = new Deferred
      args.push value
      args = [args[0], ((result) =>
          def.resolve result
        )].concat args.slice(1)
      @page.evaluate.apply @page, args
      def.promise
  # .render() render an image of the current page to the path specified by originalValue
  # .render(String path) render an image of the current page to the path specified
  # Resolves to originalValue
  render: (path) ->
    @then (value) =>
      path ?= value
      def = new Deferred
      @page.render path, (result) =>
        def.resolve(value)
      def.promise
  # .run(Function fn) allows you to manipulate the original value and page asynchronously with a node style function
  # Resolves to return from fn(page, originalValue, callback)
  # callback(err, value)
  run: (fn) ->
    if typeof fn isnt "function"
      throw TypeError(".run(Function fn) requires a function parameter")
    @then (value) =>
      def = new Deferred
      fn @page, value, (err, res) ->
        if err?
          def.reject(err)
        else
          def.resolve(res)
      def.promise
    .evaluate()    
  # .wait(Function fn) wait until page evaluates !!fn(originalValue) as true
  # Resolves to return value of fn
  wait: (fn) ->
    args = [].slice.call(arguments)
    if fn?
      if typeof fn is 'function'
        @then (value) =>
          def = new Deferred
          inc = 0
          fn = fn.toString()
          page = @page
          doEvaluate = ->
            page.evaluate.apply page, args
          args.push value
          args = [args[0], ((val) ->
              if val
                def.resolve(val)
              else
                if inc > 10
                  def.reject("Could not wait any longer")
                else
                  inc++
                  setTimeout(doEvaluate, 500)
            )].concat args.slice(1)
          doEvaluate()
          def.promise
      else if typeof fn is "string"
        @wait ((sel)->_j?(sel).length), fn
      else if typeof fn is "number"
        @then (value) ->
          def = new Deferred
          setTimeout (-> def.resolve(value)), fn
          def.promise
    else
      # Create onLoadFinished first to ensure it gets called
      def = null
      @onLoadFinished?=[]
      @onLoadFinished.push (status) =>
        if def?
          def.resolve(status)
          def = null
      @then =>
        def = new Deferred
        # Create a timeOut just in case the document is already loaded
        setTimeout ( =>
          @page.evaluate (->document?.title), (title)->
            if title? and def?
              console.log "Page already loaded, unnecessary wait()"
              def.resolve(title)
              def = null
        ), 500
        def.promise
  select: (sel) ->
    if sel?
      @evaluate ((sel, value)->_s _j(sel.replace('%s',value))), sel
    else
      @evaluate ((sel)->_s _j(sel))#, sel
  # .jquery(Function fn) passes fn($el) for modifying browser code
  # Resolves to return value of fn
  # Note this MUST follow a selector type of function
  jquery: (fn) ->
    fn = fn.toString()
    @evaluate ((fn, selId)->
      # give a name to the anonymouse function so that we can call it
      fn = fn.replace /function.*\(/, 'function x('
      # the only way we can access the request object is by passing a function to this point as a string and expanding it
      eval(fn) # :(
      # this function has access to request.abort()
      x.apply this, [_j _g[selId]]
    ), fn#, selId
  logInfo: (sel) ->
    if sel?
      @then (value) =>
        def = new Deferred
        @page.evaluate ((sel)->
          j = _j(sel)
          {count: j.length, selector: j.selector}
        ),((info) ->
          console.log info
          def.resolve(value)
        ), sel
        def.promise
    else
      @then (selId) =>
        def = new Deferred
        @page.evaluate ((selId)->
          j = _g[selId]
          {count: j.length, selector: j.selector}
        ),((info) ->
          console.log info
          def.resolve(selId)
        ), selId
        def.promise
  click: (sel) ->
    if sel?
      @evaluate ((sel, value)-> _s _j(sel.replace('%s',value)).click()), sel
    else
      @evaluate ((selId)->_g[selId].click(); selId)
  trigger: (event, sel) ->
    if sel?
      @evaluate ((event, sel)->_s _j(sel).trigger(event)), event, sel
    else
      @evaluate ((event, selId)->_g[selId].trigger(event); selId), event#, selId
  type: (text, sel) ->
    # A fake keyup event, not too sophisticated
    keyup = {
      which: 39, keyCode: 39,
      keyIdentifier: "Right",
      keyLocation: 0, location: 0,
      layerX: 0, layerY: 0,
      pageX: 0, pageY: 0,
      metaKey: false,
      altKey: false,
      ctrlKey: false
    }
    if text? and sel?
      @evaluate ((keyup, sel, text)->_s _j(sel).val(text).trigger("input").trigger _j.Event "keyup", keyup), keyup, sel, text
    if not text? and sel?
      @evaluate ((keyup, sel, text)->_s _j(sel).val(text).trigger("input").trigger _j.Event "keyup", keyup), keyup, sel#, text
    if text? and not sel?
      @evaluate ((keyup, text, selId)->_g[selId].val(text).trigger("input").trigger _j.Event "keyup", keyup; selId), keyup, text#, selId
    else
      throw Error(".type(String sel, String text) must have either sel or text or both")
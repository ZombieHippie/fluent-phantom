# Phantom decorators
Phantom = require 'phantom'; fs = require 'fs'; { Deferred } = require 'promise.coffee'
module.exports =
  # Create phantom and page
  createPhantom: (options) ->
    @then =>
      def = new Deferred
      Phantom.create options, (@ph) =>
        @ph.createPage (@page) =>
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
      @page.open url, (status) =>
        # Inject fake jquery
        fs.readFile '_j.min.js', 'utf8', (err, code) =>
          if err
            def.reject err
          else
            @page.evaluate "function(){#{code}}", ->
              def.resolve(status)
      def.promise
  injectJS: (path) ->
    @read path
    .alter (code) ->
      "function(){#{code}}"
    .evaluate()
  select: (sel) ->
    @then ->
      sel
  click: (sel) ->
    @evaluate ((sel)->_j(sel).click().length)#, sel
  trigger: (event, sel) ->
    @evaluate ((event, sel)->_j(sel).trigger(event).length), event#, sel
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
  render: (path) ->
    @then (value) =>
      path ?= value
      def = new Deferred
      @page.render path, (result) =>
        def.resolve()
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
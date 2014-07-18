# Fluent Test

Fluent = require './fluent'

start = Date.now()

Fluent(dnodeOpts:weak:false)
.log ->
  "Time to start: #{Date.now() - start}ms"

.startTimer('Program Start')
.open('https://google.com')
.getTimer('Program Start')
.log("Time to open webpage: %sms")

.startTimer 'Query with fake jquery'
.select "[name=q]"
.trigger "click"
.log '"[name=q]" matched %s elements'
.stopTimer 'Query with fake jquery'
.log 'Time Query with fake jquery %sms'

.startTimer 'Render webpage'
.render "google.png"
.stopTimer 'Render webpage'
.log 'Time Render webpage %sms'

.stopTimer('Program Start')
.log('Test duration: %sms')
.log ->
  "Total time: #{Date.now() - start}ms"
.exitPhantom()
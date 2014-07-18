# Fluent Test

Fluent = require './fluent'

start = Date.now()

Fluent(dnodeOpts:weak:false)
.log ->
  "Time to start: #{Date.now() - start}ms"

.startTimer 'Program Start'
.open 'https://google.com'

# Wait for jquery script to log
.wait()
.logTimer 'Program Start', 'Time to open google.com:'

.startTimer 'Search'
.select "[name=q]"

# Type something into the search box, q for query
.type "Cheap bananas"
.select '[value*="Search"], :contains("Search")'

# Print out some information about our current jquery selection
.logInfo()
.render "google-0.png"
.click()

# Wait til we see some 3rd headers
.wait 'h3'

# Render our first page of results
.render "google-1.png"

# Create random number to use to picke the link
.alter ->
  Math.floor Math.random() * 12

.select 'li:nth-child(%s) h3>a'
.jquery ($el) ->
  window.location.href = $el[0].href
  $el.text()
.log("Randomly clicked on %s")

# Wait for the click req and redirection req
.wait()
.wait()

# Wait extra time to load page content
.wait(1000)
.render "google-2-result.png"

.logTimer 'Search', 'Time to search google.com'
.stopTimer 'Search'

.logTimer 'Program Start', 'Execution time'
.stopTimer 'Program Start'
.log ->
  "Total time: #{Date.now() - start}ms"
.exitPhantom()
.else (error) ->
  console.error "Error running test.coffee", error
  process.exit(1)

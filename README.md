# Scraping DSL
A fluent interface for scraping web content in Node with the PhantomJS headless browser.  Its most notable feature is that, similar to waitFor.js, you can wait until the availability of content on a page, which comes in handy when scraping content generated by AJAX requests.

## Installation
Install via npm with:
```
npm install scraping-dsl
```

Note that this package depends on the [PhantomJS bridge for Node](https://github.com/sgentle/phantomjs-node), which assumes that you have already installed [PhantomJS](http://phantomjs.org/).

## Usage
The module should be easy to use (that was the point of writing it).  Just include it and describe your scraping actions.  Most examples are in CoffeeScript, but you get the point.

### Setup
Include the module with require and create a new request with the ```create()``` method.
```coffeescript
Request = require 'scraping-dsl'
req = Request.create()
```

```javascript
var Request = require('scraping-dsl'),
	req = Request.create()
```

### Extracting content
```coffeescript
Request.create()
.extract -> document.querySelectorAll('h2.post-title')
.and()
.handle (results) ->
	for result in results
		console.log result.innerText
.open 'http://techcrunch.com'
```



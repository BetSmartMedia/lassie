#
# Check: RESTful Web Service
#
# Roughly the same as the 'web' check, except this one supports additional
# request headers (for API keys, etc) and doesn't care about fragments in
# the response, only the status code. A non-200 status code will be considered
# a failed service.
#

http  = require 'http'
https = require 'https'
urlp  = require 'url'

# the setTimeout arg order really bugs me
timer = (ms, cb) -> setTimeout cb, ms

exports.run = (params, cb) ->
	url = urlp.parse(params.url)
	opts = {
		host:   url.hostname
		path:   url.path
		port:   url.port
		method: 'GET'
		headers: {}
	}
	if opts.port is null
		opts.port = if url.protocol is 'https:' then 443 else 80

	for k, v of params.headers
		opts.headers[k] = v

	request = if url.protocol is 'https:' then https.request else http.request
	req = request opts, (res) ->
		body = ""
		res.on 'data', (chunk) -> body += chunk
		res.on 'end', () ->
			if res.statusCode == 200
				cb true
			else
				cb false

	req.setTimeout 20000, ->
		req.abort()
		cb false
	req.on 'error', (e) -> cb false
	req.end()

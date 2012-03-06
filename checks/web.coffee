#
# Check: Web
#

http  = require 'http'
https = require 'https'
urlp  = require 'url'

# the setTimeout arg order really bugs me
timer = (ms, cb) -> setTimeout cb, ms

exports.run = (params, cb) ->
	url = urlp.parse(params.url)
	opts = {
		host:   url.host
		path:   url.path
		port:   if url.protocol is 'https:' then 443 else 80
		method: 'GET'
	}
	request = if url.protocol is 'https:' then https.request else http.request
	req = request opts, (res) ->
		body = ""
		res.on 'data', (chunk) -> body += chunk
		res.on 'end', () ->
			if body.indexOf(params.fragment) > -1
				cb true
			else
				cb false

	req.on 'error', (e) -> cb false
	req.end()

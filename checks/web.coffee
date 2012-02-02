#
# Check: Web
#

http  = require 'http'
https = require 'https'
urlp  = require 'url'

exports.run = (params, cb) ->
	url = urlp.parse(params.url)
	opts = {
		host: url.host
		path: url.path
		port: if url.protocol is 'https:' then 443 else 80
	}
	get = if url.protocol is 'https:' then https.get else http.get
	req = get opts, (res) ->
		body = ""
		res.on 'data', (chunk) -> body += chunk
		res.on 'end', () ->
			if body.indexOf(params.fragment) > -1
				cb true
			else
				cb false
	req.on 'error', (e) -> cb false

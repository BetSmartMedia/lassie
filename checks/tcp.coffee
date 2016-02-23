#
# Check: tcp
#

net = require 'net'

exports.run = (params, cb) ->
	client = net.connect params.port, params.host, ->
		body = ""

		client.on 'data', (chunk) ->
			body += chunk.toString()

		client.on 'close', () ->
			if body.indexOf(params.fragment) > -1
				cb true
			else
				cb false

	client.setTimeout 5000, ->
		client.destroy()
		cb false

	client.on 'error', (e) -> cb false
	client.end()

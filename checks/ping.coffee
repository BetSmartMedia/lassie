#
# Check: Ping
#

cproc = require 'child_process'

exports.run = (params, cb) ->
	ping = cproc.spawn 'ping', ['-c', '1', params.host]
	ping.on 'exit', (code) ->
		# if a failure then try a second attempt - this mitigates random ping loss
		if code == 0
			cb true
		else
			f = ->
				ping = cproc.spawn 'ping', ['-c', '1', params.host]
				ping.on 'exit', (code) ->
					cb !code
			setTimeout f, 500

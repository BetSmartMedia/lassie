#
# Check: Ping
#

cproc = require 'child_process'

exports.run = (params, cb) ->
	ping = cproc.spawn 'ping', ['-c', '1', params.host]
	ping.on 'exit', (code) ->
		cb !code

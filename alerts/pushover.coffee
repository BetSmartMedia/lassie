#
# Alert: Pushover
#

Pushover = require('node-pushover')

push = null

exports.init = (config) ->
	push = new Pushover(token: config.options.pushover.token)

exports.run = (checks, alert_params) ->
	subject = ""
	body    = ""
	checks.forEach (v) ->
		if v.alive
			subject += "#{v.name} (#{v.params.type}) has RECOVERED"
			body    += "Check \"#{v.name}\" (#{v.params.type}) has RECOVERED"
		else
			subject += "#{v.name} (#{v.params.type}) has FAILED"
			body    += "Check \"#{v.name}\" (#{v.params.type}) has FAILED"

	push.send alert_params.key, subject, body, (err, res) ->
		if err?
			console.log "Pushover Error: #{err.message}"
			return

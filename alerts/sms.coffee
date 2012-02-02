#
# Alert: SMS
#

TwilioClient = require('../lib/twilio').Client

twilio = null
phnum  = null

exports.init = (config) ->
	twilio = new TwilioClient config.options.twilio.sid, config.options.twilio.token
	phnum  = config.options.twilio.phnum

exports.run = (check_name, check_params, alert_params, alive) ->
	if alive
		message = "Check \"#{check_name}\" (#{check_params.type}) has RECOVERED"
	else
		message = "Check \"#{check_name}\" (#{check_params.type}) has FAILED"

	twilio.sendSms phnum, alert_params.phone, message, (err, res) ->
		if err?
			console.log "Twilio Error: #{err.message}"
			return
		console.log "SMS sent"

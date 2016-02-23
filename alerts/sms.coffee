#
# Alert: SMS
#
#
log = require('../lib/lassie').log

TwilioClient = require('../lib/twilio').Client

twilio = null
phnum  = null

exports.init = (config, cb) ->
	twilio = new TwilioClient config.options.twilio.sid, config.options.twilio.token
	phnum  = config.options.twilio.phnum
	cb()

exports.run = (checks, alert_params) ->
	body = ""
	checks.forEach (v) ->
		if v.alive
			body += "Check \"#{v.name}\" (#{v.params.type}) has RECOVERED\n"
		else
			body += "Check \"#{v.name}\" (#{v.params.type}) has FAILED\n"

	twilio.sendSms phnum, alert_params.phone, body, (err, res) ->
		if err?
			log "Twilio Error: #{err.message}"

#
# Alert: Email
#

mailer = require '../lib/node-mailer'

exports.init = (config, cb) -> cb()

exports.run = (checks, alert_params) ->
	body = ""
	checks.forEach (v) ->
		if v.alive
			body += "Check \"#{v.name}\" (#{v.params.type}) has RECOVERED\n"
		else
			body += "Check \"#{v.name}\" (#{v.params.type}) has FAILED\n"

	new mailer.Mail
    to:       alert_params.email
    from:     alert_params.email
    subject:  alert_params.subject or "Lassie Alert"
    body:     body
    callback: (err, data) -> true

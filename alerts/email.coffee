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

	# Old version used 'email' as the "To" field name
	to = alert_params.to or alert_params.email

	new mailer.Mail
    to:       to
    from:     alert_params.from or to
    subject:  alert_params.subject or "Lassie Alert"
    body:     body
    callback: (err, data) -> true

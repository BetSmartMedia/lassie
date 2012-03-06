#
# Alert: Email
#

mailer = require '../lib/node-mailer'

exports.init = (config) ->

exports.run = (check_name, check_params, alert_params, alive) ->
	if alive
		message = "Check \"#{check_name}\" (#{check_params.type}) has RECOVERED"
	else
		message = "Check \"#{check_name}\" (#{check_params.type}) has FAILED"

	new mailer.Mail
    to:       alert_params.email
    from:     alert_params.email
    subject:  alert_params.subject or "Lassie Alert"
    body:     message
    callback: (err, data) -> true

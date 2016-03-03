#
# Alert: Pushover
#

request = require('request')

push = null
token = null

exports.init = (config, cb) ->
	#push = new Pushover()
	token = config.options.pushover.token
	cb()

exports.run = (checks, alert_params) ->
	subject = ""
	body    = ""
	checks.forEach (v) ->
		# A priority of 2 will be used for fail notifications, which means the
		# user will have to confirm receipt of the notification - otherwise,
		# Pushover will make repeated push alerts. It will also bypass the
		# device's volume and quiet-hours settings.
		#
		# A priority of 0 will be used for recovery notifications, which means
		# the message will not bypass the device's volume or quiet-hours settings.
		# It will also not require receipt confirmation.
		data =
			token: token
			user: alert_params.key
			title: "Lassie Alert"
			priority: 0

		if v.alive
			data.message = "Check \"#{v.name}\" (#{v.params.type}) has RECOVERED"
		else
			data.message = "Check \"#{v.name}\" (#{v.params.type}) has FAILED"
			data.priority = 2
			data.retry = 30
			data.expire = 3600

		opts =
			url: "https://api.pushover.net/1/messages.json"
			form: data

		request.post opts, (err, res) ->
			if err
				console.log "Pushover Error: #{err}"
			#console.log res.body

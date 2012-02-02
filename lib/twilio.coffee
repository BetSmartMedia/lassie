#
# A very simple Twilio client capable of sending SMS messages.
#

https = require 'https'
qs    = require 'querystring'

exports.Client = class TwilioClient
	constructor: (@sid, @token) ->

	sendSms: (from, to, message, cb) ->
		params =
			From: from
			To:   to
			Body: message
		obody = qs.stringify params

		opts =
			host: 'api.twilio.com'
			port: 443
			path: "/2010-04-01/Accounts/#{@sid}/SMS/Messages.json"
			method: "POST"
			headers:
				'content-type':   'application/x-www-form-urlencoded'
				'content-length': obody.length
				'authorization':  'Basic ' + (new Buffer(@sid + ':' + @token)).toString 'base64'

		req = https.request opts, (res) ->
			res.setEncoding 'UTF8'
			ibody = ""
			res.on 'data', (chunk) -> ibody += chunk
			res.on 'end', ->
				try
					data = JSON.parse ibody
				catch e
					return cb e
				cb null, data

		req.on 'error', (e) -> cb e
		req.write obody
		req.end()

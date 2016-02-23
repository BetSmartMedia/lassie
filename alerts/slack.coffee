#
# Alert: Slack
#

log = require('../lib/lassie').log

RtmClient = require('slack-client').RtmClient
WebClient = require('slack-client').WebClient

# API client instances.
rtm = null
web = null

# Our config
config = null

# Map of names to IDs.
channels = {}
users = {}
dms = {}

loadChannels = (cb) ->
	web.channels.list (err, info) ->
		if err
			log "Slack Error: #{err}"
		else
			config?.channels?.forEach (name) ->
				info.channels.forEach (ch) ->
					if ch.name == name
						channels[name] = ch.id
			cb true

loadUsers = (cb) ->
	web.users.list (err, info) ->
		if err
			log "Slack Error: #{err}"
		else
			config?.users?.forEach (name) ->
				for u in info.members
					if u.name == name
						users[name] = u.id
			cb true


loadDMs = (cb) ->
	left = config?.users.length
	config.users?.forEach (name) ->
		web.dm.open "#{users[name]}", (err, info) ->
			dms[name] = info.channel.id
			if --left == 0
				cb true


exports.init = (cfg, cb) ->
	config = cfg.options.slack

	web = new WebClient config.token
	rtm = new RtmClient config.token, {logLevel: 'info'}

	rtm.start()

	# Collect internal IDs for channels/users we care about.
	loadChannels -> loadUsers -> loadDMs -> cb()


exports.run = (checks, alert_params) ->
	body = ""
	checks.forEach (v) ->
		if v.alive
			body += "Check \"#{v.name}\" (#{v.params.type}) has RECOVERED\n"
		else
			body += "Check \"#{v.name}\" (#{v.params.type}) has FAILED\n"

	alert_params.channels or= []
	alert_params.users or= []

	for name in alert_params.channels
		log "slack: Sending to #{name} / #{channels[name]}"
		rtm.sendMessage(body, channels[name])

	for name in alert_params.users
		log "slack: Sending to #{name} / #{dms[name]}"
		rtm.sendMessage(body, dms[name])

#
# Main logic for Lassie.
#

dateFormat = require 'dateformat'

config = {}
checks = {}
alerts = {}
state  = {}

running = false

log = (str) ->
	now = dateFormat new Date, "yyyy-mm-dd HH:MM:ss"
	msg = "[#{now}] #{str}"
	console.log msg

exports.init = (_config, _checks, _alerts) ->
	config = _config
	checks = _checks
	alerts = _alerts
	for name, params of config.checks
		state[name] = alive: true, failures: 0

exports.run = () ->
	# prevent multiple runs from executing at the same time
	if running
		log "Already running, skipping checks".yellow
		return

	running = true
	alerts_to_fire = []
	num_checks = Object.keys(config.checks).length

	# tick() is fired after every check
	tick = () ->
		if --num_checks > 0
			return
		running = false

		# batch alerts by alert names (eg, 'notify', 'emerg', etc)
		batch = {}
		alerts_to_fire.forEach (v) ->
			v[1].alerts.forEach (alert_name) ->
				batch[alert_name] or= []
				batch[alert_name].push
					alive:  v[2]
					name:   v[0]
					params: v[1]

		# send out alerts in batches
		for name, v of batch
			for alert_name, alert_params of config.alerts[name]
				console.log "Fire alert: #{alert_params.type}"
				alerts[alert_params.type].run v, alert_params

	for name, params of config.checks
		#log "Checking: #{name} (#{params.type})"
		do (name, params) ->
			checks[params.type].run params, (status) ->
				if status
					state[name].failures = 0
					if state[name].alive is false
						log "Check #{name} RECOVERED".green
						state[name].alive = true
						alerts_to_fire.push [name, params, state[name].alive]
				else
					if state[name].alive is true
						failures = params.failures or 1
						state[name].failures++
						if state[name].failures >= failures
							log "Check #{name} FAILED".red
							state[name].alive = false
							alerts_to_fire.push [name, params, state[name].alive]
						else
							d = failures - state[name].failures
							log "Check #{name} has failed #{state[name].failures} time(s) (#{d} more until alert)".yellow
				tick()

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

alert = (check_name, check_params) ->
	for alert_sect in check_params.alerts
		for alert_name, alert_params of config.alerts[alert_sect]
			log "Firing alert: #{alert_name}".cyan
			alerts[alert_params.type].run check_name, check_params, alert_params, state[check_name].alive, log

exports.run = () ->
	# prevent multiple runs from executing at the same time
	if running
		log "Already running, skipping checks".yellow
		return

	running = true
	num_checks = Object.keys(config.checks).length
	tick = () -> running = false if --num_checks < 1

	for name, params of config.checks
		log "Checking: #{name} (#{params.type})"
		do (name, params) ->
			checks[params.type].run params, (status) ->
				if status
					state[name].failures = 0
					if state[name].alive is false
						log "Check #{name} RECOVERED".green
						state[name].alive = true
						alert name, params
				else
					if state[name].alive is true
						failures = params.failures or 1
						state[name].failures++
						if state[name].failures >= failures
							log "Check #{name} FAILED".red
							state[name].alive = false
							alert name, params
						else
							d = failures - state[name].failures
							log "Check #{name} has failed #{state[name].failures} time(s) (#{d} more until alert)".yellow
				tick()

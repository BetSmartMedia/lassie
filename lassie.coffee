#!/usr/bin/env coffee
#
# Lassie - A watchdog service
#

require 'colors'
util   = require 'util'
fs     = require 'fs'
yaml   = require 'js-yaml'
daemon = require 'daemon'
Lassie = require './lib/lassie'

if process.argv.length < 3
	console.error "Usage: coffee lassie.coffee <config>"
	process.exit 1
try
	configtxt = fs.readFileSync process.argv[2], 'utf8'
	config    = yaml.load configtxt
catch e
	console.error "Error reading config:", e.message
	process.exit 1

checks = {}
alerts = {}

# fix setInterval's argument order
interval = (time, fn) -> setInterval fn, time


run = ->
	Lassie.init config, checks, alerts
	Lassie.run()
	interval config.options.check_frequency * 1000, -> Lassie.run()


startup = ->
	if config.options.daemon
		# Hack: Override the execPath, as the 'daemon' module will use this to
		# re-execute ourselves as a daemon, and the default 'node' binary will not
		# understand CoffeeScript.
		process.execPath = process.argv[0]

		# become a daemon; PID will change here, as we are re-executed.
		fd = fs.openSync config.options.log, 'a'
		daemon { stdout: fd, stderr: fd }
		# write PID
		fs.writeFileSync config.options.pid, process.pid

		Lassie.log "Starting"

		# catch SIGTERM and remove PID file
		process.on 'SIGTERM', ->
			Lassie.log "Caught SIGTERM, shutting down"
			fs.unlinkSync config.options.pid
			process.exit 0

	run()

# Always load the ping and tcp checks - the network_check feature will
# want them.
checks.ping = require "./checks/ping"
checks.tcp = require "./checks/tcp"

# Load check modules referenced in the config
for _, c of config.checks
	continue if checks[c.type]?
	checks[c.type] = require "./checks/#{c.type}"

# Load alert modules referenced in the config
for _, section of config.alerts
	for _, a of section
		continue if alerts[a.type]?
		alerts[a.type] = require "./alerts/#{a.type}"

remaining = Object.keys(alerts).length
for type, mod of alerts
	mod.init config, ->
		if --remaining == 0
			startup()



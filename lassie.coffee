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

# Load check modules referenced in the config
for _,c of config.checks
	continue if checks[c.type]?
	checks[c.type] = require "./checks/#{c.type}"

# Load alert modules referenced in the config
for _,section of config.alerts
	for _,a of section
		continue if alerts[a.type]?
		alerts[a.type] = require "./alerts/#{a.type}"
		alerts[a.type].init config

run = () ->
	Lassie.init config, checks, alerts
	Lassie.run()
	interval config.options.check_frequency * 1000, -> Lassie.run()

if config.options.daemon
	daemon.daemonize config.options.log, config.options.pid, (err, pid) ->
		# catch SIGTERM and remove PID file
		process.on 'SIGTERM', () ->
			fs.unlinkSync config.options.pid
			process.exit 0
		run()
else
	run()


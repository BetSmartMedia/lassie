## Lassie

Lassie is a simple watchdog service written in CoffeeScript. It sports a
basic modular architecture that can host multiple types of service checks
and alerts.

Lassie doesn't do any graphing or statistical collection. You probably
want statsd+Graphite or Munin if you're looking for something like that.
Lassie will notify you if a service goes down (and comes back up), nothing
more.


### Checks and Alerts

A few standard checks and alerts are included with Lassie. If you know
Javascript or CoffeeScript, then it is easy to create your own checks and
alerts.

#### Checks

- **ping**: Basic ICMP echo request. A cheap and not-foolproof way of
  checking if a server is alive on a network. Note that a server can
  respond to pings but still be "down" in some sense, so this rarely a
  sufficient check by itself.
- **web**: Retrieve a remote URL and look in the resulting payload for a
  specific fragment string. Can be useful to assess whether the payload is
  the expected body or whether it's an error message.
- **tcp**: Similar to the **web** check, but uses a raw TCP connection.
- **rest**: Retrieve a RESTful API endpoint and check if the HTTP status
  code was 200. If not, then it will be considered to be in a fail state.


#### Alerts

- **email**: 'nuff said.
- **sms**: Uses Twilio, so you will need an account with them.
- **slack**: You'll need to create a Bot Integration within your Slack
  account and use the provided API token.
- **pushover**: A SaaS product that sends push alerts to your phone. See
  their [website](https://pushover.net) for more details.


### Example Configuration

    options:
      # Check every X seconds
      check_frequency: 60

      # Run as a daemon
      daemon: true
      log:    lassie.log
      pid:    lassie.pid

      # Twilio API credentials
      twilio:
        sid:   TWILIO_SID
        token: TWILIO_TOKEN
        phnum: TWILIO_PHNUM   # outgoing phone number

      # Slack API token and target channels/users
      slack:
        token: SLACK_TOKEN
        channels:
          - 'monitoring'
        users:
          - 'judd'

    #
    # ALERTS LEVELS + CONTACTS
    #
    alerts:
      notify:
        admin-email:
          type:  email
          to: admin@example.com
        team-chat:
          type: slack
          channels: ['monitoring']
      emerg:
        admin-sms:
          type:  sms
          phone: "+18001234567"
        admin-slack:
          type: slack
          users: ['judd']

    #
    # CHECKS
    #
    checks:
      server1:
        type:   ping
        host:   server1.example.com
        alerts: [emerg, notify]
      server2:
        type:   ping
        host:   server2.example.com
        alerts: [emerg]

      site-web:
        type:     web
        url:      http://www.example.com
        fragment: "This is an example site"
        # This check must fail twice in a row before we consider it down.
        failures: 2
        alerts:   [emerg, notify]

      site-api:
        type: rest
        alerts: [emerg]
        url: 'https://api.example.com/test_endpoint'
        headers:
          accept: application/json
          x-api-key: abc123456

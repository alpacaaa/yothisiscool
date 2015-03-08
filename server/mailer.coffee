
Promise  = require 'bluebird'
mailgun  = require 'mailgun-js'
mustache = require 'mustache'

fs = require 'fs'


class Mailer

  constructor: (config) ->
    @mailgun = mailgun
      apiKey: config.MAILGUN_API_KEY
      domain: config.MAILGUN_DOMAIN

    file = __dirname + '/notification.tpl'
    @notification_tpl = fs.readFileSync(file).toString()


  send: (options) ->
    html = mustache.render @notification_tpl, options

    @mailgun.messages().send
      from: 'Dude this is cool <hey@dudethisis.cool>'
      to: options.email
      subject: 'YOLO'
      html: html


module.exports = Mailer

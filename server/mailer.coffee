
Promise = require 'bluebird'
mailgun = require 'mailgun-js'


class Mailer

  constructor: (config) ->
    @mailgun = mailgun
      apiKey: config.MAILGUN_API_KEY
      domain: config.MAILGUN_DOMAIN


  send: (options) ->
    @mailgun.messages().send
      from: 'Dude this is cool <hey@dudethisis.cool>'
      to: options.email
      subject: 'YOLO'
      text: "Check this out: #{options.comments.length}"


module.exports = Mailer

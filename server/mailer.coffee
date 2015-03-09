
Promise  = require 'bluebird'
mailgun  = require 'mailgun-js'
mustache = require 'mustache'
crypto = require 'crypto'
querystring = require 'querystring'

fs = require 'fs'


class Mailer

  constructor: (config) ->
    @mailgun = mailgun
      apiKey: config.MAILGUN_API_KEY
      domain: config.MAILGUN_DOMAIN

    file = __dirname + '/notification.tpl'
    @notification_tpl = fs.readFileSync(file).toString()

    @address_override = config.EMAIL_ADDRESS_OVERRIDE


  send: (options) ->
    email_token = options.user.getEmailToken()
    options = @add_links options, email_token
    html = mustache.render @notification_tpl, options

    params =
      from: 'Dude this is cool <hey@dudethisis.cool>'
      to: options.email
      subject: 'YOLO'
      html: html

    if @address_override
      params['h:Dude_address'] = params.to
      params.html += "<p>SENT TO #{options.user.username} – #{params.to}</p>"
      params.to = @address_override

    @mailgun.messages().send params



  generate_link: (action, email_token, params) ->
    params.access_token = @generate_access_token email_token, params
    qs = querystring.stringify params
    "https://dudethisis.cool/#{action}?#{qs}"

  generate_access_token: (email_token, params) ->
    str = Object.keys(params)
      .sort()
      .map (key) -> params[key]
      .join '|'

    str = email_token + str

    shasum = crypto.createHash 'sha512'
    shasum.update str
    shasum.digest 'hex'

  verify_token: (token, email_token, params) ->
    check = @generate_access_token email_token, params
    token == check


  add_links: (options, email_token) ->
    options.unsuscribe = @generate_link 'unsuscribe', email_token,
      email: options.email

    values =
      daily: 1
      weekly: 7
      monthly: 30

    for key,value of values
      options[key] = @generate_link 'subscription', email_token,
        email: options.email
        frequency: value


    options



module.exports = Mailer

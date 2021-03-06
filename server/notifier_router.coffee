
config = require './dude-config'
Promise = require 'bluebird'
moment  = require 'moment'
findgithubemail = require 'findgithubemail'
findgithubemail.access_token = config.GITHUB_ACCESS_TOKEN


Comment = null
GithubRepo = null
GithubUser = null
Notification = null
logger = null
isDev  = null


process_batch = (size) ->
  logger.info "Processing #{size} notifications"

  query =
    status: 'queued'
    schedule_date: lt: Date.now()

  Notification.findAsync
    where: query
    limit: size
    include: 'user'

  .then (notifications) =>

    unless notifications.length
      logger.info 'No new notifications'
      return []

    list = notifications.map (n) =>

      comments = Comment.findAsync
        where:
          id: inq: n.data.comments
          notified: null # cant get proper query to work, fuck me
        include: ['author', 'repo']

      Promise.props
        notification: n
        user: n.user()
        email: user_email n.user()
        comments: comments

    Promise.all list

  .then (data) =>

    list = data.map (item) =>
      unless item.comments.length
        return item.notification.updateAttributeAsync 'status', 'nocomments'

      unless item.email
        return item.notification.updateAttributeAsync 'status', 'unprocessable'

      if item.user.unsubscribed
        return item.notification.updateAttributeAsync 'status', 'unsubscribed'

      unless item.email == item.user.email
        item.user.updateAttribute 'email', item.email

      if isDev and !config.EMAIL_ADDRESS_OVERRIDE
        logger.warn 'Trying to send the message to the REAL email address, u mad bro'
        return Promise.resolve()

      logger.info "
        Sending email to #{item.email}
        with #{item.comments.length} comments
      "

      item.notification.updateAttribute 'status', 'processing'

      item.comments.forEach (c) ->
        Comment.beautify c, false
        permalink c
        date_posted c
        c.body = fix_comment_body c.body


      @mailer.send item
      .then ->
        item.notification.updateAttribute 'status', 'sent'
        item.user.updateAttribute 'last_notified', Date.now()

        item.comments.map (c) ->
          c.updateAttribute 'notified', true

      return true

    Promise.all list

  .then (data) ->
    logger.info "Processed #{data.length} notifications"







unsubscribe = (params) ->

  email = params.email
  token = params.access_token

  return Promise.reject() unless email and token

  GithubUser.findOneAsync email: email
  .then (user) =>
    email_token = user.email_token
    throw new Error('Email token not generated') unless email_token

    verify = @mailer.verify_token(token, email_token, email: email)
    throw new Error("Can't verify token for #{email}") unless verify

    user.updateAttributeAsync 'unsubscribed', true

  .then ->
    'You have unsubscribed succesfully!'



subscription = (params) ->
  email = params.email
  token = params.access_token
  frequency = params.frequency

  return Promise.reject() unless email and token and frequency

  GithubUser.findOneAsync email: email
  .then (user) =>
    email_token = user.email_token
    throw new Error('Email token not generated') unless email_token

    verify = @mailer.verify_token token, email_token,
      email: email
      frequency: frequency

    throw new Error("Can't verify token for #{email}") unless verify

    user.updateAttributesAsync
      unsubscribed: false
      notification_frequency: frequency

  .then ->
    "You will be notified every #{frequency} days, only if there's new activity."



user_email = (user) ->
  return user.email if user.email

  findgithubemail.find user.username
  .then (data) -> data.best_guess
  .catch ->
    logger.error 'Email not found ' + user.username






permalink = (item) ->
  link = "https://yothisis.cool/#{item.repo().slug}"
  item.project_link = link
  item.permalink = "#{link}#thank-#{item.id}"
  item


date_posted = (comment) ->
  comment.date_posted = moment(comment.date).format 'DD.MM.YYYY · HH:MM'


fix_comment_body = (body) ->
  # such inline, much wow
  body = body.split('<p>').join('<p style="margin:0;">')
  body = body.split('<strong>').join('<strong style="color:#3acec1;">')
  body = body.split('<a').join('<a style="color:#ea46b2; font-weight:bold; text-decoration:none;"')



module.exports = (app) ->
  Comment = app.models.Comment
  GithubRepo = app.models.GithubRepo
  GithubUser = app.models.GithubUser
  Notification = app.models.Notification
  logger = Notification.app.get('dude.logger')
  isDev = app.get('isDev')


  process_batch: process_batch
  unsubscribe: unsubscribe
  subscription: subscription


config = require './dude-config'
Promise = require 'bluebird'
findgithubemail = require 'findgithubemail'
findgithubemail.access_token = config.GITHUB_ACCESS_TOKEN


Comment = null
GithubRepo = null
GithubUser = null
Notification = null
logger = null



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

      comments = Comment.find
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

      item.notification.updateAttribute 'status', 'processing'

      unless item.email == item.user.email
        item.user.updateAttribute 'email', item.email


      logger.info "
        Sending email to #{item.email}
        with #{item.comments.length} comments
      "

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




user_email = (user) ->
  return user.email if user.email

  findgithubemail.find user.username
  .then (data) -> data.best_guess
  .catch ->
    logger.error 'Email not found ' + user.username





module.exports = (app) ->
  Comment = app.models.Comment
  GithubRepo = app.models.GithubRepo
  GithubUser = app.models.GithubUser
  Notification = app.models.Notification
  logger = Notification.app.get('dude.logger')


  process_batch: process_batch

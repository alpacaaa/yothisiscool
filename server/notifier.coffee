
Promise = require 'bluebird'
moment  = require 'moment'
findgithubemail = require 'findgithubemail'

config = require './dude-config'


Comment = null
GithubRepo = null
GithubUser = null
Notification = null
logger = null


class Notifier

  default_notification_frequency: 7 # days


  constructor: (app) ->
    Comment = app.models.Comment
    GithubRepo = app.models.GithubRepo
    GithubUser = app.models.GithubUser
    Notification = app.models.Notification
    logger = Notification.app.get('dude.logger')

    findgithubemail.access_token = config.GITHUB_ACCESS_TOKEN


  register_comment: (comment) ->

    promise = GithubRepo.findByIdAsync comment.repoId

    .then (repo) ->
      user_id = repo.ownerId
      return promise.cancel() if user_id == comment.authorId

      query = userId: user_id, status: 'queued'

      Promise.props
        user: GithubUser.findById user_id
        notification: Notification.findOneAsync where: query

    .then (data) =>
      notification = data.notification

      if notification
        notification.data.comments.push comment.id
        return notification.save()

      schedule_date = @process_schedule_date data.user

      Notification.createAsync
        schedule_date: schedule_date.toDate()
        data: comments: [comment.id]
        userId: data.user.id
        status: 'queued'


    .cancellable()
    .catch Promise.CancellationError, (->)

    .catch (e) ->
      logger.error e


  notification_frequency: (user) ->
    user.notification_frequency ? @default_notification_frequency

  process_schedule_date: (user) ->
    last_notified = user.last_notified
    now = moment()

    unless last_notified
      return now.add 2, 'hours'

    frequency = @notification_frequency user
    schedule  = moment(last_notified).add(frequency, 'days')
    schedule  = now.add(1, 'hour') if schedule.isBefore(now)

    schedule


  process_batch: (size) ->
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
          email: @user_email n.user()
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



  user_email: (user) ->
    return user.email if user.email

    findgithubemail.find user.username
    .then (data) -> data.best_guess
    .catch ->
      logger.error 'Email not found ' + user.username


module.exports = Notifier

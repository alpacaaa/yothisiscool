
Promise = require 'bluebird'
moment  = require 'moment'

Comment = null
GithubRepo = null
GithubUser = null
Notification = null



class Notifier

  default_notification_frequency: 7 # days


  constructor: (app) ->
    Comment = app.models.Comment
    GithubRepo = app.models.GithubRepo
    GithubUser = app.models.GithubUser
    Notification = app.models.Notification


  register_comment: (comment) ->

    GithubRepo.findById comment.repoId

    .then (repo) ->
      user_id = repo.ownerId
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

    .catch (e) ->
      logger = Notification.app.get('dude.logger')
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

module.exports = Notifier

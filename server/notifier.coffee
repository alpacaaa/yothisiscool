

Comment = null
Notification = null


class Notifier

  constructor: (app) ->
    Comment = app.models.Comment
    Notification = app.models.Notification

  register_comment: (comment) ->
    Notification.createAsync
      schedule_date: (new Date)
      data: comments: [comment.id]

    .then (n) ->
      n.updateAttribute 'ownerId', comment.authorId


module.exports = Notifier

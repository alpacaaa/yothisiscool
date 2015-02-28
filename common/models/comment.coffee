
sanitize = require 'sanitize-html'
emojione = require 'emojione'
twemoji  = require 'twemoji'
marked = require 'marked'

Promise = require 'bluebird'


module.exports = (Comment) ->

  Comment.afterRemote '**', (ctx, instance, next) ->
    return next() unless instance

    instance = [instance] unless instance.length
    instance.forEach Comment.beautify
    next()



  Comment.new = (comment, access_token, next) ->

    GithubUser = Comment.app.models.GithubUser
    GithubRepo = Comment.app.models.GithubRepo
    auth_token = GithubUser.generateAuthToken access_token

    user = null

    GithubUser.findOneAsync where: auth_token: auth_token
    .then (data) ->
      return data if data
      Promise.promisify(GithubUser.auth, GithubUser) access_token

    .then (data) ->
      return next(new Error('Wrong auth token')) unless data

      user = data
      GithubRepo.findOneAsync where: id: comment.repo

    .then (repo) ->
      return next(new Error('Repo does not exist')) unless repo

      body = sanitize comment.body,
        allowedTags: []

      return next(new Error('Empty body')) unless body.length

      Comment.createAsync
        body: body
        date: new Date()
        authorId: user.id
        repoId: comment.repo

    .then (c) ->
      next null, c




  # `beautify` seriously?
  Comment.beautify = (instance) ->
    body = instance.body
    return unless body

    body = markdownify body
    body = emojione.shortnameToUnicode body
    body = twemoji.parse body
    instance.body = body


  markdownify = (string) ->
    stupid = marked string,
      gfm: true,
      tables: false,
      breaks: false,
      pedantic: false,
      sanitize: true,
      smartLists: false,
      smartypants: false

    # remove <p></p>
    # doesn't make any sense
    # also, it's not clean
    # I feel dirty
    stupid = stupid.trim()

    if stupid[0..2] == '<p>'
      stupid = stupid[3..]

    if stupid[-4..] == '</p>'
      stupid = stupid[0..-5]

    stupid




  Comment.remoteMethod 'new',
    accepts: [
      { arg: 'comment', type: 'object', http: { source: 'body' }, required: true },
      { arg: 'access_token', type: 'string', http: { source: 'query' }, required: true }
    ]
    returns: { arg: 'result', type: 'object', root: true }


github = require '../../server/github'
Promise = require 'bluebird'
marked  = require 'marked'

index = require '../../server/alphabetic-index'


module.exports = (GithubRepo) ->

  GithubRepo.afterRemote '**', (ctx, instance, next) ->
    return next() unless instance

    instance = [instance] unless instance.length

    list = instance[0]?.comments?()
    return next() unless list?.length

    Comment = GithubRepo.app.models.Comment
    instance[0].comments().forEach Comment.beautify
    next()



  GithubRepo.new = (slug, access_token, next) ->
    GithubUser = GithubRepo.app.models.GithubUser
    repo = null
    user = null

    promise = GithubRepo.findOneAsync where: slug: slug
    .then (instance) ->
      return github.getRepo slug, access_token unless instance

      next null, instance

      return promise.cancel()

    .then (data) ->
      initial = data.name[0].toLowerCase()
      unless /^[a-z]$/.test initial
        initial = '#'

      repo_promise = GithubRepo.createAsync
        name: data.name
        slug: slug
        description: data.description
        initial: initial
        created_at: data.created_at

      Promise.props
        repo:  repo_promise
        owner: data.owner

    .then (data) ->
      # create user if needed
      repo  = data.repo
      user  = data.owner
      query = where: username: user.login
      GithubUser.findOneAsync query

    .then (instance) ->
      if instance
        updateOwner repo, instance, next
        error = new Promise.CancellationError('we good')
        return promise.cancel error

      github.request user.url, access_token

    .then (data) ->
      user = data

      GithubUser.createAsync
        name: user.name
        username: user.login
        avatar_url: user.avatar_url

    .then (new_user) ->
      updateOwner repo, new_user, next

    .cancellable()

    .catch Promise.CancellationError, ->
      # we good
      return false

    .catch (e) ->
      logger = GithubRepo.app.get('dude.logger')
      logger.error e
      next new Error('Repo does not exist on Github')


  GithubRepo.index = (next) ->
    connector = GithubRepo.app.dataSources.db.connector
    sql = "
    select repos.initial, count(repos.id) as count
    from GithubRepo as repos
    where repos.id in (
      select distinct(repoId) from Comment
    )
    group by repos.initial
    "

    connector.query sql, (err, data) ->
      by_initial = data.reduce ((acc, item) ->
        acc[item.initial] = item.count
        acc
      ), {}

      result = index.map (item) ->
        found = by_initial[item.letter.toLowerCase()]
        item.count = found ? 0
        item.slug  = (item.slug ? item.letter).toLowerCase()
        item

      next null, result

    return false


  GithubRepo.by_initial = (letter, next) ->
    letter = '#' if letter == 'hash'

    # Poor man mysql escape
    return next('what ya doin?') if letter.length > 1

    letter = letter.toLowerCase()
    connector = GithubRepo.app.dataSources.db.connector

    sql = "
    select repos.*, count(comments.id) as count
    from GithubRepo as repos
    left join Comment as comments on repos.id = comments.repoId
    where repos.initial = '#{letter}'
    group by repos.id
    having count > 0
    "

    connector.query sql, (err, data) ->
      result =
        letter: alphabetic_index[letter]
        repos:  data

      next null, result

    return false



  updateOwner = (repo, instance, next) ->
    repo.updateAttribute 'ownerId', instance.id
    next null, repo.id



  GithubRepo.remoteMethod 'new',
    accepts: [
      { arg: 'slug', type: 'string', required: true },
      { arg: 'access_token', type: 'string', http: { source: 'query' }, required: false }
    ]
    returns: { arg: 'result', type: 'object', root: true }

  GithubRepo.remoteMethod 'index',
    http: { verb: 'GET' }
    returns: { arg: 'result', type: 'object', root: true }

  GithubRepo.remoteMethod 'by_initial',
    http: { verb: 'GET' }
    accepts: { arg: 'letter', type: 'string', http: { source: 'query' }, required: true }
    returns: { arg: 'result', type: 'object', root: true }



cleanup_definition = (item) ->
  def = item.definition
  return item unless def

  def = marked item.definition
  def = def.replace('<a href', '<a target="_blank" href')
  item.definition = def
  item

alphabetic_index = do ->
  index.reduce ((acc, item) ->
    item = cleanup_definition item
    acc[item.letter.toLowerCase()] = item
    acc
  ), {}

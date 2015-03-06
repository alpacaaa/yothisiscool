
github = require '../../server/github'
crypto = require 'crypto'


module.exports = (GithubUser) ->


  GithubUser.auth = (access_token, next) ->
    url = github.api 'user'
    token = @generateAuthToken access_token

    GithubUser.findOneAsync where: auth_token: token
    .then (data) ->
      return github.request url, access_token unless data

      next null,
        username: data.login
        auth_token: token

    .then (user) ->
      query = where: username: user.login
      data  =
        name: user.name
        username: user.login
        avatar_url: user.avatar_url
        auth_token: token

      GithubUser.findOrCreateAsync query, data

    .then (user) ->
      if user.length
        user = user[0]

      user.updateAttribute 'auth_token', token
      next null, user

    .catch (e) ->
      logger = GithubUser.app.get('dude.logger')
      logger.error e
      next new Error('Invalid access token')


  GithubUser.starred = (access_token, next) ->
    url = github.api 'user/starred'

    github.request url, access_token
    .then (repos) =>
      slugs = repos
      .map (item) -> "'#{item.full_name}'"
      .join ', '

      # Backdoors all the way
      connector = GithubUser.app.dataSources.db.connector
      sql = "
      select repos.*, count(comments.id) as count
      from GithubRepo as repos, Comment as comments
      where comments.repoId = repos.id
      and repos.slug in (#{slugs})
      group by repos.id
      "

      connector.query sql, (err, data) ->
        found = data.reduce ((acc, item) ->
          acc[item.slug] = item
          acc
        ), {}

        ret = repos.map (item) ->
          slug = item.full_name
          repo = found[slug]
          return repo if repo

          slug:  slug
          count: 0

        return next null, ret

    .catch (e) ->
      logger = GithubUser.app.get('dude.logger')
      logger.error e
      next new Error('Invalid access token')

    return false



  GithubUser.generateAuthToken = (access_token) ->
    shasum = crypto.createHash 'sha1'
    shasum.update access_token
    shasum.digest 'hex'



  GithubUser.remoteMethod 'starred',
    http: { verb: 'GET' }
    accepts: { arg: 'access_token', type: 'string', http: { source: 'query' }, required: true }
    returns: { arg: 'result', type: 'object', root: true }

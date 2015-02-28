

request = require 'request-promise'

module.exports = do ->

  default_token = null

  api: (path) ->
    "https://api.github.com/#{path}"

  slugify: (user, repo) ->
    user + '/' + repo

  request: (url, access_token = null) ->
    access_token = access_token ? default_token

    if access_token
      url += "?access_token=#{access_token}"

    request
      url: url
      json: true
      headers:
        'User-Agent': 'DUDE'
      resolveWithFullResponse: true

    .then (res) =>
      remaining = res.headers['x-ratelimit-remaining']
      @onRequestCompleted remaining

      res.body

  setDefaultToken: (token) ->
    default_token = token

  onRequestCompleted: (->)

  getRepo: (slug, access_token = null) ->
    # check that repo exists
    url  = "https://github.com/#{slug}"
    request url: url, method: 'HEAD'
    .then (res) =>
      # if it exists, grab data
      url = @api "repos/#{slug}"
      @request url, access_token

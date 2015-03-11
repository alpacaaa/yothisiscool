
Promise = require 'bluebird'


module.exports = (app) ->

  connector = app.dataSources.db.connector
  isSqlConnector = !!connector.query

  GithubRepo = app.models.GithubRepo
  GithubUser = app.models.GithubUser
  Comment = app.models.Comment


  destroyDb: ->
    Promise.all [
      GithubUser.destroyAllAsync()
      GithubRepo.destroyAllAsync()
      Comment.destroyAllAsync()
    ]
    .then @resetAutoIncrement

  resetAutoIncrement: ->
    return Promise.resolve() unless isSqlConnector

    queries = ['GithubUser', 'GithubRepo', 'Comment'].map (table) ->
      "ALTER TABLE #{table} AUTO_INCREMENT = 1"

    Promise.reduce queries, (acc, sql) ->
      new Promise (resolve, reject) ->
        connector.query sql, resolve

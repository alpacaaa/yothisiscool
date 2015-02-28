

request = require 'supertest'
Promise = require 'bluebird'
crypto  = require 'crypto'
config  = require '../server/dude-config'

app = require '../server/server'

GithubRepo = app.models.GithubRepo
GithubUser = app.models.GithubUser
Comment = app.models.Comment


generateAuthToken = (access_token) ->
  shasum = crypto.createHash 'sha1'
  shasum.update access_token
  shasum.digest 'hex'




describe "User comments", ->

  token = 'dummy'
  hashed_token = generateAuthToken token

  before (done) ->
    Promise.all [
      GithubUser.destroyAllAsync()
      GithubRepo.destroyAllAsync()
      Comment.destroyAllAsync()
    ]
    .then ->
      GithubUser.createAsync
        username: 'the_dude'
        auth_token: hashed_token
    .then ->
      GithubRepo.createAsync
        name: 'evah'
        slug: 'greatestrepo/evah'

    .then -> done()



  it "should allow a user to leave a comment", (done) ->

    request(app)
    .post "/api/comments/new?access_token=#{token}"
    .send
      body: 'Bla bla, bau4iufsd'
      repo: 1
    .expect 200, done


  it "should prevent a user to add a comment if the access_token is wrong", (done) ->
    @timeout 5000

    request(app)
    .post "/api/comments/new?access_token=wrong_token"
    .send
      body: 'Bla bla, bau4iufsd'
      repo: 1
    .expect 500, done


  it "should allow a user to add a comment if the access_token is correct but the user isn't stored yet", (done) ->
    request(app)
    .post "/api/comments/new?access_token=#{config.GITHUB_ACCESS_TOKEN}"
    .send
      body: 'Bla bla, bau4iufsd'
      repo: 1
    .expect 200, done



  it "should prevent a user to use shitty HTML in the body of a comment", (done) ->

    request(app)
    .post "/api/comments/new?access_token=#{token}"
    .send
      body: 'Bla bla, <b>uhauh</b> shoulda not'
      repo: 1
    .expect 200
    .end (err, res) ->
      return done(err) if err
      if res.body.body.indexOf('<b>') > -1
        return done 'Shitty HTML still there'

      done()



  link = 'http://example.com/asd.gif'

  it "should allow a user to use Markdown", (done) ->
    request(app)
    .post "/api/comments/new?access_token=#{token}"
    .send
      body: "Bla bla, ![What the fuck](#{link}) should come up"
      repo: 1
    .expect 200
    .end (err, res) ->
      return done(err) if err
      if res.body.body.indexOf("<img src=\"#{link}\"") == -1
        return done 'Markdown broken'

      done()



  it "should allow a user to use emojis", (done) ->
    request(app)
    .post "/api/comments/new?access_token=#{token}"
    .send
      body: "Bla bla :smile: some more text"
      repo: 1
    .expect 200
    .end (err, res) ->
      return done(err) if err
      if res.body.body.indexOf("<img ") == -1
        return done 'Emojis broken'

      done()



  it "should show emojis when pulling comments from a repo", (done) ->
    request(app)
    .get "/api/githubrepos/?filter[where][id]=1&filter[include]=comments"
    .end (err, res) ->
      return done(err) if err
      last_comment = res.body[0].comments.pop()
      if last_comment.body.indexOf('<img class="emoji"') == -1
        return done 'afterRemote for Emojis broken'

      done()



  it "shouldn't allow empty comments", (done) ->
    request(app)
    .post "/api/comments/new?access_token=#{token}"
    .send
      body: ''
      repo: 1
    .expect 500, done


  it "shouldn't allow lengthy comments", (done) ->
    request(app)
    .post "/api/comments/new?access_token=#{token}"
    .send
      body: new Array(322).join('a')
      repo: 1
    .expect 500, done


  it "shouldn't allow to comment on a non existing repo", (done) ->
    request(app)
    .post "/api/comments/new?access_token=#{token}"
    .send
      body: 'asdfoaishf'
      repo: 5
    .expect 500, done

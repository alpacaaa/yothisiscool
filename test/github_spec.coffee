
assert  = require 'assert'
request = require 'supertest'
Promise = require 'bluebird'


user = 'alpacaaa'
repo = 'wadoo'
slug = "#{user}/#{repo}"


app = require '../server/server'

GithubRepo = app.models.GithubRepo
GithubUser = app.models.GithubUser
Comment = app.models.Comment



describe "Download info from Github", ->

  @timeout 5000

  before (done) ->
    Promise.all [
      GithubUser.destroyAllAsync()
      GithubRepo.destroyAllAsync()
      Comment.destroyAllAsync()
    ]
    .then -> done()


  it "should pull info from Github just ONCE", (done) ->

    createRepo = (cb) ->
      request(app)
      .post '/api/githubrepos/new'
      .send
        slug: slug
      .expect 200
      .end cb

    createRepo (err, res) ->
      repo_id = res.body
      return done(err) if err

      createRepo (err, res) ->
        return done(err) if err

        unless res.body.id == repo_id
          return done 'Repo created both times'

        done()




  it "Should return correct repo info", (done) ->
    request(app)
    .get "/api/githubrepos/findOne?filter[where][slug]=#{slug}"
    .end (err, res) ->
      return done(err) if err

      ret = res.body
      assert.equal ret.name, repo
      assert.equal ret.slug, slug
      assert.equal ret.initial, 'w'
      assert ret.description.indexOf('XML') > -1

      done()


  it "Should return correct user info", (done) ->
    request(app)
    .get "/api/githubusers/findOne?filter[where][username]=#{user}"
    .end (err, res) ->
      return done(err) if err

      ret = res.body
      assert.equal ret.name, 'Marco Sampellegrini'

      done()


  it "Should create a correct relation between repo and owner", (done) ->
    request(app)
    .get "/api/githubrepos/findOne?filter[where][slug]=#{slug}&filter[include]=owner"
    .end (err, res) ->
      return done(err) if err

      assert.ok res.body.owner.id

      done()

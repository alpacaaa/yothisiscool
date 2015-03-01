
`import Ember from 'ember'`
`import ENV from 'client/config/environment'`


ProjectRoute = Ember.Route.extend

  getRepo: (slug) ->
    @get('ws').request 'githubrepos'
    .where slug: slug
    .include ['owner', { comments: 'author' }]
    .findOne()


  model: (params) ->
    utils = @get 'utils'
    slug = @clean_slug params.slug
    controller = @get 'controller'

    unless slug.indexOf('/') > -1
      return @transitionTo 'index'

    promise = @getRepo(slug)
    .catch =>
      # does it even exist?
      @get('ws').github "repos/#{slug}"
      .find multiple: false
      .then ->
        utils.createRepo(slug)
      .then =>
        @getRepo slug


    Ember.RSVP.hash
      project: promise
      chars_allowed: ENV.APP.CHARS_ALLOWED


  clean_slug: (slug) ->
    slug.replace(/\/+$/, "")




  actions:
    newComment: (body) ->
      ws = @get 'ws'
      utils = @get 'utils'
      controller = @get 'controller'
      repo  = controller.get 'model.project.id'

      utils.requireAuth()
      .then ->
        token = utils.get('session').get 'access_token'

        ws.request 'comments', 'new'
        .access_token token
        .data
          body: body
          repo: repo
        .post()

      .then (data) ->
        ws.request 'comments'
        .where id: data.id
        .include 'author'
        .findOne()

      .then (data) ->
        controller.get('commentForm').send 'reset'
        controller.get('model.project.comments').pushObject data

      .catch (e) ->
        msg = e?.message ? e
        controller.get('commentForm').set 'errorMsg', msg



`export default ProjectRoute`

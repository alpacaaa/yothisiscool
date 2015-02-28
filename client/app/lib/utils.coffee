
`import Ember from 'ember'`


Session = Ember.Object.extend

  init: ->
    @_super()
    # needed to sync with Ember.Object
    Object.keys(localStorage).forEach (key) =>
      @set key, @getItem(key)

  setItem: (key, val) ->
    @set key, val
    localStorage.setItem key, val

  getItem: (key) ->
    localStorage.getItem key

  destroy: ->
    localStorage.clear()




Utils = Ember.Object.extend
  ws: null
  session: null

  init: ->
    @_super()
    @set 'session', Session.create()

  createRepo: (slug) ->
    @get('ws').request 'githubrepos', 'new'
      .data slug: slug
      .post()


  requireAuth: ->
    session = @get 'session'
    token = session.get 'access_token'
    return Ember.RSVP.resolve(token) if token

    new Ember.RSVP.Promise (resolve, reject) ->
      OAuth.popup 'github'
      .then (data) ->
        token = data?.access_token
        unless token
          reject 'Something went orribly wrong'

        session.setItem 'access_token', token
        resolve token




`export default Utils`

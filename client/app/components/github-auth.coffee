`import Ember from 'ember'`

GithubAuthComponent = Ember.Component.extend
  tagName: ''
  loggedIn: Ember.computed.alias 'utils.session.access_token'
  disconnected: false

  actions:
    logout: ->
      session = @get 'utils.session'
      session.set 'access_token', null
      session.destroy()

      @set 'disconnected', true
      Ember.run.later @, (->
        @set 'disconnected', false
      ), 10000

`export default GithubAuthComponent`

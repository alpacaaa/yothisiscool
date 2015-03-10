
`import Ember from 'ember'`

AlphabeticRoute = Ember.Route.extend

  model: (params) ->
    promise = @get('ws').request 'githubrepos', 'index'
    .find()

    Ember.RSVP.hash
      by_letter: promise



`export default AlphabeticRoute`

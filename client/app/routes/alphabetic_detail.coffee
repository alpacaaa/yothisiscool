
`import Ember from 'ember'`

AlphabeticDetailRoute = Ember.Route.extend

  model: (params) ->
    promise = @get('ws').request 'githubrepos', 'by_initial'
    .data
      letter: params.letter
    .find multiple: false

    Ember.RSVP.hash
      result: promise



`export default AlphabeticDetailRoute`

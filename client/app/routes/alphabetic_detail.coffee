
`import Ember from 'ember'`

AlphabeticDetailRoute = Ember.Route.extend

  model: (params) ->
    promise = @get('ws').request 'githubrepos', 'by_initial'
    .data
      letter: params.letter
    .find multiple: false
    .then (data) ->
      data.repos.forEach (item) ->
        item.owner =
          username: item.slug.split('/').shift()

      data

    Ember.RSVP.hash
      result: promise



`export default AlphabeticDetailRoute`


`import Ember from 'ember'`

Route = Ember.Route.extend
  model: ->
    latest_comments =
      @get('ws').request 'comments'
        .include 'author', 'repo'
        .order 'date DESC'
        .limit 32
        .findMany()

    Ember.RSVP.hash
      latest_comments: latest_comments

`export default Route`

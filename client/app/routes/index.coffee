
`import Ember from 'ember'`

Route = Ember.Route.extend
  model: ->
    latest_comments:
      @get('ws').request 'comments'
      .include 'author', 'repo'
      .order 'date DESC'
      .limit 16
      .findMany()

`export default Route`

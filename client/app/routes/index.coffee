
`import Ember from 'ember'`

Route = Ember.Route.extend
  model: ->
    latest_comments:
      @get('ws').request 'comments'
      .include 'author', 'repo'
      .order 'date DESC'
      .limit 16
      .findMany()

  actions:
    showStarredRepos: ->
      @get('controller.starredRepos').send 'show_starred_repos'


`export default Route`

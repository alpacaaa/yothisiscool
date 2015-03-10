
`import Ember from 'ember'`

Route = Ember.Route.extend
  model: ->
    latest_comments =
      @get('ws').request 'comments'
        .include 'author', 'repo'
        .order 'date DESC'
        .limit 16
        .findMany()

    Ember.RSVP.hash
      latest_comments: latest_comments


  actions:
    showStarredRepos: ->
      @get('utils').getStarredRepos()
      .then (data) =>
        @set 'controller.model.starred_repos', data


`export default Route`

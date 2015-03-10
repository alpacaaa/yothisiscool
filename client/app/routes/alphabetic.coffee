
`import Ember from 'ember'`

AlphabeticRoute = Ember.Route.extend

  model: (params) ->
    promise = @get('ws').request 'githubrepos', 'index'
    .find()

    Ember.RSVP.hash
      by_letter: promise


  actions:
    showStarredRepos: ->
      @get('utils').getStarredRepos()
      .then (data) =>
        @set 'controller.model.starred_repos', data


`export default AlphabeticRoute`

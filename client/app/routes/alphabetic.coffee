
`import Ember from 'ember'`

AlphabeticRoute = Ember.Route.extend

  model: (params) ->
    promise = @get('ws').request 'githubrepos', 'index'
    .find()

    Ember.RSVP.hash
      by_letter: promise


  actions:
    showStarredRepos: ->
      @get('controller.starredRepos').send 'show_starred_repos'


`export default AlphabeticRoute`

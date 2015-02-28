
`import Ember from 'ember'`

StarredReposComponent = Ember.Component.extend
  tagName: ''

  repos: []

  actions:
    show_starred_repos: ->
      utils = @get 'utils'

      utils.requireAuth()
      .then =>
        token = utils.get('session.access_token')

        @get('ws').request 'githubusers', 'starred'
        .access_token token
        .find()

      .then (data) =>
        @set 'repos', data

`export default StarredReposComponent`

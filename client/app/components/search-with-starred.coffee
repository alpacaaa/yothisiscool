`import Ember from 'ember'`

SearchWithStarredComponent = Ember.Component.extend
  tagName: ''

  starred_repos: []

  actions:
    onRepoFound: (slug)->
      @sendAction 'found_repo', slug

    showStarredRepos: ->
      @get('utils').getStarredRepos()
      .then (data) =>
        @set 'starred_repos', data


`export default SearchWithStarredComponent`

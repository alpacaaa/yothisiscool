2
`import Ember from 'ember'`

SearchRepoComponent = Ember.Component.extend

  tagName: ''
  search: ''
  hasError: false
  errorMsg: 'Mmm. This doesn’t look like a <strong>valid Github URL</strong>.'
  repoNotExistsMsg: 'Are you sure this repository exists?'

  trimSlashes: (string) ->
    string = string.replace(/^\/+|\/+$/g, '')
    if string.indexOf('/') > -1 then string else false

  normalizeSlug: (string) ->
    string = string.trim()
    string = @trimSlashes(string)
    return false unless string

    string = string.replace('github.com', '')
    string = string.replace(/^https?:\/\//,'')
    string = @trimSlashes(string)
    return false unless string

    string


  actions:
    form_submit: ->
      search = @get 'search'
      slug = @normalizeSlug search

      unless slug
        return @set 'hasError', @get('errorMsg')

      @get('utils').createRepo slug
      .then (repo) =>
        @sendAction 'found_repo', slug
      .catch =>
        @set 'hasError', @get('repoNotExistsMsg')


    removeErrors: ->
      @set 'hasError', false

    show_starred_repos: ->
      @sendAction 'show_starred_repos'


`export default SearchRepoComponent`

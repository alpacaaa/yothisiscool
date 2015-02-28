`import Ember from 'ember'`
`import { module, test } from 'qunit'`
`import startApp from '../helpers/start-app'`

application = null

module 'Acceptance: Homepage',
  beforeEach: ->
    application = startApp()
    ###
    Don't return as Ember.Application.then is deprecated.
    Newer version of QUnit uses the return value's .then
    function to wait for promises if it exists.
    ###
    return

  afterEach: ->
    Ember.run application, 'destroy'


repo = 'alpacaaa/xpathr'

test 'Search field is working', (assert) ->
  visit '/'
  fillIn '#search', 'alpacaaa'
  click '.form-search button'

  andThen ->
    assert.ok find('.form-search .field').hasClass('error')

    fillIn '#search', repo
    click '.form-search button'

  andThen ->
    assert.equal find('.form-search .field').hasClass('error'), false, 'Error removed'
    assert.equal currentPath(), 'project'
    assert.ok currentURL().indexOf(repo) > -1



test 'Latest comments are shown', (assert) ->
  return expect(0)
  visit '/'

  andThen ->
    comments = findWithAssert('ol.comments')
    assert.ok comments.find('li').length

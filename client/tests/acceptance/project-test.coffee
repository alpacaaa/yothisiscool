`import Ember from 'ember'`
`import { module, test } from 'qunit'`
`import startApp from '../helpers/start-app'`

application = null

module 'Acceptance: Project',
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

test 'Project info are shown', (assert) ->
  visit '/r/' + repo

  andThen ->
    assert.equal currentRouteName(), 'project'
    overview = find '.body.author'
    text = overview.text()

    assert.ok text.indexOf('@alpacaaa')
    assert.ok text.indexOf('xpathr')

`import Ember from 'ember'`
`import config from './config/environment'`
`import googlePageview from './mixins/google-pageview'`

Router = Ember.Router.extend googlePageview,
  location: config.locationType

Router.map ->
  @route 'project',  { path: '/*slug' }

  @route 'alphabetic', { path: '/index' }
  @route 'alphabetic_detail', { path: '/index/:letter' }

  @route 'colophon'
  @route '500'

`export default Router`

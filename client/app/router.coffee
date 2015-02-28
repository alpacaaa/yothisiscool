`import Ember from 'ember'`
`import config from './config/environment'`

Router = Ember.Router.extend
  location: config.locationType

Router.map ->
  @route 'project',  { path: '/r/*slug' }

  @route 'alphabetic', { path: '/index' }
  @route 'alphabetic_detail', { path: '/index/:letter' }

  @route 'colophon'

`export default Router`

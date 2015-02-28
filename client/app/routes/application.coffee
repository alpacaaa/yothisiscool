
`import Ember from 'ember'`
`import ENV from 'client/config/environment'`

ApplicationRoute = Ember.Route.extend

  actions:
    transitionToRepo: (slug) ->
      @transitionTo 'project', slug

`export default ApplicationRoute`

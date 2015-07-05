
`import Ember from 'ember'`


StarredReposComponent = Ember.Component.extend
  tagName: ''
  repos: []

  onReposFound: (->
    Ember.run.scheduleOnce 'afterRender', null, ->
      top = Ember.$('#starred-repositories').offset().top

      Ember.$('html,body').animate
        scrollTop: top - 50
  ).observes 'repos.length'

`export default StarredReposComponent`

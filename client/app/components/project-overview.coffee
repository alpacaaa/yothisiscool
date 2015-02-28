
`import Ember from 'ember'`
`import { ago } from 'ember-moment/computed'`

ProjectOverviewComponent = Ember.Component.extend
  tagName: ''
  timeAgo: ago 'project.created_at', true

  githubUrl: (->
    slug = @get 'project.slug'
    "https://github.com/#{slug}"
  ).property 'project.slug'

  didInsertElement: ->
    # make sure we scroll up!
    Ember.$('html,body').scrollTop 0

`export default ProjectOverviewComponent`

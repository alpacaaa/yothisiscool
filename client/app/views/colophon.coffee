
`import Ember from 'ember'`

View = Ember.View.extend
  tagName: ''

  didInsertElement: ->
    $('html,body').scrollTop 0

`export default View`

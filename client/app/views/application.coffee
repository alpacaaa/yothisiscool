
`import Ember from 'ember'`

View = Ember.View.extend
  tagName: ''

  actions:
    topClicked: ->
      $('html,body').animate scrollTop: 0

`export default View`


`import Ember from 'ember'`

View = Ember.View.extend
  tagName: ''

  didInsertElement: ->
    hbody = $('html,body')
    hbody.scrollTop 0

    $('a[href ^= "#fn"]').click (e) ->
      e.preventDefault()
      target = $(this).attr('href').substr 1
      hbody.animate
        scrollTop: $("*[id='#{target}']").offset().top - 20


`export default View`

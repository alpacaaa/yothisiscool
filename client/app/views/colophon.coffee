
`import Ember from 'ember'`

View = Ember.View.extend
  tagName: ''

  didInsertElement: ->
    hbody = $('html,body')
    hbody.scrollTop 0

    $('sup a').click (e) ->
      e.preventDefault()
      target = $(this).attr('href').substr 1
      hbody.animate
        scrollTop: $("div[id='#{target}']").offset().top - 20


`export default View`

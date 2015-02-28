
`import Ember from 'ember'`
`import { test, moduleForComponent, fillIn } from 'ember-qunit'`

moduleForComponent 'search-repo'

test 'Search string is valid', ->
  component = @subject()

  equal component.normalizeSlug('https://github.com/alpacaaa/xpathr'), 'alpacaaa/xpathr', 'Full github url'
  equal component.normalizeSlug('alpacaaa/xpathr'), 'alpacaaa/xpathr', 'Just the slug'
  equal component.normalizeSlug('/alpacaaa/xpathr/'), 'alpacaaa/xpathr', 'Slug with trailing/leading slash'
  equal component.normalizeSlug('  /alpacaaa/xpathr/  '), 'alpacaaa/xpathr', 'Extra white space'

  ok !component.normalizeSlug('simplestring'), 'String without slashes'

  Ember.run ->
    component.set 'search', 'xpathr'

  form  = @$('.form-search')
  field = form.find('.field')

  form.trigger 'submit'
  Ember.run ->
    ok field.hasClass('error'), 'Form with unvalid string'

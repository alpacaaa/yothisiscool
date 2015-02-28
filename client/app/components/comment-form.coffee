
`import Ember from 'ember'`
`import InboundActions from 'ember-component-inbound-actions/inbound-actions'`


CommentFormComponent = Ember.Component.extend InboundActions,
  tagName: ''
  isOpen: false
  comment: ''

  errorMsg: false
  emptyError: 'Doh. Something’s wrong here.'
  userIsTyping: false

  showTypingMessage: Ember.computed.or('utils.session.access_token', 'userIsTyping')

  submitComment: ->
    body = @get 'comment'
    unless body?.length
      return @set 'errorMsg', @get('emptyError')

    @sendAction 'submit', body

  actions:
    form_submit: ->
      opened = @get 'isOpen'
      return @submitComment() if opened

      @set 'isOpen', true
      @$('textarea').focus()

    removeErrors: ->
      @set 'errorMsg', false

    userTyping: ->
      @set 'userIsTyping', true

    reset: ->
      @set 'isOpen', false
      @set 'errorMsg', false
      @set 'comment', ''


`export default CommentFormComponent`

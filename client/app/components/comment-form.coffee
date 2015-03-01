
`import Ember from 'ember'`
`import InboundActions from 'ember-component-inbound-actions/inbound-actions'`


CommentFormComponent = Ember.Component.extend InboundActions,
  tagName: ''
  isOpen: false
  comment: ''
  chars_allowed: null

  errorMsg: false
  emptyError: 'Doh. Something’s <strong>wrong<strong/> here.'
  tooManyChars: 'Oops. <strong>Too many characters</strong> confuse the plot!'
  userIsTyping: false

  showTypingMessage: Ember.computed.or('utils.session.access_token', 'userIsTyping')

  remainingChars: (->
    chars = @get 'chars_allowed'
    chars - @get('comment.length') if chars
  ).property 'comment'

  watchChars: (->
    if @get('remainingChars') < 0
      @set 'errorMsg', @get('tooManyChars')
  ).observes 'remainingChars'

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

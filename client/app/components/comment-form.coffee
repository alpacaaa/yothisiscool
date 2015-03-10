
`import Ember from 'ember'`


CommentFormComponent = Ember.Component.extend
  isOpen: false
  comment: ''
  chars_allowed: null

  reset: true
  errorMsg: false
  emptyError: 'Doh. Something’s <strong>wrong<strong/> here.'
  tooManyChars: 'Oops. <strong>Too many characters</strong> confuse the plot!'
  userIsTyping: false

  showTypingMessage: Ember.computed.or('utils.session.access_token', 'userIsTyping')

  remainingChars: (->
    @set 'reset', false

    chars = @get 'chars_allowed'
    chars - @get('comment.length') if chars
  ).property 'comment'

  watchChars: (->
    msg = false

    if @get('remainingChars') < 0
      msg = @get 'tooManyChars'

    @set 'errorMsg', msg
  ).observes 'remainingChars'

  submitComment: ->
    body = @get 'comment'
    unless body?.length
      return @set 'errorMsg', @get('emptyError')

    @sendAction 'submit', body


  onReset: (->
    return unless @get('reset') == true

    @set 'isOpen', false
    @set 'errorMsg', false
    @set 'comment', ''
  ).observes 'reset'


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



`export default CommentFormComponent`

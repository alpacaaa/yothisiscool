
`import Ember from 'ember'`

CommentsListComponent = Ember.Component.extend
  tagName: 'ol'
  classNames: 'comments'
  comments: []
  sorting: ['date:desc']
  orderedComments: Ember.computed.sort 'comments', 'sorting'

  showRepo:  true
  showIndex: true
  hasPackery: false
  destroyed:  false

  comment_selected: null

  onInit: ( ->
    $(window).resize @onResize.bind(@)
    @onResize()
    @scrollToComment()
  ).on 'didInsertElement'

  onCommentsUpdate: (->
    Ember.run.scheduleOnce 'afterRender', @, @updatePackery
  ).observes 'comments.@each'

  onResize: ->
    unless @get 'hasPackery'
      @$().find('li').removeAttr 'style'

    Ember.run.debounce @, (->
      hasPackery = @get 'hasPackery'

      if $(window).width() < 576
        if hasPackery
          @destroyPackery()
      else
        unless hasPackery
          @initPackery()
    ), 1000


  updatePackery: ->
    hasPackery = @get 'hasPackery'

    @destroyPackery() if hasPackery

    @initPackery()


  initPackery: ->
    container = @$()
    return if container.data 'packery'

    @set 'hasPackery', true

    container.imagesLoaded ->
      container.packery
        itemSelector: '.comment'
        columnWidth: 288
        gutter: 0


  destroyPackery: ->
    container = @$()
    return unless container.data 'packery'

    container.packery 'destroy'
    @set 'hasPackery', false

  onDestroy: (->
    @destroyPackery()
  ).on 'willDestroyElement'


  scrollToComment: (->
    Ember.run.scheduleOnce 'afterRender', @, ->
      @$().imagesLoaded =>

        el = @$('.comment.selected')
        return unless el.length
        top  = el.offset().top
        half = el.outerHeight() / 2
        win  = Ember.$(window).height() / 2

        Ember.$('html,body').animate scrollTop: top - win + half
  ).observes 'comment_selected'


`export default CommentsListComponent`

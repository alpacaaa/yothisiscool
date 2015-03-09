
`import Ember from 'ember'`

CommentsListComponent = Ember.Component.extend
  tagName: ''
  comments: []
  sorting: ['date:desc']
  orderedComments: Ember.computed.sort 'comments', 'sorting'

  showIndex: true
  showRepo:  true
  hasPackery: false
  destroyed:  false

  comment_selected: null

  onInit: ( ->
    $(window).resize @onResize.bind(@)
    @onResize()
    @scrollToComment()

    # This sucks (and is deprecated too)
    # but until Ember 1.11
    # I'm not gonna change it
    if @get('showIndex')
      @$('.comment:last').addClass 'is_first'
  ).on 'didInsertElement'

  onCommentsUpdate: (->
    Ember.run.scheduleOnce 'afterRender', @, @updatePackery
  ).observes 'comments.@each'

  onResize: ->
    return if @get('destroyed')

    Ember.run.debounce @, (->
      hasPackery = @get 'hasPackery'

      if $(window).width() < 576
        if hasPackery
          @destroyPackery()
      else
        unless hasPackery
          @initPackery()
    ), 200


  updatePackery: ->
    hasPackery = @get 'hasPackery'

    @destroyPackery() if hasPackery

    @initPackery()


  initPackery: ->
    container = @$('.comments')
    @set 'hasPackery', true
    @set 'destroyed',  false

    container.imagesLoaded ->
      container.packery
        itemSelector: '.comment'
        columnWidth: 288
        gutter: 0


  destroyPackery: ->
    container = @$('.comments')
    return unless container.data 'packery'

    container.packery 'destroy'
    @set 'hasPackery', false
    @set 'destroyed',  true

  onDestroy: (->
    @destroyPackery()
  ).on 'willDestroyElement'


  scrollToComment: (->
    Ember.run.scheduleOnce 'afterRender', @, ->
      @$('.comments').imagesLoaded =>

        el = @$('.comment.selected')
        return unless el.length
        top  = el.offset().top
        half = el.outerHeight() / 2
        win  = Ember.$(window).height() / 2

        Ember.$('html,body').animate scrollTop: top - win + half
  ).observes 'comment_selected'


`export default CommentsListComponent`

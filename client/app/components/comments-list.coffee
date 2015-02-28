
`import Ember from 'ember'`

CommentsListComponent = Ember.Component.extend
  tagName: ''
  comments: []
  sorting: ['date:desc']
  orderedComments: Ember.computed.sort 'comments', 'sorting'

  hasPackery: false
  destroyed:  false

  onInit: ( ->
    $(window).resize @onResize.bind(@)
    @onResize()
  ).on 'didInsertElement'

  onCommentsUpdate: (->
    Ember.run.scheduleOnce 'afterRender', @, @updatePackery
  ).observes 'comments.@each'

  onResize: ->
    return if @get('destroyed')

    Ember.run.debounce @, (->
      container  = @$('.comments')
      hasPackery = @get 'hasPackery'

      if $(window).width() < 576
        if hasPackery
          @destroyPackery()
          @set 'hasPackery', false
      else
        unless hasPackery
          @initPackery()
    ), 200


  updatePackery: ->
    container = @$('.comments')
    hasPackery = @get 'hasPackery'

    @destroyPackery() if hasPackery

    @initPackery()


  initPackery: ->
    container = @$('.comments')
    @set 'hasPackery', true

    container.imagesLoaded ->
      container.packery
        itemSelector: '.comment'
        columnWidth: 288
        gutter: 0


  destroyPackery: ->
    container = @$('.comments')
    return unless container.data 'packery'
    container.packery 'destroy'

  onDestroy: (->
    @set 'destroyed', true
  ).on 'willDestroyElement'


`export default CommentsListComponent`

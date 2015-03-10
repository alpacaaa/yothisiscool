
`import Ember from 'ember'`
`import { ago } from 'ember-moment/computed'`

SingleCommentComponent = Ember.Component.extend
  tagName: ''
  timeAgo: ago 'comment.date', true
  showRepo: true

  comment_permalink: (->
    @get('comment.repo.slug') + '#thank-' + @get('comment.id')
  ).property()

  selected: (->
    @get('comment.id') == @get('comment_selected')
  ).property 'comment_selected'

  is_first: (->
    @get('showIndex') and @get('index') == 0
  ).property()

`export default SingleCommentComponent`

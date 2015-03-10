
`import Ember from 'ember'`
`import { ago } from 'ember-moment/computed'`

SingleCommentComponent = Ember.Component.extend
  tagName: ''
  timeAgo: ago 'comment.date', true
  showRepo: true
  comments_length: 0

  comment_permalink: (->
    @get('comment.repo.slug') + '#thank-' + @get('comment.id')
  ).property()

  selected: (->
    @get('comment.id') == @get('comment_selected')
  ).property 'comment_selected'

  is_first: (->
    last = @get('comments_length') - 1
    @get('showIndex') and @get('index') == last
  ).property()

`export default SingleCommentComponent`

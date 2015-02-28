
`import Ember from 'ember'`
`import { ago } from 'ember-moment/computed'`

SingleCommentComponent = Ember.Component.extend
  tagName: ''
  timeAgo: ago 'comment.date', true

`export default SingleCommentComponent`

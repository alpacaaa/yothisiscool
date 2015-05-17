
`import Ember from 'ember'`

UserAvatarComponent = Ember.Component.extend

  tagName: ''
  user: null
  size: ''

  avatar_url: (->
    size = @get 'size'
    size = "&s=#{size}" if size
    @get('user.avatar_url') + size
  ).property 'user.avatar_url', 'size'

`export default UserAvatarComponent`

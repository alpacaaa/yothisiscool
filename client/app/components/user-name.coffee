
`import Ember from 'ember'`

UsernameComponent = Ember.Component.extend

  tagName: ''
  user: null

  githubProfile: (->
    username = @get 'user.username'
    "https://github.com/#{username}"
  ).property 'user.username'

`export default UsernameComponent`


`import Ember from 'ember'`
`import request from 'ic-ajax'`


## Stolen from Ember Data
PromiseObject = Ember.ObjectProxy.extend(Ember.PromiseProxyMixin)
PromiseArray = Ember.ArrayProxy.extend(Ember.PromiseProxyMixin)

promiseObject = (promise, label) ->
  PromiseObject.create
    promise: Promise.resolve(promise, label)

promiseArray = (promise, label) ->
  PromiseArray.create
    promise: Promise.resolve(promise, label)


RequestObject = Ember.Object.extend

  init: ->
    @setProperties
      base: ''
      qs:
        filter: {}
      options:
        json: true

  include: (list...) ->
    @set 'qs.filter.include', list
    @

  order: (list...) ->
    @set 'qs.filter.order', list
    @

  where: (obj) ->
    @set 'qs.filter.where', obj
    @

  limit: (n) ->
    @set 'qs.filter.limit', n
    @

  data: (data) ->
    @set 'options.data', data
    @

  access_token: (token) ->
    @set 'qs.access_token', token
    @

  find: (config = {}) ->
    options = @get 'options'
    options.url = @buildUrl()
    options.method = 'GET'
    config.multiple = config?.multiple ? true

    cb = if config.multiple
      promiseArray
    else
      promiseObject

    cb request(options)

  findOne: ->
    @set 'id', 'findOne'
    @find multiple: false

  findMany: ->
    @set 'id', null
    @find multiple: true

  post: ->
    options = @get 'options'
    options.url = @buildUrl()
    options.method = 'POST'

    request options

  buildUrl: ->
    qs  = @get 'qs'
    id  = @get 'id'
    url = @get 'base'
    url += '/' + id if id

    url = url + '?' + @buildQueryString(qs)

  buildQueryString: (qs) ->
    Object.keys(qs).map (key) ->
      value = qs[key]
      value = JSON.stringify(value) if typeof value is 'object'
      key + '=' + value
    .join '&'




WS = Ember.Object.extend
  host: ''

  request: (path, id = '') ->
    base = @get('host') + path

    obj = RequestObject.create()
    obj.setProperties
      id: id
      base: base

    obj

  github: (path) ->
    obj = RequestObject.create()
    obj.setProperties
      id: path
      base: 'https://api.github.com'

    obj

`export default WS`

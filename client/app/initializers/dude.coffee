
`import WS from '../lib/ws'`
`import Utils from '../lib/utils'`
`import ENV from 'client/config/environment'`


init =
  name: 'dude'
  initialize: (container, app) ->
    OAuth.initialize 'look at all the fucks I give'
    OAuth.setOAuthdURL ENV.APP.OAUTH_ENDPOINT

    ws = WS.create
      host: ENV.APP.WS_ENDPOINT

    utils = Utils.create
      ws: ws

    app.register 'dude:ws', ws, { instantiate: false }
    app.register 'dude:utils', utils, { instantiate: false }
    app.inject 'route', 'ws', 'dude:ws'
    app.inject 'route', 'utils', 'dude:utils'
    app.inject 'component', 'utils', 'dude:utils'
    app.inject 'component', 'ws', 'dude:ws'


`export default init`

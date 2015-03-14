
path = require 'path'
Promise = require 'bluebird'
bbutil  = require 'bluebird/js/main/util'
serveStatic = require 'serve-static'

config = require '../dude-config'
github = require '../github'
Mailer = require '../mailer'
Notifier = require '../notifier'
httpCache = require '../http_cache'
NotifierRouter = require '../notifier_router'

winston = require 'winston'
logentries = require 'le_node'


frontend_path = path.join(__dirname, '../../frontend')
logs_path = path.join(__dirname, '../../logs')


promisifyAlltheThings = (app) ->
  for model, p of app.models
    Promise.promisifyAll p, filter: (name, func, target) ->
      return bbutil.isIdentifier(name) &&
        !bbutil.isClass(func) &&
        name.charAt(0) isnt '_' &&
        name.indexOf('Async') is -1 &&
        name isnt 'app'



initLogs = (app) ->

  unless app.get('isDev')
    winston.add winston.transports.DailyRotateFile,
      filename: logs_path + '/dude.log'

  app.set 'dude.logger', winston

  github.onRequestCompleted = (remaining) ->
    winston.info remaining + ' requests remaining'



enableOAuth = (app) ->
  github.setDefaultToken config.GITHUB_ACCESS_TOKEN

  for k, v of config
    # Obama disapproves
    process.env[k] = v

  handlers = require('oauth-express').handlers
  app.get '/auth/:provider', handlers.auth_provider_redirect
  app.get '/auth_callback/:provider', handlers.auth_callback




dudeRoutes = (app) ->
  # With FastBoot, God will forgive our sins
  # In the meantime...

  restApiRoot = app.get('restApiRoot')
  app.use(restApiRoot, httpCache.middleware, app.loopback.rest())

  try
    file  = frontend_path + '/index.html'
    index = require('fs').readFileSync(file).toString()
  catch
    index = 'DUDE!'

  serveIndex = (req, res, next) -> res.send index

  ['/:user/:repo', '/index/:letter?', '/colophon'].forEach (route) ->
    app.get route, serveIndex



staticFiles = (app) ->
  options =
    maxAge: 20000

  app.use serveStatic(frontend_path, options)



notifications = (app) ->
  notifier = new Notifier(app)
  router = NotifierRouter(app)

  router.mailer = new Mailer(config)

  app.post '/notify_users', (req, res, next) ->
    unless req.query.access_token == config.INTERNAL_URL_TOKEN
      return res.status(401).end()

    router.process_batch (req.query.batch ? 10)
    res.end()


  ['unsuscribe', 'subscription'].forEach (r) ->

    app.get '/' + r, (req, res, next) ->

      router[r] req.query
      .then (html) ->
        res.send html

      .catch (e) ->
        logger.error e

        res
        .status 500
        .send 'Something went wrong, please get in touch with us'


  app.models.Comment.observe 'after save', (ctx, next) ->
    return next() if ctx.instance.notified

    notifier.register_comment ctx.instance
    next()


loadFixtures = (app) ->
  ['GithubRepo', 'GithubUser', 'Comment'].forEach (modelName) ->
    fixture = require '../../test/fixtures/' + modelName.toLowerCase() + '-fixture'
    model = app.models[modelName]

    fixture.forEach (obj) -> model.create obj


module.exports = (app) ->

  promisifyAlltheThings app
  initLogs app
  enableOAuth app
  staticFiles app
  dudeRoutes  app
  notifications app
  httpCache.cache app

  if 'with-fixtures' in process.argv and app.get 'isDev'
    loadFixtures app

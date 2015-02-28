loopback = require 'loopback'
boot = require 'loopback-boot'


app = module.exports = loopback()
env = process.env.NODE_ENV ? 'development'
app.set 'env', env
app.set 'isDev', (env in ['development', 'test'])

# Bootstrap the application, configure models, datasources and middleware.
# Sub-apps like REST API are mounted via boot scripts.
boot(app, __dirname)

app.start = ->
  # start the web server
  app.listen ->
    app.emit('started')
    console.log 'Web server listening at: %s', app.get('url')

# start the server if `$ node server.js`
app.start() if require.main == module


cache = require 'memory-cache'

module.exports =

  cache: (app) ->

    app.remotes().after '**', (ctx, next) ->
      status = ctx.res.statusCode
      return next() unless status >= 200 and status < 205

      if ctx.req.method == 'GET'
        cache.put ctx.req.originalUrl, ctx.result
      else
        cache.clear()

      next()


  middleware: (req, res, next) ->
    return next() unless req.method == 'GET'

    hit = cache.get req.originalUrl
    return next() unless hit

    res.send hit

Promise = require 'bluebird'

app = require('./server/server')
dataSource = app.dataSources.db

ds = Promise.promisifyAll dataSource

list = Object.keys(app.models).map (item) ->
  ds.autoupdateAsync item

Promise.settle list
.then ->
  console.log 'Migration completed'
  process.exit 0
.catch (e) -> console.log e

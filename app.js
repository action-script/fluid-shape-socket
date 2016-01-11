var express = require('express')
var app = express()

var config = require('./global_config')

// server
var server = app.listen(config.server.port, function() {
   var host = server.address().address
   var port = server.address().port
   console.log('App listening at http://%s:%s', host, port)
})

app.get('/', function (req, res) {
   res.send('Hello World!')
})

app.get('/view', function(req, res) {
  res.sendFile(__dirname + '/public/view.html')
})

app.get('/*.(js|css|png|jpg)', function(req, res) {
    res.sendFile(__dirname + "/public" + req.url)
})


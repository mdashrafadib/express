'use strict'

var express = require('../../');

var app = module.exports = express()

app.get('/', function(req, res){
  res.send('Hello World');
});

/* istanbul ignore next */
if (!module.parent) {
  app.listen(80);
  console.log('Express started on port 80');
}

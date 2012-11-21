var express = require('express');
var app = express();
var server = require('http').createServer(app)
var io = require('socket.io').listen(server);
// NGINIX HACK (forcing socket.io in xhr-polling mode)
io.configure(function() {
  io.set("transports", ["xhr-polling"]);
  io.set("polling duration", 10);
  
  var path = require('path');
  var HTTPPolling = require(path.join(
    path.dirname(require.resolve('socket.io')),'lib', 'transports','http-polling')
  );
  var XHRPolling = require(path.join(
    path.dirname(require.resolve('socket.io')),'lib','transports','xhr-polling')
  );
  
  XHRPolling.prototype.doWrite = function(data) {
    HTTPPolling.prototype.doWrite.call(this);
    
    var headers = {
      'Content-Type': 'text/plain; charset=UTF-8',
      'Content-Length': (data && Buffer.byteLength(data)) || 0
    };
    
    if (this.req.headers.origin) {
      headers['Access-Control-Allow-Origin'] = '*';
      if (this.req.headers.cookie) {
        headers['Access-Control-Allow-Credentials'] = 'true';
      }
    }
    
    this.response.writeHead(200, headers);
    this.response.write(data);
    this.log.debug(this.name + ' writing', data);
  };
});

var PUBLIC_DIR = "static";

app.use(express.static(PUBLIC_DIR));
app.use(express.bodyParser());

var mongoose = require('mongoose');
var db = mongoose.createConnection('localhost', 'hci-sync');

// S C H E M A 
var sessionSchema = mongoose.Schema({
  date: Date,
  gameMode: String,
	taps: [mongoose.Schema.Types.Mixed]
});
var Session = db.model('Session', sessionSchema);

// A P P 
app.get('/', function(req, res){
	res.sendfile(PUBLIC_DIR + '/index.html');
});


app.post('/sessions', function (req, res){
	var s = new Session(req.params.taps);
  s.date = new Date;
	s.save();
	io.sockets.emit('session-added', s);
	res.send({error: false});
});

app.post('/sessions/new', function (req, res){
	var s = new Session();
  s.date = new Date;
  s.gameMode = req.body.gameMode || "";
	s.save();
	io.sockets.emit('session-added', s);
	res.send(s);
});

app.post('/sessions/:id/taps/new', function (req, res){
	Session.findOne({_id: req.params.id}, function (err, obj) {
		obj.taps.push({time: req.body.time});
		obj.save();
		res.send(obj);
		io.sockets.emit('tapped', obj);
	});
});

server.listen(4567);
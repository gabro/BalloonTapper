var express = require('express');
var app = express();
var server = require('http').createServer(app)
var io = require('socket.io').listen(server);
var PUBLIC_DIR = "static";

app.use(express.static(PUBLIC_DIR));
app.use(express.bodyParser());

var mongoose = require('mongoose');
var db = mongoose.createConnection('localhost', 'hci-sync');

var sockets = [];
var broadcast = function (type, msg) {
	for (var i = 0; i < sockets.length; i++) {
		sockets[i].emit(type, msg);
	}
}

io.sockets.on('connection', function (socket) {
  sockets.push(socket);
});

// S C H E M A 
var sessionSchema = mongoose.Schema({
	taps: [mongoose.Schema.Types.Mixed]
});
var Session = db.model('Session', sessionSchema);

// A P P 
app.get('/', function(req, res){
	res.sendfile(PUBLIC_DIR + '/index.html');
});


app.post('/sessions', function (req, res){
	var s = new Session(req.params.taps);
	s.save();
	broadcast('session-added', s);
	res.send({error: false});
});

app.post('/sessions/new', function (req, res){
	var s = new Session();
	s.save();
	broadcast('session-added', s);
	res.send(s);
});

app.post('/sessions/:id/taps/new', function (req, res){
	Session.findOne({_id: req.params.id}, function (err, obj) {
		obj.taps.push({time: req.body.time});
		obj.save();
		res.send(obj);
		broadcast('tapped', obj);
	});
});

server.listen(4567);
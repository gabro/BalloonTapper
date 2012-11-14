var express = require('express');
var app = express();
var server = require('http').createServer(app)
var io = require('socket.io').listen(server);
var PUBLIC_DIR = "static";

app.use(express.static(PUBLIC_DIR));

var mongoose = require('mongoose');
var db = mongoose.createConnection('localhost', 'hci-sync');

// S C H E M A 
var sessionSchema = mongoose.Schema({
	id: String,
	taps: [{id: String, time: Number}]
});
var Session = db.model('Session', sessionSchema);

// A P P 
app.get('/', function(req, res){
	res.sendfile(PUBLIC_DIR + '/index.html');
});


app.post('/session', function (req, res){
	var s = new Session(req.params.taps);
	s.save();
	io.sockets.emit('session-added', s);
	res.send({error: false});
});

server.listen(3000);
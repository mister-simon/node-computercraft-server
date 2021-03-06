require('dot-env');

var fs = require('fs');

var serveIndex = require('serve-index'),
	express = require('express'),
	path = require('path'),
	app = express();

	
app.use('/scripts', express.static(path.join(__dirname, 'scripts')));

app.get('/listing/lua', function(req, res){
	var files = [],
		stringyFiles = "";

	checkFolder('scripts', files);

	stringyFiles = JSON.stringify(files).replace('[', '{').replace(']', '}');

	res.send(stringyFiles);
});

app.listen(process.env.PORT || 8888, function () {
	console.log('WE GO NOW');
});


function checkFolder(path, output){
	if(fs.statSync(path).isDirectory()){
		var contents = fs.readdirSync(path);

		for (var i = 0, l = contents.length; i < l; i++) {
			checkFolder(path+'/'+contents[i], output);
		}
	} else {
		output.push(path);
	}
}
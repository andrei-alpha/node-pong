filesys = require 'fs'
haml = require 'haml'
path = require 'path'
express = require 'express'
assets = require 'connect-assets'
sys = require 'sys'
exec = require 'child_process'
#jade = require 'jade'

#compile all coffee files
exec.exec "python compile.py", null

app = express()
#app.set "views", __dirname + "/views"
#app.set "view engine", "jade"
#app.use express.favicon()
#app.use express.errorHandler()
#app.use express.bodyParser()
app.use express.static( __dirname + '//static')
app.use assets()

load_file = (my_path, res) ->
	full_path = path.join(process.cwd(), my_path);
	filesys.exists full_path, (exists) ->
		if not exists
			res.end "Hello there!"
		else
			res.sendFile full_path

app.get '/*', (req, res) ->
	load_file req.path, res

port = process.env.PORT or 5000
app.listen(port)

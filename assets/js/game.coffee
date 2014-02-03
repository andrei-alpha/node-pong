R = null

Raphael.fn.ball = (uid, pos, dir) ->
	ball = @ellipse(pos.x, pos.y, 20, 20).attr(
		stroke: "none"
		fill: "r(.01,.02) red-black"
	)

	ball.uid = uid
	ball.dir = dir
	return ball


move = (ball) ->
	console.log ball

$(document).ready ->
	R = Raphael("main")
	
	pos = {'x': 500, 'y': 500}
	dir = {'x': -10, 'y': 12}

	ball = R.ball(10, pos, dir)
	move(ball)

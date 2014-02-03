R = null
frames = 50
eps = 0
Wx = $(window).width()
Wy = $(window).height()
rectangles = []

Raphael.fn.ball = (uid, pos, dir) ->
	ball = @ellipse(pos.x, pos.y, 20, 20).attr(
		stroke: "none"
		fill: "r(.01,.02) red-black"
	)

	ball.r = 20
	ball.uid = uid
	ball.dir = dir
	ball.pos = pos
	return ball

Raphael.fn.line = (uid, pos) ->
	rect = @rect(pos[0], pos[1], pos[2], pos[3], 10).attr(
		stroke: "none"
		fill: "grey"
	)
	return rect

colide = (r, ball) ->
	p = [r[0], r[1], r[2], r[1], r[2], r[3], r[0], r[3]]
	dir = ball.dir
	res = PolyK.Raycast(p, ball.pos.x, ball.pos.y, dir.x, dir.y)
	stepDist = Math.sqrt(dir.x * dir.x + dir.y * dir.y)
	
	if res? and res.dist <= stepDist + ball.r + eps
		rate = (stepDist + ball.r + eps - res.dist) / stepDist
		ball.pos.x += dir.x * rate * -1
		ball.pos.y += dir.y * rate * -1
		switch res.edge
			when 0 then dir.y *= -1
			when 1 then dir.x *= -1
			when 2 then dir.y *= -1
			when 3 then dir.x *= -1
			when 4 then dir.x *= -1
			else console.log "error on edge detection", res.edge

move = (ball) ->
	ball.pos = (
		x: ball.pos.x + ball.dir.x
		y: ball.pos.y + ball.dir.y 
	)	

	for rect in rectangles
		colide rect, ball

	ball.attr(
		cx: ball.pos.x
		cy: ball.pos.y
	)
	setTimeout (-> move ball), 1000 / frames

$(document).ready ->
	R = Raphael("main")
	rectangles.push [0, 0, Wx, 0]
	rectangles.push [0, 0, 0, Wy]
	rectangles.push [Wx, 0, Wx, Wy]
	rectangles.push [0, Wy, Wx, Wy]
	
	i = 0
	while i <= 30
		type = parseInt Math.random() * 100
		x1 = parseInt Math.random() * Wx / 10 * i
		y1 = parseInt Math.random() * Wy / 10 * i
		len = parseInt Math.random() * 200 + 200
		if type <= 50
			cord = [x1, y1, 10, len]
			rectangles.push([x1, y1, x1 + 10, y1 + len])
		else
			cord = [x1, y1, len, 10]
			rectangles.push([x1, y1, x1 + len, y1 + 10])
		rect = R.line(10, cord)
		++i

	pos = {'x': 500, 'y': 500}
	dir = {'x': -7, 'y': 6}
	ball = R.ball(10, pos, dir)
	move ball


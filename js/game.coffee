R = null
frames = 50
Wx = $(window).width()
Wy = $(window).height()
rectangles = []
circle = null
pads = []
eps = 0

Raphael.fn.ball = (uid, pos, dir) ->
	ball = @ellipse(pos.x, pos.y, 10, 10).attr(
		stroke: "none"
		fill: "r(.01,.02) red-black"
	)

	ball.r = 10
	ball.uid = uid
	ball.dir = dir
	ball.pos = pos
	return ball

Raphael.fn.line = (uid, pos, ang, color) ->
	rect = @rect(pos[0], pos[1], pos[2], pos[3], 4).attr(
		stroke: "none"
		fill: color
	)
	rect.rotate(ang, pos[0], pos[1])
	return rect

addPad = (ix1, iy1, ix2, iy2) ->
	# srink pad
	x1 = ix1 + (ix2 - ix1) / 2.9
	x2 = ix2 + (ix1 - ix2) / 2.9
	y1 = iy1 + (iy2 - iy1) / 2.9
	y2 = iy2 + (iy1 - iy2) / 2.9

	ang = Math.atan2(y2 - y1, x2 - x1) / Math.PI * 180
	dist = Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))

	pad = R.line(1, [x1, y1, dist, 10], ang, "red")
	pad.rect = [x1, y1, x1, y1, x2, y2, x2, y2]
	pad.outer = [ix1, iy1, ix2, iy2]
	pad.track = getTrack ix1, iy1, ix2, iy2, x1, y1, x2, y2
	pad._score = 0

	norm = vectorReverse vectorNorm [ix2 - ix1, iy2 - iy1]
	pad.score = R.text(ix1 + norm[0] * 10, iy1 + norm[1] * 10, pad._score)

	# use a range [0, 100] for each position on the track
	pad.pos = 50
	pads.push pad

addRectangle = (x1, y1, x2, y2) ->
	rectangles.push([x1, y1, x1, y1, x2, y2, x2, y2])
	ang = Math.atan2(y2 - y1, x2 - x1) / Math.PI * 180
	dist = Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))

	#console.log 'ang', ang, 'line', x1, y1, x2, y2, dist, 10

	line = R.line(1, [x1, y1, dist, 10], ang, 'grey')

colide = (rect, ball) ->
	dir = ball.dir
	expRect = expandPoly rect, ball.r
	res = PolyK.Raycast(expRect, ball.pos.x, ball.pos.y, dir.x, dir.y)
	stepDist = Math.sqrt(dir.x * dir.x + dir.y * dir.y)
	
	if res? and res.dist <= stepDist + ball.r + eps
		rate = (stepDist + ball.r + eps - res.dist) / stepDist
		line = [rect[res.edge % (rect.length / 2)], rect[res.edge % (rect.length / 2) + 1]]
		vec = vectorReflect [dir.x, dir.y], [res.norm.x, res.norm.y], line
		dir.x = vec[0]
		dir.y = vec[1]

		# update position
		ball.pos.x += dir.x * rate * -1
		ball.pos.y += dir.y * rate * -1
		return true
	return false

updateScore = (bpos) ->
	loser = {'pad': null, 'dist': 999999}

	for pad in pads
		d1 = distance bpos.x, bpos.y, pad.outer[0], pad.outer[1]
		d2 = distance bpos.x, bpos.y, pad.outer[2], pad.outer[3]

		if (Math.min d1, d2) < loser.dist
			loser.pad = pad
			loser.dist = Math.min d1, d2
	loser.pad._score += 1
	loser.pad.score.attr('text', loser.pad._score)

lastT = 0
move = (ball) ->
	# If is out of the board remove
	if (distance ball.pos.x, ball.pos.y, circle.cx, circle.cy) > circle.rad
		updateScore ball.pos
		ball.remove()
		initBall()
		return

	# If it colides update position
	hit = false
	for rect in rectangles
		hit |= colide rect, ball
	for pad in pads
		if colide pad.rect, ball
			# increase the ball speed
			ball.dir.x *= 1.05
			ball.dir.y *= 1.05

			# glow pad
			glow = pad.glow()
			setTimeout (-> 
				for elem in glow 
					elem.remove()
			), 100
			hit = true

	# Else continue moving
	if not hit
		ball.pos = (
			x: ball.pos.x + ball.dir.x
			y: ball.pos.y + ball.dir.y 
		)
	ball.attr(
		cx: ball.pos.x
		cy: ball.pos.y
	)

	# Move each pad in a smart way
	for pad  in pads
		movePad pad, ball
	
	lastT = setTimeout (-> move ball), 1000 / frames

@stop = ->
	console.log 'end simulation'
	clearTimeout lastT

board = ->
	circle = (
		cx: Wx / 2
		cy: Wy / 2
		rad: Math.min(Wx / 2, Wy / 2) - 50 
	)
	angs = [270, 342, 54, 126, 198, 270].map (ang) -> ang * Math.PI / 180
	polys = angs.map (ang) -> pointOnCircle circle.rad, ang, circle.cx, circle.cy  
	#console.log 'polys', polys

	for p1, i in polys when i < polys.length - 1
		p2 = polys[i + 1]

		[x1, y1, x2, y2] = [p1[0], p1[1], p2[0], p2[1]]
		[sx, sy] = [(x2 - x1) / 5, (y2 - y1) / 5]
		pts = [0, 1, 4, 5].map (x) -> [x1 + sx * x, y1 + sy * x]
		pts = [].concat pts...

		addRectangle pts[0], pts[1], pts[2], pts[3]
		addPad pts[2], pts[3], pts[4], pts[5]
		addRectangle pts[4], pts[5], pts[6], pts[7]

initBall = ->
	# Give ball random direction
	mag2 = Math.min(Wx, Wy) / 10
	sx = Math.random() * (mag2 / 2) + mag2 / 4 
	sy = mag2 - sx
	sx = Math.sqrt(sx)
	sy = Math.sqrt(sy)
	if Math.random() < 0.5
		sx *= -1
	if Math.random() < 0.5
		sy *= 1

	pos = {'x': Wx / 2, 'y': Wy / 2}
	dir = {'x': sx, 'y': sy}
	ball = R.ball(10, pos, dir)

	# start moving the
	setTimeout (-> move ball), 1000

$(document).ready ->
	R = Raphael("main")
	board()
	initBall()
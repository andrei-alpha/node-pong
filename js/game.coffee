R = null
frames = 50
Wx = $(window).width()
Wy = $(window).height()
rectangles = []
pads = []
eps = 0

Raphael.fn.ball = (uid, pos, dir) ->
	ball = @ellipse(pos.x, pos.y, 15, 15).attr(
		stroke: "none"
		fill: "r(.01,.02) red-black"
	)

	ball.r = 20
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
	x1 = ix1 + (ix2 - ix1) / 3
	x2 = ix2 + (ix1 - ix2) / 3
	y1 = iy1 + (iy2 - iy1) / 3
	y2 = iy2 + (iy1 - iy2) / 3

	ang = Math.atan2(y2 - y1, x2 - x1) / Math.PI * 180
	dist = Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))

	pad = R.line(1, [x1, y1, dist, 10], ang, 'red')
	pad.rect = [x1, y1, x1, y1, x2, y2, x2, y2]
	pad.outer = [ix1, iy1, ix2, iy2]
	pad.track = getTrack ix1, iy1, ix2, iy2, x1, y1, x2, y2

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

lastT = 0

move = (ball) ->
	# If it colides update position
	hit = false
	for rect in rectangles
		hit |= colide rect, ball
	for pad in pads
		hit |= colide pad.rect, ball

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
	rectangles.push [0, 0, Wx, 0]
	rectangles.push [0, 0, 0, Wy]
	rectangles.push [Wx, 0, Wx, Wy]
	rectangles.push [0, Wy, Wx, Wy]

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
	mag2 = 85
	sx = Math.random() * (mag2 / 2) + mag2 / 4 
	sy = mag2 - sx
	sx = Math.sqrt(sx)
	sy = Math.sqrt(sy)
	if Math.random() < 0.5
		sx *= -1
	if Math.random() < 0.5
		sy *= 1

	console.log 'ball speed', sx, sy

	pos = {'x': Wx / 2, 'y': Wy / 2}
	dir = {'x': sx, 'y': sy}
	return R.ball(10, pos, dir)

$(document).ready ->
	R = Raphael("main")
	board()

	ball = initBall()
	move ball
maxSpeed = 8

@getTrack = (ix1, iy1, ix2, iy2, x1, y1, x2, y2) ->
	# srink the track to actual movable place, eg - pad size
	ix1 += (x2 - x1) / 2
	ix2 += (x1 - x2) / 2
	iy1 += (y2 - y1) / 2 
	iy2 += (y1 - y2) / 2

	return [ix1, iy1, ix2, iy2]
	#[(Math.min ix1, ix2), (Math.max ix1, ix2)], 
	#	[(Math.min iy1, iy2), (Math.max iy1, iy2)]]

@movePad = (pad, ball) ->
	expRect = expandPoly pad.outer, ball.r
	res = PolyK.Raycast(expRect, ball.pos.x, ball.pos.y, ball.dir.x, ball.dir.y)

	# don't move pad if the ball won't hit it
	if not res?
		return

	point = pointOnLineAtDist [ball.dir.x, ball.dir.y], res.dist, ball.pos.x, ball.pos.y
	# the point is expected to be on the pad line, so we can check by x only
	point[0] = putInRange point[0], Math.min(pad.track[0], pad.track[2]),
		Math.max(pad.track[0], pad.track[2])
	hitPos = mod (point[0] - pad.track[0]) / ((pad.track[2] - pad.track[0]) / 100)

	move = putInRange hitPos - pad.pos, -maxSpeed, maxSpeed
	
	if move is 0
		if Math.random() < 0.8
			return
		move = Math.random() * 4 - 2
		move = putInRange move, 0, Math.min(pad.pos, 100 - pad.pos)

	pad.pos += move
	mx = (pad.track[2] - pad.track[0]) / 100 * move
	my = (pad.track[3] - pad.track[1]) / 100 * move

	#console.log 'padHit', hitPos, 'pos', pad.pos, 'move', move, 
	#	'point', point, 'outer', pad.outer, 'move', mx, my

	# move pad polygon and rotate drawing
	pad.rect = polyTranslate pad.rect, mx, my
	pad.transform '...T' + mx + ',' + my
	#console.log 'after', pad.rect, 'track', pad.track	
@vectorReflect = (vec, norm, line) ->
	uvec = unitVector vec
	magv = magnitude vec
	unorm = unitVector norm
	c1 = -dotProduct uvec, unorm

	temp = unorm
	temp = temp.map (elem) -> elem * 2 * c1

	ret = []
	for elem in zip(uvec, temp)
		ret.push elem[0] + elem[1]
	ret = ret.map (x) -> x * magv
	#console.log 'vec', vec, 'unorm', norm, 'line', line, 'dot', c1, 'mag', magv, 'return', ret

	return ret

@pointOnCircle = (rad, ang, cx, cy) ->
	return [cx + rad * Math.cos(ang), cy + rad * Math.sin(ang)]

magnitude = (vec) ->
	return Math.sqrt (vec.map (x) -> x * x).reduce (x, y) -> x + y

unitVector = (vec) ->
	return vec.map (x) -> x / magnitude vec

dotProduct = (uvec1, uvec2) ->
	ret = []
	for elem in zip(uvec1, uvec2)
		ret.push elem[0] * elem[1]
	return ret.reduce (x, y) -> x + y

zip = (arr1, arr2) ->
  basic_zip = (el1, el2) -> [el1, el2]
  zipWith basic_zip, arr1, arr2

zipWith = (func, arr1, arr2) ->
  min = Math.min arr1.length, arr2.length
  ret = []

  for i in [0...min]
    ret.push func(arr1[i], arr2[i])
  return ret

for (var i = 0; i < sprite_get_number(spr); i++) {
	var _scl = 2
	var _x = 32 * _scl
	var _y = 32 * _scl
	var _sep = sprite_get_width(spr) * _scl + _x
	draw_sprite_ext(spr, i, _x + i * _sep, _y, _scl, _scl, 0, -1, 1)
}


var _scl = 16
var _mat1 = matrix_build(0, 0, 0, 0, 0, current_time/20, _scl, _scl, _scl)
var _mat2 = matrix_build(room_width/2, room_height/2, 0, 60, 0, 0, 1, 1, 1)
matrix_set(matrix_world, matrix_multiply(_mat1, _mat2))

draw_voxel(player)

matrix_set(matrix_world, matrix_build_identity())


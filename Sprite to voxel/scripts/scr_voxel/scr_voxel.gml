
function sprite_to_voxel(_sprite, _from_bottom = true, _xalign = 0.5, _yalign = 0.5, _zalign = 1){
	
	// Internal functions
	static __vertex_add = function(_vb, _x, _y, _z, _col, _alpha, _nx, _ny, _nz) {
		vertex_position_3d(_vb, _x, _y, _z);
		vertex_normal(_vb, _nx, _ny, _nz);
		vertex_color(_vb, _col, _alpha);
	}
	
	static __pos_to_index = function(_wid, _hei, _x, _y, _z) {
		return _x + _y * _wid + _z * (_wid * _hei);
	}	
	
	// Get sprite info
	var _wid		= sprite_get_width(_sprite);
	var _hei		= sprite_get_height(_sprite);
	var _frames		= sprite_get_number(_sprite);
	var _spr_xoff	= sprite_get_xoffset(_sprite);
	var _spr_yoff	= sprite_get_yoffset(_sprite);
	
	var _size		= buffer_sizeof(buffer_u32);
	var _frame_size	= _wid * _hei * _size;
	var _buff_size	= _frame_size * _frames;
	var _surf		= surface_create(_wid, _hei);
	var _buffer		= buffer_create(_buff_size, buffer_fixed, 1);
	buffer_fill(_buffer, 0, _size, 0, _buff_size);
	
	
	// Fill buffer data
	for (var i = 0; i < _frames; i++) {
		surface_set_target(_surf);
			draw_clear_alpha(c_black, 0);
			var _frame = abs(((_from_bottom * _frames) - _from_bottom) - i)
			draw_sprite(_sprite, _frame, _spr_xoff, _spr_yoff);
		surface_reset_target();
		buffer_get_surface(_buffer, _surf, _frame_size * i);
	}
	surface_free(_surf);
	buffer_seek(_buffer, buffer_seek_start, 0);	

	// Vertex format
	vertex_format_begin();
	vertex_format_add_position_3d();
	vertex_format_add_normal();
	vertex_format_add_color();
	var _vform = vertex_format_end();
	
	// Vertex model
	var _vbuffer = vertex_create_buffer();	
	vertex_begin(_vbuffer, _vform);
	
	var _culltest = array_create(6)
	for (var i = 0; i < _wid * _hei * _frames; i++) {
		
		var _pixel	= buffer_read(_buffer, buffer_u32);
		var _col	= _pixel & 0xFFFFFF;
		var _a		= ((_pixel >> 24) & 0xFF) > 0.0;
		if (!_a) continue;
		
		var _x	= i mod _wid;
		var _y	= (i div _wid) mod _hei;
		var _z	= (i div (_wid * _hei)) mod _frames;
		var _n	= 1;
		
		// Face culling test		
		for (var j = 0; j < 6; j++) {
		    var _check_x = _x;
		    var _check_y = _y;
		    var _check_z = _z;
    
		    switch (j) {
		        case 0: _check_x++; break;
		        case 1: _check_x--; break;
		        case 2: _check_y++; break;
		        case 3: _check_y--; break;
		        case 4: _check_z++; break;
		        case 5: _check_z--; break;
		    }
    
		    if (_check_x < 0 || _check_x >= _wid ||
		        _check_y < 0 || _check_y >= _hei ||
		        _check_z < 0 || _check_z >= _frames) {
		        _culltest[j] = true;
		    } else {
		        var _peek_value = buffer_peek(_buffer, __pos_to_index(_wid, _hei, _check_x, _check_y, _check_z) * _size, buffer_u32);
		        _culltest[j] = ((_peek_value >> 24) & 0xFF) == 0.0;
		    }
		}
			
		_x -= _wid*_xalign;
		_y -= _hei*_yalign;
		_z -= _frames*_zalign	
		
		// X+
		if (_culltest[0]) {
			__vertex_add(_vbuffer,	_x+_n,	_y+_n,	_z,		_col, _a, 1, 0, 0);
			__vertex_add(_vbuffer,	_x+_n,	_y+_n,	_z+_n,	_col, _a, 1, 0, 0);
			__vertex_add(_vbuffer,	_x+_n,	_y,		_z+_n,	_col, _a, 1, 0, 0);
			__vertex_add(_vbuffer,	_x+_n,	_y,		_z+_n,	_col, _a, 1, 0, 0);
			__vertex_add(_vbuffer,	_x+_n,	_y,		_z,		_col, _a, 1, 0, 0);
			__vertex_add(_vbuffer,	_x+_n,	_y+_n,	_z,		_col, _a, 1, 0, 0);
		}
		
		// X-
		if (_culltest[1]) {
			__vertex_add(_vbuffer,	_x,		_y,		_z,		_col, _a, -1, 0, 0);
			__vertex_add(_vbuffer,	_x,		_y,		_z+_n,	_col, _a, -1, 0, 0);
			__vertex_add(_vbuffer,	_x,		_y+_n,	_z+_n,	_col, _a, -1, 0, 0);
			__vertex_add(_vbuffer,	_x,		_y+_n,	_z+_n,	_col, _a, -1, 0, 0);
			__vertex_add(_vbuffer,	_x,		_y+_n,	_z,		_col, _a, -1, 0, 0);
			__vertex_add(_vbuffer,	_x,		_y,		_z,		_col, _a, -1, 0, 0);
		}
		
		// Y+
		if (_culltest[2]) {
			__vertex_add(_vbuffer,	_x,		_y+_n,	_z,		_col, _a, 0, 1, 0);
			__vertex_add(_vbuffer,	_x,		_y+_n,	_z+_n,	_col, _a, 0, 1, 0);
			__vertex_add(_vbuffer,	_x+_n,	_y+_n,	_z+_n,	_col, _a, 0, 1, 0);
			__vertex_add(_vbuffer,	_x+_n,	_y+_n,	_z+_n,	_col, _a, 0, 1, 0);
			__vertex_add(_vbuffer,	_x+_n,	_y+_n,	_z,		_col, _a, 0, 1, 0);
			__vertex_add(_vbuffer,	_x,		_y+_n,	_z,		_col, _a, 0, 1, 0);
		}
		
		// Y-
		if (_culltest[3]) {
			__vertex_add(_vbuffer,	_x+_n,	_y,		_z,		_col, _a, 0, -1, 0);
			__vertex_add(_vbuffer,	_x+_n,	_y,		_z+_n,	_col, _a, 0, -1, 0);
			__vertex_add(_vbuffer,	_x,		_y,		_z+_n,	_col, _a, 0, -1, 0);
			__vertex_add(_vbuffer,	_x,		_y,		_z+_n,	_col, _a, 0, -1, 0);
			__vertex_add(_vbuffer,	_x,		_y,		_z,		_col, _a, 0, -1, 0);
			__vertex_add(_vbuffer,	_x+_n,	_y,		_z,		_col, _a, 0, -1, 0);
		}
		
		// Z+
		if (_culltest[4]) {
			__vertex_add(_vbuffer,	_x,		_y+_n,	_z+_n,	_col, _a, 0, 0, 1);
			__vertex_add(_vbuffer,	_x,		_y,		_z+_n,	_col, _a, 0, 0, 1);
			__vertex_add(_vbuffer,	_x+_n,	_y,		_z+_n,	_col, _a, 0, 0, 1);
			__vertex_add(_vbuffer,	_x+_n,	_y,		_z+_n,	_col, _a, 0, 0, 1);
			__vertex_add(_vbuffer,	_x+_n,	_y+_n,	_z+_n,	_col, _a, 0, 0, 1);
			__vertex_add(_vbuffer,	_x,		_y+_n,	_z+_n,	_col, _a, 0, 0, 1);
		}
		
		// Z-
		if (_culltest[5]) {
			__vertex_add(_vbuffer,	_x,		_y,		_z,		_col, _a, 0, 0, -1);
			__vertex_add(_vbuffer,	_x,		_y+_n,	_z,		_col, _a, 0, 0, -1);
			__vertex_add(_vbuffer,	_x+_n,	_y,		_z,		_col, _a, 0, 0, -1);
			__vertex_add(_vbuffer,	_x+_n,	_y,		_z,		_col, _a, 0, 0, -1);
			__vertex_add(_vbuffer,	_x,		_y+_n,	_z,		_col, _a, 0, 0, -1);
			__vertex_add(_vbuffer,	_x+_n,	_y+_n,	_z,		_col, _a, 0, 0, -1);
		}
	}
	
	vertex_end(_vbuffer);
	vertex_freeze(_vbuffer);
	buffer_delete(_buffer);
	
	return _vbuffer;
}

function draw_voxel(_voxel) {
	var _ztest = gpu_get_ztestenable()
	var _zwrite	= gpu_get_zwriteenable()
	
	gpu_set_ztestenable(true)
	gpu_set_zwriteenable(true)
	
	shader_set(shd_voxel)
	vertex_submit(_voxel, pr_trianglelist, -1)
	shader_reset()
	
	gpu_set_ztestenable(_ztest)
	gpu_set_zwriteenable(_zwrite)
}













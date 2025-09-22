// GameUtils.gml - Utility functions converted from TypeScript

// Math utility functions
function clamp_value(_value, _min, _max) {
    return max(_min, min(_max, _value));
}

function lerp_value(_a, _b, _t) {
    return _a + (_b - _a) * _t;
}

// Vector2 utility functions
function vector2_length(_vector) {
    return sqrt(_vector.x * _vector.x + _vector.y * _vector.y);
}

function vector2_normalize(_vector) {
    var _len = vector2_length(_vector);
    if (_len == 0) _len = 1;
    return Vector2(_vector.x / _len, _vector.y / _len);
}

function vector2_scale(_vector, _scalar) {
    return Vector2(_vector.x * _scalar, _vector.y * _scalar);
}

function vector2_add(_a, _b) {
    return Vector2(_a.x + _b.x, _a.y + _b.y);
}

function vector2_subtract(_a, _b) {
    return Vector2(_a.x - _b.x, _a.y - _b.y);
}

function vector2_distance_sq(_a, _b) {
    var _dx = _a.x - _b.x;
    var _dy = _a.y - _b.y;
    return _dx * _dx + _dy * _dy;
}

function vector2_distance(_a, _b) {
    return sqrt(vector2_distance_sq(_a, _b));
}

function vector2_distance_to_segment_sq(_point, _a, _b) {
    var _abx = _b.x - _a.x;
    var _aby = _b.y - _a.y;
    var _apx = _point.x - _a.x;
    var _apy = _point.y - _a.y;
    var _ab_len_sq = _abx * _abx + _aby * _aby;

    if (_ab_len_sq == 0) {
        return vector2_distance_sq(_point, _a);
    }

    var _t = (_apx * _abx + _apy * _aby) / _ab_len_sq;
    _t = clamp_value(_t, 0, 1);
    var _closest_x = _a.x + _abx * _t;
    var _closest_y = _a.y + _aby * _t;
    var _dx = _point.x - _closest_x;
    var _dy = _point.y - _closest_y;
    return _dx * _dx + _dy * _dy;
}

function random_range_value(_min, _max) {
    return random(_max - _min) + _min;
}

// Color utility functions
function rgba_color(_r, _g, _b, _alpha) {
    return make_color_rgb(_r, _g, _b);
}

function rgba_string(_color_array, _alpha) {
    // In GameMaker, we'll use make_color_rgb and set alpha separately
    return make_color_rgb(_color_array[0], _color_array[1], _color_array[2]);
}

// Easing functions
function ease_out_cubic(_t) {
    var _clamped = clamp_value(_t, 0, 1);
    return 1 - power(1 - _clamped, 3);
}

function ease_in_out_cubic(_t) {
    var _clamped = clamp_value(_t, 0, 1);
    if (_clamped < 0.5) {
        return 4 * _clamped * _clamped * _clamped;
    }
    return 1 - power(-2 * _clamped + 2, 3) / 2;
}

// Lane conversion utility
function lane_to_world(_lane, _room_width) {
    var _lanes = 6;
    var _padding = 120;
    var _usable_width = _room_width - _padding * 2;
    var _step = _usable_width / (_lanes - 1);
    return Vector2(_padding + _step * (_lane - 1), -60);
}

// Performance profile detection
function detect_performance_profile() {
    // Simplified for GameMaker - assume decent performance
    return {
        isMobile: false,
        particleMultiplier: 1,
        floatingTextLimit: 80,
        enableShadows: true,
        backgroundDensity: 1,
        enableBackgroundRibbons: true,
        maxParticles: 600
    };
}

// Array utility functions
function array_contains(_array, _value) {
    for (var _i = 0; _i < array_length(_array); _i++) {
        if (_array[_i] == _value) {
            return true;
        }
    }
    return false;
}

function array_remove_value(_array, _value) {
    for (var _i = 0; _i < array_length(_array); _i++) {
        if (_array[_i] == _value) {
            array_delete(_array, _i, 1);
            return true;
        }
    }
    return false;
}
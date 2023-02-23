// NOTE: Shader automatically converted from Godot Engine 4.0.beta9's ParticleProcessMaterial.

shader_type particles;
render_mode collision_use_scale;
uniform float hue_variation_min;
uniform float hue_variation_max;
//uniform float lifetime_randomness;
uniform vec4 color_value : source_color;
uniform vec3 gravity;


uniform float anim_dur;
uniform vec2 camera_pos;
uniform vec3 emission_box_extents;

float rot_direction(vec2 from, vec2 to) {
  vec2 dir = to - from;
  return atan(-dir.y, dir.x);
}


vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(vec2(c, -s),vec2( s, c));
	return m * v;
}

float rand_from_seed(inout uint seed) {
	int k;
	int s = int(seed);
	if (s == 0)
	s = 305420679;
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0)
		s += 2147483647;
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

float rand_from_seed_m1_p1(inout uint seed) {
	return rand_from_seed(seed) * 2.0 - 1.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

void start() {
	uint base_number = NUMBER;
	uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED);
	float pi = 3.14159;
	float degree_to_rad = pi / 180.0;
	CUSTOM.y = 0.0;
	CUSTOM.x=rand_from_seed(alt_seed);
//	CUSTOM.w = (1.0 - lifetime_randomness * rand_from_seed(alt_seed));
//	CUSTOM.a=0.0;
	COLOR.a=0.0;
	COLOR.rgb=vec3(1.0);
//	COLOR.rgb=vec3(rand_from_seed(alt_seed),rand_from_seed(alt_seed),rand_from_seed(alt_seed));
	if (RESTART_POSITION) {
		TRANSFORM[0] = vec4(0.001);
		TRANSFORM[1] = vec4(0.00);
		TRANSFORM[2] = vec4(0.0);
		TRANSFORM[3].xyz = vec3(rand_from_seed(alt_seed) * 2.0 - 1.0, rand_from_seed(alt_seed) * 2.0 - 1.0, 0.0)*emission_box_extents;
		
		
	if (RESTART_VELOCITY) VELOCITY = (EMISSION_TRANSFORM * vec4(VELOCITY, 0.0)).xyz;
	TRANSFORM = EMISSION_TRANSFORM * TRANSFORM;
	}
	
	
	CUSTOM.s=TRANSFORM[3].x;
	TRANSFORM[3].z=TRANSFORM[3].y;
}

void process() {
	uint base_number = NUMBER;
	uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED);

	
	float pi = 3.14159;
	float degree_to_rad = pi / 180.0;
	
	float drop_dir=rot_direction(EMISSION_TRANSFORM[3].xy,TRANSFORM[3].xy);
	float drop_height=mod(-(clamp(CUSTOM.y+anim_dur,0.0,1.0)*(200.0/LIFETIME)),200);
	
	VELOCITY.xy=vec2(0.0,0.0);
	
	CUSTOM.z = (CUSTOM.y - (1.0 - anim_dur))/anim_dur;
	vec2 origin_point=vec2(CUSTOM.s,TRANSFORM[3].z);
	COLOR.a=clamp(COLOR.a+DELTA*20.0,0.0,0.5);
	float base_scale = 0.1;
	float y_scale = 1.0;
	if (CUSTOM.y==0.0){
		if (COLLIDED) {
			ACTIVE = false;
		}
	}
	if (CUSTOM.z<CUSTOM.y-(1.0-anim_dur-0.2)){
		y_scale=1.0;
		float dis=(distance(TRANSFORM[3].xy,EMISSION_TRANSFORM[3].xy));
		base_scale=(distance(TRANSFORM[3].xy,EMISSION_TRANSFORM[3].xy)/(150.0/LIFETIME))*(CUSTOM.y)+0.05;
		TRANSFORM[3].xy=origin_point+rotate(vec2((drop_height)*dis/(200.0/LIFETIME),0.0),drop_dir);
		
	}else{
		base_scale=1.0;
		drop_dir=CUSTOM.x;
		TRANSFORM[3].xy=origin_point;
	}
	vec3 tex_scale = vec3(1.0);
	float tex_hue_variation = 1.0;
	float hue_rot_angle = (tex_hue_variation) * pi * 2.0 * mix(hue_variation_min, hue_variation_max, rand_from_seed(alt_seed));
	float hue_rot_c = cos(hue_rot_angle);
	float hue_rot_s = sin(hue_rot_angle);
	mat4 hue_rot_mat = mat4(vec4(0.299, 0.587, 0.114, 0.0),
			vec4(0.299, 0.587, 0.114, 0.0),
			vec4(0.299, 0.587, 0.114, 0.0),
			vec4(0.000, 0.000, 0.000, 1.0)) +
		mat4(vec4(0.701, -0.587, -0.114, 0.0),
			vec4(-0.299, 0.413, -0.114, 0.0),
			vec4(-0.300, -0.588, 0.886, 0.0),
			vec4(0.000, 0.000, 0.000, 0.0)) * hue_rot_c +
		mat4(vec4(0.168, 0.330, -0.497, 0.0),
			vec4(-0.328, 0.035,  0.292, 0.0),
			vec4(1.250, -1.050, -0.203, 0.0),
			vec4(0.000, 0.000, 0.000, 0.0)) * hue_rot_s;
	
	
	base_scale = sign(base_scale) * max(abs(base_scale), 0.001);
	y_scale = sign(y_scale) * max(abs(y_scale), 0.001);
	TRANSFORM[0] = vec4(cos(drop_dir-PI), -sin(drop_dir-PI), 0.0, 0.0) * base_scale * sign(tex_scale.r) * max(abs(tex_scale.r), 0.001);
	TRANSFORM[1] = vec4(sin(drop_dir-PI), cos(drop_dir-PI), 0.0, 0.0)  * y_scale * sign(tex_scale.g) * max(abs(tex_scale.g), 0.001);
	TRANSFORM[2] = vec4(0.0, 0.0, 1.0, 0.0);
	
	CUSTOM.y += DELTA / LIFETIME;
	if (CUSTOM.y > 1.0) {
		ACTIVE = false;
	}
	
}


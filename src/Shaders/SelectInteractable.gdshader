shader_type spatial;
render_mode unshaded, shadows_disabled;

uniform vec3 color : source_color;
uniform float lines1:hint_range(0.0, 200.0, 1.0) = 24.0;
uniform float lines2:hint_range(0.0, 100.0, 1.0) = 2.0;
uniform float _emission: hint_range(0.0, 10.0) = 1.0;
uniform float _fresnel: hint_range(0.0, 10.0) = 1.0;

varying float rand_dist;

float random_static(float x){
	return fract(sin(x * 12.9898 + 78.233) * 43758.5453);
}

float random_anim(float x){
	return fract(sin(x * 12.9898 + 78.233) * 43758.5453 + sin(TIME * 0.1)) ;
}
 
//--- static noise
float random2_static (vec2 uv) {
  return fract(sin(dot(uv.xy,vec2(12.9898,78.233))) * 43758.5453123);
}
 
//--- animated noise
float random2_anim (vec2 uv) {
	return fract(sin(dot(uv.xy + vec2(sin(TIME), cos(TIME)), 
					  vec2(12.9898,78.233))) * 43758.5453123);
}
 
float fresnel(float amount, vec3 normal, vec3 view){
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}


void vertex() {
	float distortion = sin(TIME*10.0 + VERTEX.y*20.0)* 0.04;
	float rand_time = random_static(TIME);
	rand_dist = step(rand_time, 0.01);
	
	
	VERTEX.x += distortion * rand_time;
  //float height = texture(noise, VERTEX.xz / 2.0 + 0.5).x;
  //VERTEX.y += height * height_scale;
}

void fragment() {
	float n = random2_static(SCREEN_UV);
	float f = fresnel(_fresnel, NORMAL, VIEW); // 5.0
	
	// -- odd-even lines
	vec2 igrid = floor(SCREEN_UV * lines1);
	float li = mod(igrid.y, 2.0);
	li = mix(0.4, 1.0, li);
	
	// -- random lines
	vec2 uv2 = SCREEN_UV;
	uv2.y -= TIME * 0.06;
	vec2 igrid2 = floor(uv2 * lines2);
	float l2 = random_anim(igrid.y);
	l2 = step(0.2, l2);
	l2 = mix(0.2, 1.0, l2);
	
	float m = f * n * li * l2;
	ALBEDO =  color + mix(_emission, _emission + 5.0, rand_dist); //vec3(li);vec3(l2);//
	ALPHA = m;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}

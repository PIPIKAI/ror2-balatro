#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define MY_HIGHP_OR_MEDIUMP highp
#else
	#define MY_HIGHP_OR_MEDIUMP mediump
#endif

extern MY_HIGHP_OR_MEDIUMP vec2 holofoil;
extern MY_HIGHP_OR_MEDIUMP number dissolve;
extern MY_HIGHP_OR_MEDIUMP number time;
extern MY_HIGHP_OR_MEDIUMP vec4 texture_details;
extern MY_HIGHP_OR_MEDIUMP vec2 image_details;
extern bool shadow;
extern MY_HIGHP_OR_MEDIUMP vec4 burn_colour_1;
extern MY_HIGHP_OR_MEDIUMP vec4 burn_colour_2;


vec3 spinning_light(float t)
{
    return vec3(64.5 / 3.5 * sin(t), 1.0, - 64.5 / 3.5 * cos(t));
}

vec2 hash2( vec2 p )
{
    // procedural white noise	
    vec2 q = vec2(dot(p,vec2(127.1,311.7)),
                  dot(p,vec2(269.5,183.3)) );
	return fract(vec2(sin(q)*43758.5453));
}

vec3 hash3( vec2 p )
{
    vec3 q = vec3( dot(p,vec2(127.1,311.7)), 
				   dot(p,vec2(269.5,183.3)), 
				   dot(p,vec2(419.2,371.9)) );
	return fract(sin(q)*43758.5453);
}

vec4 hash4( vec2 p )
{
    vec4 q = vec4( dot(p,vec2(127.1,311.7)), 
				   dot(p,vec2(269.5,183.3)), 
				   dot(p,vec2(419.2,371.9)), 
				   dot(p,vec2(832.3,201.5)) );
	return fract(sin(q)*43758.5453);
}

//https://iquilezles.org/articles/voronoise
float voronoise( in vec2 p, float u, float v )
{
	float k = 1.0+63.0*pow(1.0-v,6.0);

    vec2 i = floor(p);
    vec2 f = fract(p);
    
	vec2 a = vec2(0.0,0.0);
    for( int y=-2; y<=2; y++ )
    for( int x=-2; x<=2; x++ )
    {
        vec2  g = vec2( x, y );
		vec3  o = hash3( i + g )*vec3(u,u,1.0);
		vec2  d = g - f + o.xy;
		float w = pow( 1.0-smoothstep(0.0,1.414,length(d)), k );
		a += vec2(o.z*w,w);
    }
	
    return max(a.x/a.y, 0.0);
}

//https://iquilezles.org/articles/voronoilines/
vec2 voronoi(vec2 p)
{
    vec2 ip = floor(p);
    vec2 fp = fract(p);

	vec2 mg, mr;

    float md = 8.0;
    vec2 mz = vec2(0.0);
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        vec2 g = vec2(float(i),float(j));
		vec4 o = hash4(ip + g);//*vec3(u,u,1.0);
        vec2 r = g + vec2(o) - fp;
        float d = dot(r,r);

        if(d < md)
        {
            md = d;
            mr = r;
            mg = g;
            mz = o.zw;
        }
    }

    return mz;
}


//https://stackoverflow.com/questions/3407942/rgb-values-of-visible-spectrum
vec3 spectral_spektre(float l)
{
    l = 400.0 + l * 300.0;
    float r=0.0,g=0.0,b=0.0;
         if ((l>=400.0)&&(l<410.0)) { float t=(l-400.0)/(410.0-400.0); r=    +(0.33*t)-(0.20*t*t); }
    else if ((l>=410.0)&&(l<475.0)) { float t=(l-410.0)/(475.0-410.0); r=0.14         -(0.13*t*t); }
    else if ((l>=545.0)&&(l<595.0)) { float t=(l-545.0)/(595.0-545.0); r=    +(1.98*t)-(     t*t); }
    else if ((l>=595.0)&&(l<650.0)) { float t=(l-595.0)/(650.0-595.0); r=0.98+(0.06*t)-(0.40*t*t); }
    else if ((l>=650.0)&&(l<700.0)) { float t=(l-650.0)/(700.0-650.0); r=0.65-(0.84*t)+(0.20*t*t); }
         if ((l>=415.0)&&(l<475.0)) { float t=(l-415.0)/(475.0-415.0); g=             +(0.80*t*t); }
    else if ((l>=475.0)&&(l<590.0)) { float t=(l-475.0)/(590.0-475.0); g=0.8 +(0.76*t)-(0.80*t*t); }
    else if ((l>=585.0)&&(l<639.0)) { float t=(l-585.0)/(639.0-585.0); g=0.82-(0.80*t)           ; }
         if ((l>=400.0)&&(l<475.0)) { float t=(l-400.0)/(475.0-400.0); b=    +(2.20*t)-(1.50*t*t); }
    else if ((l>=475.0)&&(l<560.0)) { float t=(l-475.0)/(560.0-475.0); b=0.7 -(     t)+(0.30*t*t); }
    return vec3(r,g,b);
}

//https://www.alanzucconi.com/2017/07/15/improving-the-rainbow/
vec3 spectral_gems(float w)
{
    return vec3
    (       
        max(1.0 - pow(4.0 * (w - 0.75), 2.0), 0.0),
        max(1.0 - pow(4.0 * (w - 0.5), 2.0), 0.0),
        max(1.0 - pow(4.0 * (w - 0.25), 2.0), 0.0)
    );
}

vec3 voronoi_normal(vec2 uv, vec3 normal, vec3 forward)
{
    //float noise = voronoise(uv * 20.0, 0.0, 0.0);
    // vec2 noise = voronoi(uv * 150.0);
    vec2 white_noise = hash2(uv);
    vec2 noise = white_noise * 1.0;//voronoi_noise * 0.995 + white_noise * 0.005;
    noise.x = voronoise(uv * 120.0 * vec2(4.0, 1.0), 0., 1.0);
    noise.y = voronoise(uv * 120.0 * vec2(4.0, 1.0), 0., 1.0);
    
    float theta = noise.x * 2.0 * 3.14;
    float phi = acos(1.0 - noise.y * 1.125);

    vec3 k = cross(normal, normalize(forward));
    vec3 v = normal;

    vec3 a = normal * cos(phi) + cross(k, v) * sin(phi) + k * dot(k, v) * (1.0 - cos(phi));
    vec3 b = dot(a, normal)*normal;
    vec3 o = a - b;
    vec3 w = cross(normal, o);
    vec3 th = length(o)*(cos(theta)*normalize(o)+sin(theta)*normalize(w));
    return b + th;
}

vec3 bump_normal(vec2 uv, vec3 normal, vec3 forward)
{
    float delta = 0.001;
    float delta_h = 0.00003;
    vec2 noise = hash2(uv);
    float p = voronoise(uv * 120.0 * vec2(4.0, 1.0), 0.0, 1.0) * delta_h;
    float x = voronoise((uv + vec2(delta, 0.0)) * 120.0 * vec2(4.0, 1.0), 0.0, 1.0) * delta_h;
    float y = voronoise((uv + vec2(0.0, delta)) * 120.0 * vec2(4.0, 1.0), 0.0, 1.0) * delta_h;
    
    return normalize(cross(vec3(delta, 0.0, x - p), vec3(0.0, delta, y - p)));
}

float draw_point(vec3 ro, vec3 rd, vec3 p)
{
    float d = length(cross(p - ro, rd)) / length(rd);
    d = smoothstep(.03, .01, d);
    return d;
}


vec4 plane_from_basis(vec3 v0, vec3 v1, vec3 v2)
{
    vec3 vc = cross(v2 - v0, v1 - v0);
    return vec4(vc, -dot(vc, v0));
}

vec4 ray_plane_intersect(vec3 ro, vec3 rd, vec4 plane)
{
    float v = dot(vec3(plane), rd);
    float o = dot(vec3(plane), ro);
    float od = -plane.w - o;
    float d = od / v;
    return vec4(ro + d * rd, d);
}


vec3 light(
    vec3 light_pos,
    vec3 holo_normal,
    vec3 light_color,
    vec3 ro,
    vec3 rd)
{
    vec3 object_normal = vec3(0.0, 0.0, 1.);
    
    vec3 light_dir = normalize(light_pos );

    vec3 n1 = holo_normal * 0.8;
    vec3 n2 = object_normal * 0.2;
    vec3 n = normalize(vec3((n1.x + n2.x) * 2.0, (n1.y + n2.y) * 2.0, holo_normal.z * 1.0));
    
    float a = dot(n, ro);
    float b = dot(n, light_pos);
    float t = a / (a + b);
    vec3 s = (1.0 - t) * (ro - n * a) + t * (light_pos - n * b);
    vec3 disp =  s;
    
    float angle = atan(disp.y, disp.x);
    
    float spectrum = pow(max(dot(-normalize(rd), reflect(-light_dir, n)), 0.0), 4.0);
    float corner = (1.0 + cos(4.0 * angle + 3.14)) / 2.0;
    spectrum = (spectrum + corner * 0.42) * (1.0 - corner * 0.29);
    
    float holo_a = 0.55;
    float holo_b = 0.20;
    float holo_c = 0.21;
    float holo_d = 0.1;
    vec3 holo = spectral_gems(1.0 - (spectrum - holo_a) / holo_b) * smoothstep(0.0, holo_c, cos(5.0 * angle) - holo_d) ;
    return (holo) ;
}

vec4 get_res(vec2 fragCoord ){
        float card_height = 1.0;
    float card_width = 1.0;
    float corner_radius = 0.04;
    
    
    vec3 ro = vec3(0.,0.,1.0);
    vec3 lookat = vec3(0.);
    float zoom = 5.5;
    
    vec2 uv = fragCoord.xy / love_ScreenSize.xy;
    uv -= .5;
    uv.x *= love_ScreenSize.x / love_ScreenSize.y;
    
    vec3 f = normalize(lookat - ro);
    vec3 r = cross(vec3(0.0, 1.0, 0.0), f);
    vec3 u = cross(f, r);
    
    vec3 c = ro + f * zoom;
    vec3 i = c + uv.x * r + uv.y * u;
    
    vec3 rd = i - ro;

    vec3 p = vec3(0.0 + card_width / 2.0, 0.0 - card_height / 2.0, 0.0);
    vec3 d0 = vec3(-card_width,0.,0.);
    vec3 d1 = vec3(0.0,card_height,0.0);

    vec3 holo_normal = voronoi_normal(vec2(uv), cross(d0, d1), d0);
    
    


    vec3 light_color = vec3(1.0,1.0,1.0);
    
    vec3 out_color = vec3(0.45, 0.45, 0.45);

    
    
    for( int i = 0; i < 20; i++)
    {
        out_color += light(spinning_light(  ((holofoil.x + holofoil.y) +time)  / 8. + 3.14 * float(i) / 10.0),holo_normal, light_color, ro, rd);
    }

    return vec4(out_color, 1.0);
}

vec4 dissolve_mask(vec4 tex, vec2 texture_coords, vec2 uv)
{
    if (dissolve < 0.001) {
        return vec4(shadow ? vec3(0.,0.,0.) : tex.xyz, shadow ? tex.a*0.3: tex.a);
    }

    float adjusted_dissolve = (dissolve*dissolve*(3.-2.*dissolve))*1.02 - 0.01; //Adjusting 0.0-1.0 to fall to -0.1 - 1.1 scale so the mask does not pause at extreme values

	float t = time * 10.0 + 2003.;
	vec2 floored_uv = (floor((uv*texture_details.ba)))/max(texture_details.b, texture_details.a);
    vec2 uv_scaled_centered = (floored_uv - 0.5) * 2.3 * max(texture_details.b, texture_details.a);
	
	vec2 field_part1 = uv_scaled_centered + 50.*vec2(sin(-t / 143.6340), cos(-t / 99.4324));
	vec2 field_part2 = uv_scaled_centered + 50.*vec2(cos( t / 53.1532),  cos( t / 61.4532));
	vec2 field_part3 = uv_scaled_centered + 50.*vec2(sin(-t / 87.53218), sin(-t / 49.0000));

    float field = (1.+ (
        cos(length(field_part1) / 19.483) + sin(length(field_part2) / 33.155) * cos(field_part2.y / 15.73) +
        cos(length(field_part3) / 27.193) * sin(field_part3.x / 21.92) ))/2.;
    vec2 borders = vec2(0.2, 0.8);

    float res = (.5 + .5* cos( (adjusted_dissolve) / 82.612 + ( field + -.5 ) *3.14))
    - (floored_uv.x > borders.y ? (floored_uv.x - borders.y)*(5. + 5.*dissolve) : 0.)*(dissolve)
    - (floored_uv.y > borders.y ? (floored_uv.y - borders.y)*(5. + 5.*dissolve) : 0.)*(dissolve)
    - (floored_uv.x < borders.x ? (borders.x - floored_uv.x)*(5. + 5.*dissolve) : 0.)*(dissolve)
    - (floored_uv.y < borders.x ? (borders.x - floored_uv.y)*(5. + 5.*dissolve) : 0.)*(dissolve);

    if (tex.a > 0.01 && burn_colour_1.a > 0.01 && !shadow && res < adjusted_dissolve + 0.8*(0.5-abs(adjusted_dissolve-0.5)) && res > adjusted_dissolve) {
        if (!shadow && res < adjusted_dissolve + 0.5*(0.5-abs(adjusted_dissolve-0.5)) && res > adjusted_dissolve) {
            tex.rgba = burn_colour_1.rgba;
        } else if (burn_colour_2.a > 0.01) {
            tex.rgba = burn_colour_2.rgba;
        }
    }

    return vec4(shadow ? vec3(0.,0.,0.) : tex.xyz, res > adjusted_dissolve ? (shadow ? tex.a*0.3: tex.a) : .0);
}

number hue(number s, number t, number h)
{
	number hs = mod(h, 1.)*6.;
	if (hs < 1.) return (t-s) * hs + s;
	if (hs < 3.) return t;
	if (hs < 4.) return (t-s) * (4.-hs) + s;
	return s;
}

vec4 RGB(vec4 c)
{
	if (c.y < 0.0001)
		return vec4(vec3(c.z), c.a);

	number t = (c.z < .5) ? c.y*c.z + c.z : -c.y*c.z + (c.y+c.z);
	number s = 2.0 * c.z - t;
	return vec4(hue(s,t,c.x + 1./3.), hue(s,t,c.x), hue(s,t,c.x - 1./3.), c.w);
}

vec4 HSL(vec4 c)
{
	number low = min(c.r, min(c.g, c.b));
	number high = max(c.r, max(c.g, c.b));
	number delta = high - low;
	number sum = high+low;

	vec4 hsl = vec4(.0, .0, .5 * sum, c.a);
	if (delta == .0)
		return hsl;

	hsl.y = (hsl.z < .5) ? delta / sum : delta / (2.0 - sum);

	if (high == c.r)
		hsl.x = (c.g - c.b) / delta;
	else if (high == c.g)
		hsl.x = (c.b - c.r) / delta + 2.0;
	else
		hsl.x = (c.r - c.g) / delta + 4.0;

	hsl.x = mod(hsl.x / 6., 1.);
	return hsl;
}

vec4 effect( vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec4 pixel = Texel(texture, texture_coords);
	vec2 uv = (((texture_coords)*(image_details)) - texture_details.xy*texture_details.ba)/texture_details.ba;

	vec4 tex = get_res(screen_coords.xy);

    float avg = (pixel.r + pixel.g + pixel.b) / 2.;
    pixel = vec4(tex.rgb * 0.5 + pixel.rgb * 0.5, pixel.a);
    // tex.rgb = RGB(HSL(res)).rgb;
    // tex.rgb = (res.rgb == vec3(0.3)) ? tex.rgb : res.rgb;
    // tex = mix(tex,res, 0.7);
	return dissolve_mask(pixel, texture_coords, uv);
}

extern MY_HIGHP_OR_MEDIUMP vec2 mouse_screen_pos;
extern MY_HIGHP_OR_MEDIUMP float hovering;
extern MY_HIGHP_OR_MEDIUMP float screen_scale;

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    if (hovering <= 0.){
        return transform_projection * vertex_position;
    }
    float mid_dist = length(vertex_position.xy - 0.5*love_ScreenSize.xy)/length(love_ScreenSize.xy);
    vec2 mouse_offset = (vertex_position.xy - mouse_screen_pos.xy)/screen_scale;
    float scale = 0.2*(-0.03 - 0.3*max(0., 0.3-mid_dist))
                *hovering*(length(mouse_offset)*length(mouse_offset))/(2. -mid_dist);

    return transform_projection * vertex_position + vec4(0,0,0,scale);
}
#endif
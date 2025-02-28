precision highp float;

uniform vec2 u_resolution;
uniform float u_time;

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float color = 0.5 + 0.5 * sin(u_time + uv.xyx + vec3(0, 2, 4));
    gl_FragColor = vec4(color, color * 0.8, color * 0.6, 1.0);
}

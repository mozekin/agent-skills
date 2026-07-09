// crt-glow.glsl — subtle CRT / phosphor effect for Ghostty
// -----------------------------------------------------------------------------
// Faint green bloom + soft scanlines + vignette. Tuned to stay READABLE:
// this is a hint of a CRT, not a heavy filter. Enable in your config with:
//
//     custom-shader = shaders/crt-glow.glsl
//     custom-shader-animation = true
//
// Ghostty feeds the rendered terminal in as iChannel0 (ShaderToy-style).
// Adjust the three tuning constants below to taste.
// -----------------------------------------------------------------------------

const float BLOOM   = 0.030;  // strength of the green glow (0.0 to disable)
const float SCANLINE = 0.045; // darkness of scanlines
const float VIGNETTE = 0.85;  // brightness at the corners (1.0 = none)

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 px = 1.0 / iResolution.xy;

    // Base terminal image.
    vec3 col = texture(iChannel0, uv).rgb;

    // Green-weighted bloom sampled from the 4 neighbours.
    vec3 bloom = texture(iChannel0, uv + vec2( px.x, 0.0)).rgb
               + texture(iChannel0, uv + vec2(-px.x, 0.0)).rgb
               + texture(iChannel0, uv + vec2(0.0,  px.y)).rgb
               + texture(iChannel0, uv + vec2(0.0, -px.y)).rgb;
    col += bloom * BLOOM * vec3(0.35, 1.0, 0.5);

    // Soft scanlines locked to a fixed line count so they don't shimmer.
    float scan = sin(uv.y * 720.0 * 3.14159265) * 0.5 + 0.5;
    col *= 1.0 - SCANLINE * scan;

    // Gentle vignette.
    vec2 v = uv * (1.0 - uv.yx);
    float vig = pow(v.x * v.y * 15.0, 0.20);
    col *= mix(VIGNETTE, 1.0, clamp(vig, 0.0, 1.0));

    fragColor = vec4(col, 1.0);
}

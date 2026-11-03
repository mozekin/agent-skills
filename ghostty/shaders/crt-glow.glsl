// crt-glow.glsl — subtle CRT / phosphor effect for Ghostty (1.3+)
// -----------------------------------------------------------------------------
// Bloom + soft scanlines + vignette, tuned to stay READABLE: a hint of a CRT,
// not a heavy filter. Theme-adaptive: the glow is the text's own color, so it
// reads magenta/cyan under cyberpunk-neon and green under matrix-phosphor.
//
// Enable in your config:
//     custom-shader = shaders/crt-glow.glsl
//
// If it fails to compile Ghostty just skips it (errors go to the log, not the
// config validator). Tune the constants below.
// -----------------------------------------------------------------------------

const float BLOOM    = 0.35;  // glow strength (0.0 disables)
const float RADIUS   = 2.0;   // glow spread, in pixels
const float SCANLINE = 0.06;  // scanline darkness (0.0 disables)
const float PERIOD   = 3.0;   // scanline spacing, in pixels
const float VIGNETTE = 0.82;  // corner brightness (1.0 disables)

// Brightness of a sample above the background, so empty cells don't glow.
vec3 lit(vec2 uv) {
    return max(texture(iChannel0, uv).rgb - iBackgroundColor, 0.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 px = RADIUS / iResolution.xy;

    vec4 term = texture(iChannel0, uv);
    vec3 col = term.rgb;

    // 8-tap bloom: only lit (text) pixels contribute.
    vec3 bloom = lit(uv + vec2( px.x, 0.0)) + lit(uv + vec2(-px.x, 0.0))
               + lit(uv + vec2(0.0,  px.y)) + lit(uv + vec2(0.0, -px.y))
               + lit(uv + px) + lit(uv - px)
               + lit(uv + vec2(px.x, -px.y)) + lit(uv + vec2(-px.x, px.y));
    vec3 glow = bloom * (BLOOM / 8.0);
    col += glow;

    // Scanlines on fixed pixel rows, so they never shimmer when resizing.
    float scan = 0.5 + 0.5 * cos(fragCoord.y * 6.2831853 / PERIOD);
    col *= 1.0 - SCANLINE * scan;

    // Vignette.
    vec2 v = uv * (1.0 - uv.yx);
    float vig = clamp(pow(v.x * v.y * 15.0, 0.2), 0.0, 1.0);
    col *= mix(VIGNETTE, 1.0, vig);

    // Keep the terminal's alpha so background-opacity / blur still work.
    // The glow raises alpha a little so it shows over the translucent bg.
    float a = clamp(term.a + dot(glow, vec3(0.333)), 0.0, 1.0);
    fragColor = vec4(col, a);
}

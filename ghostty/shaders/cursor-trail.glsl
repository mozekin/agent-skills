// cursor-trail.glsl — neon cursor trail for Ghostty (1.3+)
// -----------------------------------------------------------------------------
// When the cursor jumps (new line, vim motion, clicking elsewhere), a short
// glowing streak in the cursor's color shoots from the old spot to the new one
// and shrinks into the cursor. Ordinary typing (one-cell moves) leaves no trail.
//
// Enable in your config:
//     custom-shader = shaders/cursor-trail.glsl
// It needs custom-shader-animation (on by default).
// -----------------------------------------------------------------------------

const float DURATION  = 0.22;  // seconds the trail lasts
const float INTENSITY = 0.6;   // peak opacity of the trail
const float MIN_JUMP  = 1.5;   // ignore moves shorter than this many cursor heights

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord / iResolution.xy);

    float t = (iTime - iTimeCursorChange) / DURATION;
    if (t >= 1.0 || iCursorVisible == 0 || iFocus == 0) return;

    // iCurrentCursor.xy is the top-left corner (y grows upward), .zw the size.
    vec2 head = iCurrentCursor.xy  + vec2(0.5, -0.5) * iCurrentCursor.zw;
    vec2 tail = iPreviousCursor.xy + vec2(0.5, -0.5) * iPreviousCursor.zw;
    vec2 seg = head - tail;
    float len2 = dot(seg, seg);
    float h_px = iCurrentCursor.w;
    if (len2 < (MIN_JUMP * h_px) * (MIN_JUMP * h_px)) return;

    // Position along the segment (0 = tail, 1 = head) and distance to it.
    float s = clamp(dot(fragCoord - tail, seg) / len2, 0.0, 1.0);
    float d = length(fragCoord - tail - seg * s);

    // Tapered streak: thin at the tail, cursor-sized at the head.
    float radius = mix(0.12, 0.5, s) * h_px;
    float body = 1.0 - smoothstep(0.0, radius, d);

    // The tail retracts toward the head as the animation runs.
    float retract = smoothstep(t, t + 0.2, s);

    float k = body * retract * (1.0 - t) * INTENSITY;
    fragColor.rgb = mix(fragColor.rgb, iCurrentCursorColor.rgb, k);
    fragColor.a = max(fragColor.a, k);
}

// =============================================================================
//  Underscore (underline) cursor trail shader for Ghostty
//
//  Adapted from a block-cursor trail shader. The trail geometry originally
//  assumed the cursor fills the whole cell, so it only looked right with
//  cursor-style = block. This version collapses the cursor rectangle to a thin
//  bar pinned to the bottom edge of the cell BEFORE any trail math runs, so the
//  trail (and the hole punched for the real cursor) are underscore-shaped.
//
//  Recommended ghostty config:
//      cursor-style             = underline
//      custom-shader            = ~/.config/ghostty/shaders/cursor_underscore_trail.glsl
//      custom-shader-animation  = always
//
//  `custom-shader-animation = always` keeps the trail animating even when the
//  cursor would otherwise be treated as idle (e.g. the line/underline cursor
//  turning hollow on unfocus, which can freeze the animation otherwise).
// =============================================================================

// sRGB -> Linear conversion (needed because Ghostty passes sRGB values but the shader pipeline operates in linear color space)
vec3 sRGBToLinear(vec3 c) {
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}

// --- CONFIGURATION ---
vec4 TRAIL_COLOR = vec4(sRGBToLinear(iCurrentCursorColor.rgb), iCurrentCursorColor.a); // for custom color: vec4(0.2, 0.6, 1.0, 0.5); (wrap in sRGBToLinear for correct brightness)
const float DURATION = 0.09; // in seconds
const float MAX_TRAIL_LENGTH = 0.2;
const float THRESHOLD_MIN_DISTANCE = 1.5; // min distance to show trail (units of cursor width)
const float BLUR = 2.0; // blur size in pixels (for antialiasing)

// Underscore bar thickness, in pixels.
// Bar thickness as a FRACTION OF CELL WIDTH (not the reported cursor height).
// Width is stable across cursor-style changes; the reported height is NOT —
// an underline cursor turns into a hollow block on blink/unfocus and starts
// reporting a full-cell height. Tying thickness to that height made the bar
// balloon to a full block on those frames (the boxy blink artifact) and also
// shifted the bar's center, firing a phantom trail. Keying off width avoids
// both, and it auto-scales with font size. Bump it up for a chunkier bar.
const float UNDERSCORE_THICKNESS = 0.12;

// --- CONSTANTS for easing functions ---
const float PI = 3.14159265359;
const float C1_BACK = 1.70158;
const float C2_BACK = C1_BACK * 1.525;
const float C3_BACK = C1_BACK + 1.0;
const float C4_ELASTIC = (2.0 * PI) / 3.0;
const float C5_ELASTIC = (2.0 * PI) / 4.5;
const float SPRING_STIFFNESS = 9.0;
const float SPRING_DAMPING = 0.9;

// --- EASING FUNCTIONS ---

// // Linear
// float ease(float x) {
//     return x;
// }

// // EaseOutQuad
// float ease(float x) {
//     return 1.0 - (1.0 - x) * (1.0 - x);
// }

// // EaseOutCubic
// float ease(float x) {
//     return 1.0 - pow(1.0 - x, 3.0);
// }


// // EaseOutQuart
// float ease(float x) {
//     return 1.0 - pow(1.0 - x, 4.0);
// }

// // EaseOutQuint
// float ease(float x) {
//     return 1.0 - pow(1.0 - x, 5.0);
// }

// // EaseOutSine
// float ease(float x) {
//     return sin((x * PI) / 2.0);
// }

// // EaseOutExpo
// float ease(float x) {
//     return x == 1.0 ? 1.0 : 1.0 - pow(2.0, -10.0 * x);
// }

// EaseOutCirc
float ease(float x) {
    return sqrt(1.0 - pow(x - 1.0, 2.0));
}

// // EaseOutBack
// float ease(float x) {
//     return 1.0 + C3_BACK * pow(x - 1.0, 3.0) + C1_BACK * pow(x - 1.0, 2.0);
// }

// // EaseOutElastic
// float ease(float x) {
//     return x == 0.0 ? 0.0
//          : x == 1.0 ? 1.0
//                     : pow(2.0, -10.0 * x) * sin((x * 10.0 - 0.75) * C4_ELASTIC) + 1.0;
// }

// Parametric Spring
// float ease(float x) {
//     x = clamp(x, 0.0, 1.0);
//     float decay = exp(-SPRING_DAMPING * SPRING_STIFFNESS * x);
//     float freq = sqrt(SPRING_STIFFNESS * (1.0 - SPRING_DAMPING * SPRING_DAMPING));
//     float osc = cos(freq * 6.283185 * x) + (SPRING_DAMPING * sqrt(SPRING_STIFFNESS) / freq) * sin(freq * 6.283185 * x);
//     return 1.0 - decay * osc;
// }

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Based on Inigo Quilez's 2D distance functions article: https://iquilezles.org/articles/distfunctions2d/
// Potencially optimized by eliminating conditionals and loops to enhance performance and reduce branching

float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    // max(dot(e,e), eps): when the trail collapses at the end of a move (head == tail)
    // an edge has zero length, so dot(e,e) == 0 and this division becomes 0/0 = NaN.
    // The NaN spreads through mix() and paints stray pixels. The guard prevents it.
    vec2 proj = a + e * clamp(dot(w, e) / max(dot(e, e), 1e-6), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfParallelogram(in vec2 p, in vec2 v0, in vec2 v1, in vec2 v2, in vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);

    d = seg(p, v0, v3, s, d);
    d = seg(p, v1, v0, s, d);
    d = seg(p, v2, v1, s, d);
    d = seg(p, v3, v2, s, d);

    return s * sqrt(d);
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialising(float distance) {
	return 1. - smoothstep(0., normalize(vec2(BLUR, BLUR), 0.).x, distance);
}

float determineIfTopRightIsLeading(vec2 a, vec2 b) {
    float condition1 = step(b.x, a.x) * step(a.y, b.y); // a.x < b.x && a.y > b.y
    float condition2 = step(a.x, b.x) * step(b.y, a.y); // a.x > b.x && a.y < b.y

    // if neither condition is met, return 1 (else case)
    return 1.0 - max(condition1, condition2);
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}


void mainImage(out vec4 fragColor, in vec2 fragCoord){
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif

    // normalization & setup(-1, 1 coords)
    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));

    // ---------------------------------------------------------------------
    //  UNDERSCORE ADAPTATION
    //  Collapse both cursors to a thin bar pinned to the bottom of the cell.
    //  In this coordinate convention .xy is the top-left corner and y grows
    //  upward, so the cell's bottom edge is (.y - .w). We rebuild each cursor
    //  as a bar of height `uThick` sitting on that bottom edge. Everything
    //  downstream (trail parallelogram, straight-move rect, punched hole)
    //  then operates on the underscore instead of a full block.
    // ---------------------------------------------------------------------
    // Thickness from WIDTH (.z), never from the reported height (.w). The bottom
    // edge (.y - .w) stays at the cell bottom whether the cursor reports a thin
    // underline or a full-cell hollow block, so this bar is stable through blinks
    // and focus changes — no ballooning, no phantom trail.
    float uThick = currentCursor.z * UNDERSCORE_THICKNESS;

    // movement threshold keyed off WIDTH (.z), not height — an underscore's
    // height is tiny, so a height-based threshold would be meaningless.
    float minDist = currentCursor.z * THRESHOLD_MIN_DISTANCE;

    currentCursor  = vec4(currentCursor.x,  currentCursor.y  - currentCursor.w  + uThick, currentCursor.z,  uThick);
    previousCursor = vec4(previousCursor.x, previousCursor.y - previousCursor.w + uThick, previousCursor.z, uThick);

    vec2 centerCC = currentCursor.xy - (currentCursor.zw * offsetFactor);
    vec2 centerCP = previousCursor.xy - (previousCursor.zw * offsetFactor);

    vec2 delta = centerCP - centerCC;
    float lineLength = length(delta);

     float sdfCurrentCursor = getSdfRectangle(vu, centerCC, currentCursor.zw * 0.5);

     vec4 newColor = vec4(fragColor);

     float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
     if (lineLength > minDist) {
         // ANIMATION logic

        float head_eased = 0.0;
        float tail_eased = 0.0;

        float tail_delay_factor = MAX_TRAIL_LENGTH / lineLength;

        float isLongMove = step(MAX_TRAIL_LENGTH, lineLength);

        float head_eased_short = ease(progress);
        float tail_eased_short = ease(smoothstep(tail_delay_factor, 1.0, progress));
        float head_eased_long = 1.0;
        float tail_eased_long = ease(progress);

        head_eased = mix(head_eased_long, head_eased_short, isLongMove);
        tail_eased = mix(tail_eased_long, tail_eased_short, isLongMove);

        // detect straight moves
        vec2 delta_abs = abs(centerCC - centerCP);
        float threshold = 0.001;
        float isHorizontal = step(delta_abs.y, threshold);
        float isVertical = step(delta_abs.x, threshold);
        float isStraightMove = max(isHorizontal, isVertical);

        // -- Making the parallelogram sdf (diagonal move) --

        // animate the TOP-LEFT corners
        vec2 head_pos_tl = mix(previousCursor.xy, currentCursor.xy, head_eased);
        vec2 tail_pos_tl = mix(previousCursor.xy, currentCursor.xy, tail_eased);

        float isTopRightLeading = determineIfTopRightIsLeading(currentCursor.xy, previousCursor.xy);
        float isBottomLeftLeading = 1.0 - isTopRightLeading;

        // v0, v1 : "front" of the trail (head)
        vec2 v0 = vec2(head_pos_tl.x + currentCursor.z * isTopRightLeading, head_pos_tl.y - currentCursor.w);
        vec2 v1 = vec2(head_pos_tl.x + currentCursor.z * isBottomLeftLeading, head_pos_tl.y);

        // v2, v3: "back" of the trail (tail)
        vec2 v2 = vec2(tail_pos_tl.x + currentCursor.z * isBottomLeftLeading, tail_pos_tl.y);
        vec2 v3 = vec2(tail_pos_tl.x + currentCursor.z * isTopRightLeading, tail_pos_tl.y - previousCursor.w);

        float sdfTrail_diag = getSdfParallelogram(vu, v0, v1, v2, v3);

        // -- Making the rectangle sdf (straight move) --

        vec2 head_center = mix(centerCP, centerCC, head_eased);
        vec2 tail_center = mix(centerCP, centerCC, tail_eased);

        vec2 min_center = min(head_center, tail_center);
        vec2 max_center = max(head_center, tail_center);

        vec2 box_size = (max_center - min_center) + currentCursor.zw;
        vec2 box_center = (min_center + max_center) * 0.5;

        float sdfTrail_rect = getSdfRectangle(vu, box_center, box_size * 0.5);

        // -- FINAL SELECTING AND DRAWING --
        float sdfTrail = mix(sdfTrail_diag, sdfTrail_rect, isStraightMove);

        vec4 trail = TRAIL_COLOR;
        float trailAlpha = antialising(sdfTrail);
        // Fade the trail out over the final stretch. At rest (progress == 1) the
        // trail collapses onto the cursor, but its soft antialiased edge spills
        // ~BLUR px beyond the cursor rectangle while the hard-edged punch-hole
        // below restores only the strict interior. That leaves a ring of
        // TRAIL_COLOR which is hidden while the cursor fills the interior, but
        // appears as a hollow outline the instant the cursor blinks off. Fading
        // alpha to 0 by progress == 1 leaves nothing to leak.
        trailAlpha *= 1.0 - smoothstep(0.85, 1.0, progress);
        newColor = mix(newColor, trail, trailAlpha);

        // punch hole
        newColor = mix(newColor, fragColor, step(sdfCurrentCursor, 0.));
    }

    fragColor = newColor;
}

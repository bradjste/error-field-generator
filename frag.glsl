/* Fragment shader that draws a fancy animation */

precision highp float;

varying vec2 vPosition;

uniform float uTime;

/* colors used in the shader */
uniform vec4 uColPrimary;
uniform vec4 uColPop;

#define M_PI 3.1415926535897932384626433832795

// GLSL atan2 implementation using only atan
float atan2_approx(float y, float x) {
    if (x > 0.0) {
        return atan(y / x);
    } else if (x < 0.0) {
        if (y >= 0.0) {
            return atan(y / x) + M_PI;  // PI
        } else {
            return atan(y / x) - M_PI; //PI
        }
    } else {  // x == 0.0
        if (y > 0.0) {
            return 0.5 * M_PI;  // PI / 2
        } else if (y < 0.0) {
            return -0.5 * M_PI;  // -PI / 2
        } else {
            return 0.0; // undefined, but return 0
        }
    }
}

float evaluate(float x, float y) {
    return x * cos(tan(y) / 10.0 *  sin( x * y * y + 1000.0 / (x + 1.0 * y))) + x * y;
    // return y * sin(pow(x + 2.6, y) * atan(x + 3.0 * y)) * x * (x * y)/uTime; // circle
    return tan( 10.1 * uTime + sin(x * y * x) / y * atan(0.001 * uTime * (y + x/ y))) * sin(0.1 * uTime * x * y) * y;
}

float getErrorFromPosition() {
    float scale = 0.00210 * uTime;  // * (uTime * 2.8); // 1.0 + 20.0 * cos(sin(uTime) * sin(uTime) * uTime)
    float offSetX =  0.09 * uTime;
    float offSetY =  1.57;
    float x = offSetX + vPosition.x * scale;
    float y = offSetY + vPosition.y * scale;




    return 1.0 - abs(y - evaluate(x, y));
}


// All components are in the range [0…1], including hue.
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// All components are in the range [0…1], including hue.
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

/* Returns the color (RGBA) for the fragment, at time "t" (in seconds) */
// vec4 getColor() {

//     float t = uTime;

//     const float PERIOD_SHAPE = 10.0; // seconds
//     const float PERIOD_ROTATE = 40.0; // seconds
//     const float ZOOM = 0.8;

//     // Convert to polar
//     float r = length(vPosition.xy);
//     float theta = atan(vPosition.y, vPosition.x);

//     // Rotate with time
//     theta += 2.0 * M_PI * t/PERIOD_ROTATE;

//     // If we're outside a disk of radius 1, leave pixel transparent
//     if (r >= 1.0) {
//         return vec4(0.0);
//     }

//     // give it a spherical look by taking r as being the angle of a point
//     // on a sphere
//     r = asin(r);

//     // Pattern zoom
//     r = r / ZOOM;

//     // Convert back to cartesian
//     vec2 p = vec2(r * cos(theta), r * sin(theta));

//     // delta in the animation found empirically (though with known period)
//     float delta = 2.095 + 0.030 * sin(t * 2.0 * M_PI / PERIOD_SHAPE);

//     // Adapted from https://youtu.be/8bbTkNZYdQ8
//     for (float i = 0.0; i < 128.0; i += 1.0) {
//         p = 1.03 * (abs(p) - 0.6);
//         p *= mat2(cos(delta), -sin(delta), sin(delta), cos(delta));
//     }

//     // Initialize the pixel as transparent
//     vec3 rgb = vec3(0.0);
//     float alpha = 0.0;

//     // Find some nice spots (empirically) & make output only 2 colors
//     if(1.2 * length(p) >= 0.8) {
//         rgb = uColPrimary.rgb;
//         alpha = uColPrimary.a;
//     } else if (length(p + vec2(0.2, -0.1)) <= 0.5) {
//         rgb = uColPop.rgb;
//         alpha = uColPop.a;
//     }

//     // Add subtle shading
//     // (light in top-left and dark in bottom right)
//     rgb -= cos(atan(vPosition.y, vPosition.x) + M_PI/4.0) * r / 15.;

//     return vec4(alpha * rgb, alpha);

// }

vec4 getColor2() {
    // if (abs(vPosition.x) <= 0.01 && abs(vPosition.y) <= 0.01) {
    //     return vec4(1.0, 1.0, 1.0, 1.0);
    // }

    float theta = atan2_approx(vPosition.y, vPosition.x) / (M_PI * 2.0); // [0, 1]
    float r = length(vPosition.xy);

    float value = getErrorFromPosition();

    // if (1.0 - value < 0.01) {
    //     return vec4(1.0);
    // }

    // if (vPosition.x > 0.0) {
    //     hue = atan((vPosition.y / vPosition.x) + sin(uTime)) / M_PI;
    // }
    // if (vPosition.x < 0.0) {
    //     hue = atan((vPosition.y / vPosition.x)) / M_PI;
    // }
    // hue += fract(hue - uTime * 0.1);

    vec3 color = hsv2rgb(vec3(
        fract(value + uTime * 0.1), 
        1.0,
        1.0
        // (uTime - r) / (r * r * r / sin(vPosition.x * atan(vPosition.y / vP) * 2.0 * M_PI)) // 1.0 - r^10
    ));

    return vec4(color, 1.0);
}

void main() {
    gl_FragColor = getColor2();
}

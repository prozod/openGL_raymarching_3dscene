#version 330 core
precision highp float;

in vec2 fragUV;
out vec4 FragColor;

uniform vec2 u_resolution;
uniform vec3 u_cameraPos;
uniform vec3 u_cameraDir;
uniform float u_time;

// signed distance functions (some of them are from Inigo Quilez website)
float sdSphere(vec3 p, float r) {
    return length(p) - r;
}

float sdPlane(vec3 p, float y) {
    return p.y - y;
}

float sdBox(vec3 p, vec3 b) {
    vec3 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

float sdT(vec3 p, float width, float height, float thickness) {
    float stemDist = sdBox(p - vec3(0.0, 0.0, 0.0), vec3(thickness, height, thickness));
    float topDist = sdBox(p - vec3(0.0, height, 0.0), vec3(width * 0.5, thickness, thickness));
    return min(stemDist, topDist);
}

float sdH(vec3 p, float width, float height, float thickness) {
    float leftBar = sdBox(p - vec3(-width * 0.5, 0.0, 0.0), vec3(thickness, height, thickness));
    float rightBar = sdBox(p - vec3(width * 0.5, 0.0, 0.0), vec3(thickness, height, thickness));
    float middleBar = sdBox(p - vec3(0.0, height * 0.2, 0.0), vec3(width * 0.5, thickness, thickness));
    return min(min(leftBar, rightBar), middleBar);
}

float sdU(vec3 p, float width, float height, float thickness) {
    float leftBar = sdBox(p - vec3(-width * 0.5, 0.0, 0.0), vec3(thickness, height, thickness));
    float rightBar = sdBox(p - vec3(width * 0.5, 0.0, 0.0), vec3(thickness, height, thickness));
    float bottomBar = sdBox(p - vec3(0.0, -height * 0.53, 0.05), vec3(width * 0.5, thickness, thickness));
    return min(min(leftBar, rightBar), bottomBar);
}

// specular lighting model 
vec3 specularLighting(vec3 normal, vec3 lightDir, vec3 viewDir, float shininess) {
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), shininess);
    return vec3(1.0) * spec;
}

// lighting model (diffuse + specular)
vec3 lighting(vec3 normal, vec3 lightDir, vec3 hitColor, vec3 viewDir, float shininess, bool isInShadow) {
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 spec = specularLighting(normal, lightDir, viewDir, shininess);
    vec3 ambientLight = vec3(0.05, 0.05, 0.05);
    float lightIntensity = 1.0;

    // this is how i comppute shadows, if the point is in shadow i reduce the light intensity
    if (isInShadow) {
        lightIntensity *= 0.2; // light intensity is reduced by 80% for shadowed areas
    }

    return (hitColor * diff + spec + ambientLight) * lightIntensity;
}

// the overall scene containng the ojbects 
float scene(vec3 p, out vec3 hitColor, out vec3 normal) {
    float sphere1Dist = sdSphere(p - vec3(1.5 + abs(cos(u_time)), -0.5 + abs(sin(u_time * 5)), 2.4), 0.4);
    float sphere2Dist = sdSphere(p - vec3(4.0, -0.5 + abs(sin(u_time * 4)), -1.0), 0.2);
    float sphere3Dist = sdSphere(p - vec3(5.8, -0.2, -2.1), 0.8);
    float platformDist = sdPlane(p, -1.0);
    
    float tDist = sdT(p - vec3(3.0, 0.0, 2.0), 1.5, 1.1, 0.2);
    float hDist = sdH(p - vec3(5.0, 0.0, 2.0), 1.0, 1.3, 0.2);
    float uDist = sdU(p - vec3(7.0, 0.0, 2.0), 1.0, 1.3, 0.2);

    float minDist = platformDist;
    normal = vec3(0.0, 1.0, 0.0);
    hitColor = vec3(0.1, 0.3, 0.1);

    if (sphere1Dist < minDist) {
        minDist = sphere1Dist;
        normal = normalize(p - vec3(-1.0, 0.0, 0.0));
        hitColor = vec3(0.5, 0.2, 0.9);
    }
    if (sphere2Dist < minDist) {
        minDist = sphere2Dist;
        normal = normalize(p - vec3(2.0, 0.0, 0.0));
        hitColor = vec3(0.2, 0.8, 0.2);
    }
    if (sphere3Dist < minDist) {
        minDist = sphere3Dist;
        normal = normalize(p - vec3(0.5, 0.0, 0.0));
        hitColor = vec3(0.8, 0.8, 0.2);
    }
    if (tDist < minDist) {
        minDist = tDist;
        normal = normalize(p - vec3(2.0, 0.0, 0.0));
        hitColor = vec3(1.0, 0.5, 0.5);
    }
    if (hDist < minDist) {
        minDist = hDist;
        normal = normalize(p - vec3(-2.0, 0.0, 0.0));
        hitColor = vec3(0.5, 1.0, 0.5);
    }
    if (uDist < minDist) {
        minDist = uDist;
        normal = normalize(p - vec3(-5.0, 0.0, 0.0));
        hitColor = vec3(0.5, 0.5, 1.0);
    }

    return minDist;
}

bool inShadow(vec3 p, vec3 lightPos) { // checks if the object is in shadow
    vec3 lightDir = normalize(lightPos - p);
    float t = 0.0;

    for (int i = 0; i < 50; ++i) {
        t += 0.05;  // shadow ray size
        vec3 shadowPoint = p + t * lightDir;
        vec3 hitColor = vec3(0.0);
        vec3 normal = vec3(0.0);
        float dist = scene(shadowPoint, hitColor, normal);

        if (dist < 0.05) {
            return true; // shadow ray hit something (point in shadow)
        }
    }
    return false; // no object is blocking the light
}

void main() {
    float aspect = u_resolution.x / u_resolution.y;
    vec2 uv = fragUV * 2.0 - 1.0;
    uv.x *= aspect;  // dont beep boop flatten objects when resolution isn't square

    vec3 ro = u_cameraPos;
    vec3 forward = normalize(u_cameraDir); // POV forward direction

    vec3 right = normalize(cross(forward, vec3(0.0, 1.0, 0.0)));
    vec3 up = cross(right, forward);
    vec3 rd = normalize(forward + uv.x * right + uv.y * up);

    vec3 color = vec3(0.0);
    float t = 0.0;

    float lightAngle = u_time * 2.0;  

    vec3 lightPos = vec3(15.0, 15.0, 5.0);

    float cosAngle = cos(lightAngle);
    float sinAngle = sin(lightAngle);

    lightPos = vec3(
        lightPos.x * cosAngle - lightPos.z * sinAngle,
        lightPos.y,
        lightPos.x * sinAngle + lightPos.z * cosAngle
    );

    for (int i = 0; i < 500; ++i) {
        vec3 p = ro + t * rd;
        vec3 hitColor = vec3(0.0);
        vec3 normal = vec3(0.0);
        float dist = scene(p, hitColor, normal);

        if (dist < 0.05) {
            bool shadow = inShadow(p, lightPos);  // check if the point is in shadow
            // bool shadow = false;
            vec3 lightDir = normalize(lightPos - p);
            vec3 viewDir = normalize(ro - p);
            float shininess = 32.0;

            color = lighting(normal, lightDir, hitColor, viewDir, shininess, shadow);
            break;
        }

        t += dist / 2;
        if (t > 50.0) {
            float gradient = uv.y * 0.5 + 0.5;
            color = mix(vec3(0.2, 0.0, 1.0), vec3(0.2, 0.8, 1.0), gradient);
            break;
        }
    }

    FragColor = vec4(color, 1.0);
}


#version 330 core 
in vec3 ourColor;
in vec3 ourPosition;
out vec4 color;
void main()
{
    float radius = 0.5;
    vec3 origin = vec3(0.0);
    float dist = distance(origin, ourPosition);
    float delta = 0.01;
    float alpha = smoothstep(dist-delta, dist, radius-delta);
    color = vec4(ourColor, alpha);
}

#version 330 core
out vec4 color;

in vec2 TexCoords;
in vec3 FragPos;
in vec3 Normal;

uniform sampler2D texture_diffuse1;
uniform sampler2D texture_diffuse2;
uniform sampler2D texture_diffuse3;
uniform sampler2D texture_specular1;
uniform sampler2D texture_specular2;

void main()
{
    vec3 diffuse1 = vec3(texture(texture_diffuse1, TexCoords));
    vec3 diffuse2 = vec3(texture(texture_diffuse2, TexCoords));
    vec3 diffuse3 = vec3(texture(texture_diffuse3, TexCoords));
    vec3 specular1 = vec3(texture(texture_specular1, TexCoords));
    vec3 specular2 = vec3(texture(texture_specular2, TexCoords));

    vec3 ambient = (diffuse1 + diffuse2 + diffuse3) / 3.0;
    vec3 specular = (specular1 + specular2) * 0.5;

    color = vec4(ambient, 1.0);
}

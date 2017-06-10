#version 330 core
out vec4 color;

in vec2 TexCoords;
in vec3 FragPos;
in vec3 Normal;

// uniform vec3 lightPos;
uniform vec3 viewPos;

uniform sampler2D texture_diffuse1;
uniform sampler2D texture_diffuse2;
uniform sampler2D texture_diffuse3;
uniform sampler2D texture_specular1;
uniform sampler2D texture_specular2;

struct Light {
    vec3 position;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

uniform Light light;

void main()
{
    vec3 diffuse1 = vec3(texture(texture_diffuse1, TexCoords));
    vec3 diffuse2 = vec3(texture(texture_diffuse2, TexCoords));
    vec3 diffuse3 = vec3(texture(texture_diffuse3, TexCoords));
    vec3 specular1 = vec3(texture(texture_specular1, TexCoords));
    vec3 specular2 = vec3(texture(texture_specular2, TexCoords));

    vec3 ambient = light.ambient * diffuse1;

    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(light.position - FragPos);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = light.diffuse * diff * diffuse1;

    // Specular
    vec3 viewDir = normalize(viewPos - FragPos);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0);
    vec3 specular = light.specular * spec * vec3(texture(texture_specular1, TexCoords));

    vec3 result = ambient + diffuse + specular;
    color = vec4(result, 1.0f);
}

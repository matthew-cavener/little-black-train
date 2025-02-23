shader_type canvas_item;

uniform float cutoff_threshold : hint_range(0.0, 1.0) = 0;
uniform float brightness_value : hint_range(0.0, 10.0) = 3;

void fragment() {
    vec4 pixelColor = texture(TEXTURE, UV);
    //float avg = (pixelColor.r + pixelColor.g + pixelColor.b) / 3.0;
    //pixelColor.rgb = vec3(avg);
    float brightness = (pixelColor.r + pixelColor.g + pixelColor.b) / brightness_value;
    vec4 greyColor = vec4(brightness, brightness, brightness, pixelColor.a);
    COLOR = greyColor;
}
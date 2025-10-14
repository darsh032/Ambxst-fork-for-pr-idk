#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float phase;
    float amplitude;
    float frequency;
    vec4 shaderColor;
    float lineWidth;
    float canvasWidth;
    float canvasHeight;
    float fullLength;
} ubuf;

#define PI 3.14159265359

// Calcula Y de la onda en una posición X
float waveY(float x, float centerY) {
    float k = ubuf.frequency * 2.0 * PI / ubuf.fullLength;
    return centerY + ubuf.amplitude * sin(k * x + ubuf.phase);
}

// Calcula la derivada de la onda (útil para mejorar la búsqueda del punto más cercano)
float waveDerivative(float x) {
    float k = ubuf.frequency * 2.0 * PI / ubuf.fullLength;
    return ubuf.amplitude * k * cos(k * x + ubuf.phase);
}

// Distancia a la curva de la onda usando búsqueda optimizada
float distanceToWave(vec2 pos, float centerY) {
    float startX = 0.0;
    float endX = ubuf.canvasWidth;
    
    // Comenzar la búsqueda desde la X del pixel
    float testX = clamp(pos.x, startX, endX);
    
    // Iteración de Newton-Raphson para encontrar el punto más cercano
    // Esto es mucho más eficiente que buscar en todo el rango
    for (int iter = 0; iter < 5; iter++) {
        float y = waveY(testX, centerY);
        float dy = waveDerivative(testX);
        
        vec2 curvePoint = vec2(testX, y);
        vec2 toPixel = pos - curvePoint;
        
        // Tangente a la curva
        vec2 tangent = normalize(vec2(1.0, dy));
        
        // Proyectar el vector hacia el pixel sobre la tangente
        float projection = dot(toPixel, tangent);
        
        // Actualizar posición de búsqueda
        testX += projection;
        testX = clamp(testX, startX, endX);
        
        // Si llegamos al límite, salir
        if (testX <= startX || testX >= endX) break;
    }
    
    // Calcular distancia final
    vec2 closestPoint = vec2(testX, waveY(testX, centerY));
    return distance(pos, closestPoint);
}

// Calcula el factor de reducción del grosor en los extremos
float edgeTaper(float x) {
    float startX = 0.0;
    float endX = ubuf.canvasWidth;
    float taperDistance = ubuf.lineWidth * 0.5;
    
    // Fade en el extremo izquierdo
    if (x < startX + taperDistance) {
        float t = (x - startX) / taperDistance;
        float u = 1.0 - t;
        return sqrt(max(0.0, 1.0 - u * u));
    }
    
    // Fade en el extremo derecho
    if (x > endX - taperDistance) {
        float t = (endX - x) / taperDistance;
        float u = 1.0 - t;
        return sqrt(max(0.0, 1.0 - u * u));
    }
    
    return 1.0;
}

void main() {
    vec2 pixelPos = qt_TexCoord0 * vec2(ubuf.canvasWidth, ubuf.canvasHeight);
    float centerY = ubuf.canvasHeight * 0.5;
    
    // Verificar si estamos dentro del canvas en X
    if (pixelPos.x < 0.0 || pixelPos.x > ubuf.canvasWidth) {
        discard;
    }
    
    // Calcular distancia a la línea central de la onda (grosor infinitesimal)
    float dist = distanceToWave(pixelPos, centerY);
    
    // Aplicar el taper en los extremos
    float taper = edgeTaper(pixelPos.x);
    float effectiveRadius = (ubuf.lineWidth * 0.5) * taper;
    
    // Calcular alpha usando antialiasing suave
    // El grosor del antialiasing es proporcional al tamaño del pixel
    float aaWidth = 1.0;
    float alpha = 1.0 - smoothstep(effectiveRadius - aaWidth, effectiveRadius + aaWidth, dist);
    
    // Descartar pixels completamente transparentes
    if (alpha < 0.01) {
        discard;
    }
    
    fragColor = vec4(ubuf.shaderColor.rgb, ubuf.shaderColor.a * alpha * ubuf.qt_Opacity);
}

//
//  CircleShader.metal
//  MetalCircle
//
//  Created by João Gabriel Pozzobon dos Santos on 17/11/21.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct VertexOut {
    simd_float4 position [[position]];
    simd_float4 color;
};

vertex VertexOut vertexShader(const constant VertexOut *vertexArray [[buffer(0)]], unsigned int vid [[vertex_id]]){
    VertexOut output = vertexArray[vid];
    return output;
}

fragment simd_float4 fragmentShader(VertexOut interpolated [[stage_in]]){
    return interpolated.color;
}

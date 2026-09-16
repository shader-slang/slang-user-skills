// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import slang.numerics;

T squarePlusOne<T : INumeric>(T value)
{
    return value * value + T(1);
}

bool scalarLess<T : IScalarReal>(T left, T right)
{
    return left < right;
}

T shapedClamp<T : INumericalExtrema>(T value, T lower, T upper)
{
    return clamp(value, lower, upper);
}

vector<T, N> builtinShapedClamp<
    T : IBuiltinScalarArithmeticTypeDispatchMarker & INumericalExtrema,
    let N : int>(vector<T, N> value, vector<T, N> lower, vector<T, N> upper)
{
    return clamp(value, min(value, lower), max(value, upper));
}

RWStructuredBuffer<float4> outputBuffer;

[shader("compute")]
[numthreads(1, 1, 1)]
void main()
{
    float3 value = shapedClamp(squarePlusOne(float3(1.0, 2.0, 3.0)), float3(0.0), float3(8.0));
    int3 integerValue = builtinShapedClamp(int3(1, 2, 3), int3(0), int3(2));
    outputBuffer[0] = float4(
        value.xy,
        float(integerValue.z),
        scalarLess(1.0, 2.0) ? 1.0 : 0.0);
}

// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import slang.numerics;

vector<T, N> combineVector<T : IBuiltinScalarReal, int N>(
    vector<T, N> left,
    vector<T, N> right)
{
    return min(left + right, right);
}

T.Scalar innerProduct<T : IDotProduct>(T left, T right)
{
    return dot(left, right);
}

T builtinVectorInnerProduct<T : IBuiltinScalarNumeric, let N : int>(
    vector<T, N> left,
    vector<T, N> right)
{
    return dot(left, right);
}

RWStructuredBuffer<float4> outputBuffer;

[shader("compute")]
[numthreads(1, 1, 1)]
void main()
{
    float3 left = float3(1.0, 2.0, 3.0);
    float3 right = float3(4.0, 5.0, 6.0);
    int integerDot = builtinVectorInnerProduct(int2(1, 2), int2(3, 4));
    uint unsignedDot = builtinVectorInnerProduct(uint2(2, 3), uint2(4, 5));
    outputBuffer[0] = float4(
        combineVector(left, right).xy,
        float(integerDot),
        float(unsignedDot + uint(innerProduct(left, right))));
}

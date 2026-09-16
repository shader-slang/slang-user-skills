// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import slang.numerics;

T addBuiltinFloat<T : IFractional, S : IBuiltinScalarFloatingPointType>(T left, S right)
{
    return left + T(right);
}

RWStructuredBuffer<float4> outputBuffer;

[shader("compute")]
[numthreads(1, 1, 1)]
void main()
{
    vector<half, 3> source = vector<half, 3>(half(1.0), half(2.0), half(3.0));
    vector<float, 3> converted = convertBuiltinVector<float>(source);
    matrix<float, 2, 2> convertedMatrix =
        convertBuiltinMatrix<float>(matrix<half, 2, 2>(half(1.0), half(2.0), half(3.0), half(4.0)));
    uint convertedInteger = convertBuiltinScalar<uint>(converted[0]);
    outputBuffer[0] = float4(
        converted,
        addBuiltinFloat(1.0, half(0.5)) + float(convertedInteger) + convertedMatrix[0][0]);
}

// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

interface IReadable<T>
{
    T read(uint index);
}

struct FixedPair<T>
{
    T values[2];
}

extension<T> FixedPair<T> : IReadable<T>
{
    T read(uint index)
    {
        return values[index];
    }
}

extension<T, C : IReadable<T>> C
{
    T first()
    {
        return this.read(0);
    }
}

T readFirst<T, C>(C values)
    where C : IReadable<T>
{
    return values.first();
}

RWStructuredBuffer<int> outputBuffer;

[shader("compute")]
[numthreads(1, 1, 1)]
void main()
{
    FixedPair<int> values = {{3, 5}};
    outputBuffer[0] = readFirst<int>(values);
}

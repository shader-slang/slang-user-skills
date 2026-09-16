// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

struct FixedPair<T>
{
    T values[2];
}

extension<T> FixedPair<T> : IArray<T>
{
    int getCount()
    {
        return 2;
    }

    __subscript(int index) -> T
    {
        get { return values[index]; }
    }
}

interface IConvertTo<Destination>
{
    Destination convert();
}

struct RawInt : IConvertTo<int>
{
    int value;

    int convert()
    {
        return value;
    }
}

extension<Destination> FixedPair<Destination>
{
    static FixedPair<Destination> convertFrom<Source : IConvertTo<Destination>>(
        FixedPair<Source> source)
    {
        return {{
            source.values[0].convert(),
            source.values[1].convert(),
        }};
    }
}

T readFirst<T, C : IArray<T>>(C values)
{
    return values[0];
}

RWStructuredBuffer<int> outputBuffer;

[shader("compute")]
[numthreads(1, 1, 1)]
void main()
{
    FixedPair<int> values = {{3, 5}};
    FixedPair<RawInt> wrapped = {{{7}, {11}}};
    FixedPair<int> converted = FixedPair<int>.convertFrom(wrapped);
    outputBuffer[0] = readFirst<int>(values) + converted.values[1];
}

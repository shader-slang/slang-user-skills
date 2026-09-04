# Contracts and Constrained Extensions

Infer a type parameter's contract from operations in the template body, not only from concrete arguments visible at current call sites.
Keep the interface no broader than the body requires.

## Constraint placement

Constrain the type on which an operation is performed.
If a generic adds two `Pair<T>` values, constraining `T` does not define addition for `Pair<T>`.
Either make the body operate on `T` components or make `Pair<T>` conform to the interface required by the generic operation.

Use a `where` clause when the constrained type is constructed or when it makes the relationship clearer:

```slang
T readFirst<T, C>(C values)
    where C : IReadable<T>
{
    return values.read(0);
}
```

## User-defined contracts

Match the source operation precisely:

```slang
interface IReadable<T>
{
    T read(uint index);
}

interface IAccumulator<T>
{
    [mutating] void add(T value);
}
```

Do not put writable value arrays and reference-backed writable resources behind one interface unless their mutation semantics genuinely match.
Prefer a read-only contract when the body only reads.

## Constrained extensions

Put generic parameters and their constraints before the extended type:

```slang
extension<T : IReadable<int>> T
{
    int first()
    {
        return this.read(0);
    }
}
```

For a generic wrapper, repeat the parameter relationship in the extension:

```slang
extension<T : IScalarAdditive> Pair<T> : IAdditive
{
    // Requirements use the wrapper as `This`.
}
```

See the compiler-checked [contract example](examples/contracts-and-extensions.slang).

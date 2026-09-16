# Contracts and Constrained Extensions

Infer a type parameter's contract from operations in the template body, not only from concrete arguments visible at current call sites.
Keep the interface no broader than the body requires.

## Preserve independent roles

Do not merge independent source template parameters merely because one visible call gives them the
same concrete argument.
For example, keep the stored element and lookup key distinct when the source comparator accepts
different types:

```slang
interface ICompare<Element, Key>
{
    int compare(Element element, Key key);
}

uint lowerBound<Element, Key, Container : IArray<Element>, Compare : ICompare<Element, Key>>(
    Container values,
    Key key,
    Compare compare);
```

The generic caller owns `Element`, `Key`, the standard readable container, and the comparator as
separate parameters.
If an operator relationship cannot be expressed directly as a Slang constraint, move that one
operation into an adapter or strategy interface rather than equating the operand types.

## Constraint placement

Constrain the type on which an operation is performed.
If a generic adds two `Pair<T>` values, constraining `T` does not define addition for `Pair<T>`.
Either make the body operate on `T` components or make `Pair<T>` conform to the interface required by the generic operation.

Use a `where` clause when the constrained type is constructed or when it makes the relationship clearer:

```slang
T readFirst<T, C : IArray<T>>(C values)
{
    return values[0];
}
```

## User-defined contracts

Prefer an existing standard contract when it supplies the required behavior.
Declare a custom read contract only when the source operation genuinely differs from `IArray<T>`
or the supplied toolchain lacks a conformance for the resource involved.
For example, an API whose only operation is an unsigned-address load can use:

```slang
interface ILoadAt<T>
{
    T load(uint address);
}

interface IAccumulator<T>
{
    [mutating] void add(T value);
}
```

Do not put writable value arrays and reference-backed writable resources behind one interface unless their mutation semantics genuinely match.
Prefer `IArray<T>` or another read-only contract when the body only reads.

Different generic bodies over the same source type can require different contracts.
Do not combine their requirements into one catch-all interface and then invent implementations for
types that support only a subset.
Use sibling interfaces or refinements, for example a read interface for `load`, a write refinement
for `store`, and a separate lifecycle capability for `release`.
An empty lifecycle method or a write that discards its value is not a valid conformance.

## Constrained extensions

Every generic parameter declared by an extension should be determined by the extended type.
If a type parameter appears only in one member signature or constraint, declare it on that member instead of on the extension.

For example, `Source` belongs on `convertFrom` because it is not part of `Box<Destination>`:

```slang
interface IConvertTo<Destination>
{
    Destination convert();
}

struct Box<T>
{
    T value;
}

extension<Destination> Box<Destination>
{
    static Box<Destination> convertFrom<Source : IConvertTo<Destination>>(Box<Source> source)
    {
        return { source.value.convert() };
    }
}
```

Putting `Source` on the extension would leave it independent of the target type.
Slang can warn that such an extension is non-standard and may not make the member available as intended.

A member constraint can constrain its own `Source` parameter in terms of `Destination`, as above.
It cannot add a new constraint to the extension's existing `Destination` parameter.
If the natural contract is instead `Destination : IConvertFrom<Source>`, use a free generic function that owns both parameters, or redesign the contract without reversing its meaning merely to fit an extension.

Put generic parameters and their constraints before the extended type:

```slang
extension<T : IArray<int>> T
{
    int first()
    {
        return this[0];
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

Use constrained extensions this way for ordinary named members.
Current Slang operator lookup does not reliably find an operator declared only in a constrained extension.
When a source member operator needs a stronger constraint than its wrapper, preserve operator syntax with a free generic operator instead:

```slang
Pair<T> operator+<T : IScalarAdditive>(Pair<T> left, Pair<T> right)
{
    return { left.first + right.first, left.second + right.second };
}
```

See the compiler-checked [contract example](examples/contracts-and-extensions.slang).

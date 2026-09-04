# Custom Numeric Types and Wrappers

## Decide whether the type itself needs a conformance

Add a conformance when a custom type is passed as the type argument to generic code requiring that interface.
If a wrapper's methods perform all arithmetic directly on a payload, constraining only the payload can be sufficient.

Do not infer that every numeric-looking wrapper should conform.
Before adding a conformance, verify that every inherited requirement has a faithful implementation.

## Mathematical scalars

A scalar in the numerics model is a logical element, not necessarily one machine word.
Complex, dual, fixed-point, ratio, and interval types can be scalar types.

Start with the narrowest scalar refinement that downstream generic code needs:

- `IScalarAdditive` for addition and subtraction;
- `IScalarNumeric` when same-type multiplication is needed;
- `IScalarFractional` when division and reciprocal are needed;
- an elementary-function interface only for functions the type faithfully implements;
- ordering only when the type has the promised comparison semantics.

All scalar refinements share this shape contract:

```slang
typealias Scalar = This;
typealias Mask = bool;

static This fromScalar(Scalar value)
{
    return value;
}
```

`INumeric` also requires construction from builtin integers, and `IFractional` requires construction from builtin floating-point values.
Inside those constructor implementations, an internal builtin conversion can be appropriate because the custom representation is explicitly being built from compiler-recognized scalar types.
User-facing generic algorithms should still call the public constructor as `T(value)`.

The compiler-checked [dual-number example](examples/custom-dual-number.slang) implements `IScalarFractional` without pretending that the dual number itself has an IEEE floating-point representation.

## Shaped wrappers

When a wrapper represents a logical shape, set `Scalar` to its element type, set `Mask` to the corresponding Boolean shape, and implement the shaped operations on the wrapper itself.
The compiler-checked [pair wrapper example](examples/wrapper-conformance.slang) shows a minimal `IAdditive` conformance.

A constraint on `T` does not automatically make `Pair<T>` additive.
The wrapper must either perform component operations internally or provide its own conformance when passed to a generic additive function.

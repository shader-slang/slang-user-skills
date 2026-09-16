# Shapes, Masks, and Numeric Conversions

## Same-shaped masks

Comparison on a shaped type returns `T.Mask`, not necessarily `bool`:

```slang
T.Mask componentLess<T : IComponentwiseOrdered>(T left, T right)
{
    return left < right;
}

bool allLess<T : IComponentwiseOrdered>(T left, T right)
{
    return (left < right).all();
}
```

Preserve component-wise semantics.
Reduce with the mask's `all()` or `any()` operation only when the source algorithm requires one Boolean result.

## Scalar-to-shaped values

A same-type operator does not automatically accept a distinct scalar operand.
Use `T.fromScalar` when the source semantics require splatting one scalar over the logical shape:

```slang
T weightedSum<T : IFractional>(T left, T right, T.Scalar weight)
{
    T shapedWeight = T.fromScalar(weight);
    return left * (T.one() - shapedWeight) + right * shapedWeight;
}
```

## Construction from builtin values

`INumeric` includes construction from every builtin integer type.
`IFractional` additionally includes construction from every builtin floating-point type.
Use ordinary construction syntax in generic code:

```slang
T addBuiltinFloat<T : IFractional, S : IBuiltinScalarFloatingPointType>(T left, S right)
{
    return left + T(right);
}
```

The sealed constraint is appropriate for the generic source because the conversion facility explicitly promises builtin source types.
The destination remains constrained by its public mathematical capability.

For component-wise conversion, construct every destination component from its corresponding source component.
Do not convert one component and splat it.

When the source and destination are both generic builtin scalar representations, ordinary construction can be ambiguous because no single extensible interface describes every cross-category conversion.
Use the public builtin conversion operation instead:

```slang
TDestination convertValue<
    TDestination : IBuiltinScalarTypeDispatchMarker,
    TSource : IBuiltinScalarTypeDispatchMarker>(TSource value)
{
    return convertBuiltinScalar<TDestination>(value);
}
```

For a builtin vector or matrix, use the corresponding same-shaped helper:

```slang
vector<TDestination, N> convertVector<
    TDestination : IBuiltinScalarTypeDispatchMarker,
    TSource : IBuiltinScalarTypeDispatchMarker,
    let N : int>(vector<TSource, N> value)
{
    return convertBuiltinVector<TDestination>(value);
}
```

`convertBuiltinMatrix<TDestination>` provides the analogous matrix operation.
When the supplied numerics module predates these helpers, or when the shape is a user-defined
wrapper, loop over its logical components and call `convertBuiltinScalar` once per component.
Both approaches preserve signedness changes, integer-to-floating-point and floating-point-to-integer conversions, Boolean conversions, and wider floating-point destinations without routing through an intermediate representation.
See the compiler-checked [conversion example](examples/builtin-numeric-conversion.slang).

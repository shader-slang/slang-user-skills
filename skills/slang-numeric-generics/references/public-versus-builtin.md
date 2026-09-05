# Public Numeric Contracts versus Sealed Builtin Constraints

Public numeric interfaces describe capabilities that user-defined types can implement.
Sealed `__Builtin*` interfaces describe compiler-recognized representations and intentionally cannot be implemented by user types.

Use a public contract when ordinary interface operations express the body:

```slang
import slang.numerics;

T twice<T : IAdditive>(T value)
{
    return value + value;
}
```

This works for builtin additive values and for a user-defined type with a faithful `IAdditive` conformance.

This replacement is not equivalent:

```slang
T twiceBuiltin<T : __BuiltinArithmeticType>(T value)
{
    return value + value;
}
```

`twiceBuiltin` excludes every user-defined numeric type, even if it implements exactly the addition operation the body needs.

Use a sealed builtin constraint when the implementation depends on a builtin-only intrinsic, representation, layout, or type constructor.
For a generic builtin vector element, the sealed constraint can be conjoined with a public scalar capability so both requirements remain explicit.

The compiler-checked [negative example](examples/sealed-builtin-negative.slang) confirms that a user-defined additive type cannot satisfy the sealed interface.

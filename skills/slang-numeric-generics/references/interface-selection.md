# Numeric Interface Selection

Choose the smallest public capability that covers the generic body.
The scalar-or-shaped column accepts component-wise vector and matrix behavior where supported; the scalar-only column excludes those shapes.

| Body requirement | Scalar or shaped | Scalar only |
| --- | --- | --- |
| Shape metadata and scalar splat | `INumericShapedType` | `IScalarShapedType` |
| Addition, subtraction, zero, and compound assignment | `IAdditive` | `IScalarAdditive` |
| Same-type multiplication, one, and construction from builtin integers | `INumeric` | `IScalarNumeric` |
| Negation and absolute value | `ISignedNumeric` | `IScalarSignedNumeric` |
| Division, reciprocal, and construction from builtin floating-point values | `IFractional` | `IScalarFractional` |
| Floating-point representation, rounding, and classification | `IFloatingPoint` | `IScalarFloatingPoint` |
| Integer division, remainder, bitwise operations, and shifts | `IIntegerType` | `IScalarIntegerType` |
| Signed or unsigned integer behavior | `ISignedIntegerType`, `IUnsignedIntegerType` | corresponding `IScalar...` refinement |
| Component-wise equality | `IComponentwiseEquatable` | `IEquatable` when a scalar `bool` is required |
| Component-wise relational comparison | `IComponentwiseOrdered` | `IPartiallyOrdered` or `ITotallyOrdered` |
| One elementary-function family | corresponding independent family | add `IScalarShapedType` if scalar-only |
| All elementary-function families | `IElementaryFunctions` | `IScalarElementaryFunctions` |
| Fractional arithmetic, elementary functions, component-wise ordering, `min`, `max`, and `step` | `IReal` | `IScalarReal` |

Use capability conjunctions when appropriate.
For example, `IFractional & IRootFunctions` is preferable to `IReal` when the body needs arithmetic and square roots but no ordering or other elementary functions.

`IFloatingPoint` is not a synonym for real-number operations, and `IReal` does not require an IEEE floating-point representation.
Use `IPartiallyOrdered` for IEEE-style scalar comparisons and `ITotallyOrdered` only when the type guarantees a total order.

When a type parameter is used as the element of an explicitly constructed builtin vector or matrix, select the scalar-only refinement from the table.
The builtin shape can additionally require a sealed builtin-element constraint.
For a real-valued vector element, this can take the form `T : __BuiltinFloatingPointType & IScalarReal`.
Retain the public part so the numeric capability remains visible.

Cooperative-vector conformances and other shaped-type support can differ from ordinary vectors and matrices.
Probe the exact shaped type and express only the independent capabilities needed by the algorithm.

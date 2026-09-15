# Wave Intrinsics

Use this reference only when a port changes a wave operation or the type that flows into one.
Wave behavior depends on more than the intrinsic name, so inventory the following before editing:

- the value being communicated or reduced;
- the lane index, mask, or group from which it is read;
- any operation or mode discriminator that decides whether the wave operation runs;
- the fallback behavior when that discriminator selects another mode; and
- whether a wrapper is communicated as one value or component by component.

Preserve every branch of that protocol.
Do not replace a conditional wave read with an unconditional read, turn a fallback branch into a wave operation, change the lane expression, or return the input for every mode merely to compile.

Core wave intrinsics accept compiler-recognized builtin representations.
When a generic scalar element can be Boolean, integer, or floating-point, use the public `IBuiltinScalarTypeDispatchMarker` constraint rather than narrowing it to a numeric interface or spelling `__BuiltinType`.
The dispatch marker is appropriate here because the implementation calls a builtin-only intrinsic; it is not a substitute for an arithmetic capability.

If a user-defined aggregate must participate in a wave operation, preserve its logical value by applying the same wave operation and lane/mode protocol to every relevant field or component.
Do not reinterpret the aggregate as an unrelated builtin type.

Probe every meaningful source category admitted by the generic contract.
For a scalar-element wave helper, this commonly means at least one Boolean, signed or unsigned integer, and floating-point instantiation when the source admits those categories.

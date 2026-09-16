---
name: slang-port-hlsl-templates
description: Port HLSL C++-style template declarations and calls to native Slang generics while preserving type and value parameter domains. Use for template syntax, dependent extents, body-derived type contracts, or finite value-specialized overload families; use the numeric-generics skill when an inferred contract is numeric.
license: Apache-2.0 WITH LLVM-exception
---

# Port HLSL Templates to Slang Generics

Preserve the source algorithm and the full supported specialization domain.
Do not specialize only for visible call sites or delete dormant template declarations to make one entry point compile.

## Use semantic fidelity as the completion gate

Compilation is necessary evidence, but it is not completion.
Before the first edit, make a compact ledger that maps each source declaration, overload, type or
value parameter, operation, and mutation to its intended Slang counterpart.
Before reporting success, reopen the original and final source side by side and reject the port if
any ledger row fails one of these checks:

- Every requested declaration and materially distinct overload still has a real generic
  implementation.
- Independent source roles remain independently quantified unless the source contract proves that
  their types are equal; a concrete call where roles happen to share a type is not such proof.
- Every operation used by a generic body has a corresponding constraint, and every introduced
  interface requirement has a real implementation for each claimed conformance.
- Comparison operands, predicate direction, equality tests, index units, and returned values retain
  their source meaning.
- Every source mutation reaches the same logical storage before the same downstream observation;
  temporaries have explicit, complete writeback when needed.
- Finite value-specialized cases and uninstantiated but supported type categories remain expressible.

Use compiler diagnostics to repair typing and language differences, then perform this source audit
independently of whether the final compilation passes.

## Consult the companion guidance when its trigger applies

Treat the companion skills as required parts of this workflow, not optional references:

- Read and follow `slang-port-hlsl` when the input is a complete shader/module rather than an isolated template snippet, or when any diagnostic concerns HLSL-versus-Slang declarations, mutation, indexing, resources, entry points, or language mode instead of generic constraints.
- Read and follow `slang-numeric-generics` before choosing a constraint whenever a type parameter is used with arithmetic, comparison, conversion or construction, a numeric intrinsic, a vector or matrix constructor, or as the representation of a custom numeric type.
- Read [references/finite-value-dispatch.md](references/finite-value-dispatch.md) before changing a dependent array or a call from a value-generic body to a finite family of fixed-size overloads.

Apply every triggered companion before the first large source rewrite.
When the agent supports explicit skill loading, invoke each triggered skill by its exact name rather
than only searching the installed files for related terms.
If `slang-numeric-generics` cannot be loaded, use this conservative fallback: import
`slang.numerics`, use `IEquatable`, `IPartiallyOrdered`, or `ITotallyOrdered` for scalar comparison,
use the corresponding component-wise interfaces for shaped comparisons, and start broad arithmetic
ports with `IScalarReal` or `IReal` rather than a legacy numeric interface.
Record that the companion guidance was unavailable.

## Probe standard contracts before declaring local ones

Do not invent a project-local interface until the supplied compiler has rejected the closest
standard contract in a minimal probe.
This is a decision gate, not a documentation lookup: installed source files may omit declarations
and conformances embedded in the compiler's core module.
In particular, when a generic body only reads elements by integer index, compile the exact
`IArray<Element>` probe shown below before defining a custom read protocol.
If it succeeds, use `IArray<Element>` throughout the port; if it fails, preserve the diagnostic in
the porting log and introduce only the missing operation.

## Inventory the abstraction before editing

For every template declaration and call site, record:

- whether each parameter is a type or a value, and the type of each value parameter;
- dependent array extents, loop bounds, compile-time branches, and overload choices;
- operations required of each type parameter, including construction, copying, mutation, indexing, calls, operators, associated types or constants, and resource access;
- the intended specialization domain, including finite value cases not reached by the visible entry point.

Infer a type parameter's contract from the template body, documentation, and representative uses.
This is a porting analysis technique, not a request for the Slang compiler to infer generic constraints from a body.

## Port parameters directly when possible

Slang accepts type-first value-parameter syntax such as `<int N>`, `<uint N>`, and `<bool Enabled>`.
The equivalent `<let N : int>` spelling is also available.
Preserve dependent extents and compile-time values instead of replacing them with macros.

Leave a type parameter unconstrained when its body only stores, copies, or returns values.
Otherwise express the body-derived contract:

1. For numeric operations, follow the required `slang-numeric-generics` trigger above before selecting the constraint.
2. For a domain-specific contract, declare a small interface containing exactly the required operations.
3. Match static versus instance members, receiver mutation, default construction, associated types, associated constants, and read-versus-write access.
4. Constrain the type on which the operations are actually invoked.
   Constraining a wrapper's element does not automatically make the wrapper conform.
5. Validate the proposed contract in a small probe before restructuring a large shader.

Before declaring a project-local interface for read-only integer indexing, probe the built-in
`IArray<Element>` contract.
Arrays, vectors, matrices, structured buffers, and other standard containers already use it, and
newer toolchains may also provide it for read-only typed `Buffer<Element>` resources.
Use `getCount()` only when the algorithm needs the extent; a generic body may use only the inherited
read subscript.
If the exact resource type in the supplied toolchain does not conform, introduce one narrow adapter
or interface for the missing operation instead of assuming the conformance or broadening the
algorithm's requirements.
Do not infer that a core-module conformance is absent merely because it is not visible in installed
`.slang` source files; many built-in declarations are embedded in the compiler.
Compile an evaluation-only probe with the task's compiler and options, for example:

```slang
T readBuffer<T : ITexelElement>(Buffer<T> values, int index)
    where Buffer<T> : IArray<T>
{
    return values[index];
}
```

When that probe passes, prefer the standard contract even if the current algorithm does not call
every member such as `getCount()`.

Keep independent source parameters independent unless the source contract equates them.
A visible specialization where the buffer element, key, and comparator operand happen to be the
same type does not justify collapsing those roles in the generic port.
Model cross-type relationships with separate interface parameters, associated types, or an adapter
operation instead of forcing one type argument everywhere.

Give each generic body only the operations it uses.
Do not take the union of operations across several overloads or members and force every concrete
type through one catch-all interface.
Use small sibling interfaces or refinements when operation sets differ, and put default-strategy
constraints only on overloads that actually select that strategy.
If a concrete type has no meaningful implementation of a requirement, leave it nonconforming or
split the contract; never add an empty method, constant result, or dropped write to make it conform.

When the generic explicitly constructs `vector<T, N>`, `matrix<T, R, C>`, or another builtin shape, start with the public `IBuiltinScalar...` constraint matching the element capability; do not expose implementation-level `__Builtin...` markers in the port.
When the same storage abstraction must admit Boolean, integer, and floating-point elements for a builtin-only intrinsic, use `IBuiltinScalarTypeDispatchMarker` on the stored element type and put arithmetic capabilities on the operations that need them.
When the abstracted type itself is passed to `dot`, consider `IDotProduct`, which covers built-in numeric scalars and ordinary vectors and returns the logical scalar type.
These interfaces require `import slang.numerics;` and a compiler invocation with `-experimental-feature`.
If the task's compiler or standard modules do not provide them, report that compatibility boundary instead of silently substituting legacy constraints.

Read [references/contracts-and-extensions.md](references/contracts-and-extensions.md) when declaring interfaces, conformances, or constrained extensions.

Every generic parameter on an extension should be determined by the extended type.
When an additional type or value parameter is used only by one operation, declare it on that member.
The member can constrain its new parameter in terms of the extension's parameters, but it cannot add a new constraint to an existing extension parameter; use a free generic function when the natural contract requires both parameters to be constrained together.

## Separate storage domains from operation domains

Do not constrain an entire wrapper to the strongest operation used by one of its members.
A wrapper that stores both numeric values and Boolean masks can often remain generic over the builtin representation while arithmetic, ordering, reciprocal, or dot-product operations use free generic functions or constrained extensions for ordinary named methods.

Slang checks a generic body against its declared constraints before any concrete specialization proves more facts.
Leaving the body unconstrained is therefore invalid even when every visible call uses `float`.
Conversely, constraining the wrapper itself to `IScalarReal` or `IBuiltinScalarReal` excludes integer and Boolean instantiations from storage members that do not require real arithmetic.

Use this pattern when operations need a stronger contract than storage:

```slang
struct Packet<T : IBuiltinScalarTypeDispatchMarker, let N : int>
{
    vector<T, N> value;
}

Packet<T, N> operator+<T : IBuiltinScalarAdditive, let N : int>(
    Packet<T, N> left,
    Packet<T, N> right)
{
    return { left.value + right.value };
}
```

The free operator owns the stronger arithmetic contract while `Packet<bool, N>` remains a valid storage type.
Use a constrained extension for an ordinary named method when all its generic parameters are determined by the extended type.
Current Slang operator lookup does not reliably discover an operator declared only in a constrained extension, so port member operators that need stronger constraints as free generic operators and preserve the original operator syntax at call sites.
Do not append a `where` clause to a non-generic member in an attempt to strengthen an enclosing type parameter; move that member to a constrained extension, or to a free function when it is an operator or independently constrains multiple types.

## Preserve finite value-dependent overloads

A generic body is checked while a value parameter such as `N` is abstract.
A dependent `T[N]` therefore does not select overloads that separately accept only `T[1]`, `T[2]`, or `T[3]`.
Neither `static_assert` nor an ordinary `if (N == K)` refines `T[N]` to `T[K]` for overload resolution.

Use this decision order:

1. If the per-value bodies are instances of one algorithm, make the callee value-generic and express that algorithm directly with `N`.
   Preserve the original finite domain with `static_assert` or an equivalent caller constraint.
2. If the per-value bodies are materially different, retain them behind a dispatcher type whose conformance is specialized for each supported value.
   Constrain the generic caller on that conformance so unsupported values remain ill-formed.
3. If neither formulation is expressible without changing semantics, report the minimized language limitation.

Read [references/finite-value-dispatch.md](references/finite-value-dispatch.md) for complete patterns and a counterexample that does not refine a dependent type.

Do not expect a scalar-to-`vector<T, 1>` conversion to lift through an array or another generic wrapper.
For example, `T[N]` and `vector<T, 1>[N]` remain different parameter types.
Preserve the declared shape with an exact overload or an explicit element-wise adapter; if the value is passed by `inout` or aliases storage, confirm that copying and writing back preserves the source behavior.

## Preserve mutation across compatibility adapters

Treat every new temporary that replaces an HLSL `inout` argument, swizzle l-value, property, or
mutating generic receiver as a possible behavior change.
Prefer calling the mutating operation on the original variable when Slang permits it.
When Slang requires a temporary, copy the complete logical value in, perform the operation, and
write the complete modified value back before any downstream read that observed the mutation in the
source:

```slang
uint3 temporary = state.encoded.yzw;
reorder(temporary);
state.encoded.yzw = temporary;
```

Do not create a fresh copy inside a loop merely to satisfy a `[mutating]` call when the source passed
the persistent generic variable by `inout`; mutations to that copy would be discarded before the
next iteration.
If a copy is unavoidable, copy it back at the same semantic boundary as the source operation.

Before finishing, compare every source `inout` call with its final counterpart and record the
source storage, any temporary or copied receiver, the writeback, and the first downstream read.
Compilation cannot reveal a missing writeback when the affected path is inactive or when the stale
value remains well typed.

## Validate behavior, not just compilation

Run the supplied Slang compiler after each coherent change.
At completion, verify every requested entry point and emitted artifact, confirm that active HLSL template syntax is gone, and confirm that native generic abstractions remain.

Build a small semantic verification matrix from the inventory before declaring success:

- every requested template declaration still exists as a real generic abstraction;
- every materially different finite value case remains reachable;
- every operation family used by a type parameter is preserved, including conversions, comparisons, masks, indexing, mutation, and intrinsics;
- every meaningful source-domain category remains admitted by the constraints; and
- the original call sites and entry points still exercise the generic path.

Compile representative matrix rows with temporary probes when the harness permits it.
At minimum, compile the captured call and audit every uninstantiated row against the final source.
Do not add permanent test-only calls to the shader merely to force an instantiation.

Follow the concrete-path and source-diff audit in
[the base porting skill's semantic-validation reference](../slang-port-hlsl/references/semantic-validation.md).
In particular, inspect every changed predicate, guard, side effect, index unit, conversion, and
copyback, and trace each operation in a new interface through every relevant conformance.
Do not infer equality from comparator equivalence unless the source contract explicitly makes
those relations identical.
For each conformance, verify that every required method implements corresponding source behavior.
An empty or placeholder method is a semantic failure even when no current entry point instantiates
that path.

Prefer a readable sufficient constraint such as `IReal`, `IScalarReal`, or an appropriate `IBuiltinScalar...` alias over delaying or compromising a faithful port in pursuit of the narrowest possible interface.
Constraint precision is a maintainability concern; semantic success is the gate.

Never replace a body with a default result, bypass a wave or resource operation, discard a write, or narrow to a visible specialization to obtain a compile.
If a faithful port remains blocked, preserve the best coherent port, record the blocker, and fail honestly.

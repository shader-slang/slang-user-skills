# Validate semantic fidelity

Compilation proves that the final program is well typed for the compiled entry point and
configuration.
It does not prove that uninstantiated generic cases, inactive shader permutations, resource index
units, mutation paths, or adapter conformances preserve the source behavior.

Use this audit after the port compiles and before declaring success.

## Compare the source and final behavior

Generate or inspect a source diff that excludes logs, generated artifacts, and reports.
For every changed declaration or expression, classify the change as syntax-only, a necessary
compatibility adaptation, a generic-contract change, or an algorithm change.
An algorithm change requires explicit source evidence; a compiler diagnostic alone does not
justify one.

Check these high-risk edits directly:

- predicates, operand order, equality versus ordering, and scalar versus component-wise masks;
- guards around assignments, writes, barriers, wave operations, and other side effects;
- resource and array indices, including whether an index is measured in elements or bytes;
- conversions, constructor calls, component order, splats, and bit reinterpretation;
- receiver mutation, `inout` temporaries, aliasing, and explicit copyback; and
- returned values, output parameters, offsets, counts, and forwarding overloads.

For every final local initialized from an expression that the source passed by `inout`, trace the
local through the call and find the assignment that copies the modified value back to the original
storage.
For every copied generic receiver, verify that the source also used a copy; otherwise call the
mutating operation on the persistent variable or restore its complete state before the next
source-visible read or loop iteration.

Preserve the source predicate as written unless its contract establishes an equivalent
replacement.
In particular, `compare(a, b) == 0` is not evidence that `a == b`: a comparator can group distinct
values into the same ordering class.

## Trace abstractions to concrete behavior

For every introduced interface, protocol, adapter, wrapper, or helper:

1. List each operation that replaces source behavior.
2. Find every relevant concrete conformance or implementation, including ones reached only by an
   inactive permutation or an uninstantiated generic case.
3. Compare each implementation with the source operation it replaces.
4. Reject empty bodies, constant/default results, dropped writes, arbitrary finite-case fallbacks,
   or implementations that preserve only the currently compiled call.

Do not stop at the interface declaration.
A correct requirement can still be paired with a no-op or behavior-changing conformance.

## Exercise a representative matrix

Derive a small probe matrix from the source abstraction rather than from the visible call sites.
Choose rows that distinguish materially different behavior, such as:

- each supported finite value case and one unsupported case that should be rejected;
- signed, unsigned, floating-point, Boolean-mask, scalar, and shaped categories that the source
  meaningfully admits;
- each concrete protocol or adapter implementation;
- equality and inequality, or true and false control-flow outcomes;
- nonzero offsets, multiple indices or lanes, and multi-component values; and
- mutation paths where a temporary must be copied back.

Compile representative probes when the environment permits it.
When execution tests are unavailable, inspect the final bodies against every matrix row and record
which rows have only static evidence.
Do not claim that one compiled specialization establishes the rest of the generic domain.

## Record the completion audit

Before the final report, record:

- which source/final diff was reviewed;
- which concrete implementations and call paths were traced;
- which matrix rows compiled, executed, or received only a source audit; and
- any remaining semantic uncertainty or compiler/library limitation.

The report should summarize this evidence, not substitute for performing the audit.

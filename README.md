# Slang User Skills

This repository contains agent skills for writing Slang code and working with Slang tools.
Its contents are intended for Slang users; contributor workflows for developing the Slang compiler belong elsewhere.

The repository follows the [Agent Skills specification](https://agentskills.io/specification).
Skills live under `skills/` and can be discovered by tools that support that specification.

## Available skills

- `slang-port-hlsl` covers general language and compiler differences encountered while porting HLSL to native Slang.
- `slang-port-hlsl-templates` covers translation of HLSL templates into Slang generics.
- `slang-numeric-generics` covers Slang's experimental capability-oriented numeric interfaces.

The skills are under active development and have not yet reached a stable release.
In particular, the numeric interfaces currently require a Slang build that provides `slang.numerics` and enables experimental features.

## Installation

With a version of GitHub CLI that provides `gh skill`, install all skills for Codex at user scope with:

```sh
gh skill install shader-slang/slang-user-skills --all --agent codex --scope user
```

Omit `--scope user` to install into the current project.
Install one skill by replacing `--all` with its name, for example `slang-port-hlsl-templates`.

## Validation

Validate the repository structure with:

```sh
python scripts/validate-skills.py
gh skill publish --dry-run
```

Validate the Slang examples against a selected compiler with:

```sh
python scripts/validate-examples.py --slangc /path/to/slangc
```

The example validator passes `-lang slang` and `-experimental-feature`.

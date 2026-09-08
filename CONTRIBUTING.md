# Contributing to Slang User Skills

This repository contains skills for people using the Slang language, compiler, tools, APIs, or standard modules.
Workflows for developing or maintaining the Slang implementation belong in the appropriate contributor repository instead.

## Requirements for a skill change

- Follow the [Agent Skills specification](https://agentskills.io/specification), including matching the skill directory and frontmatter `name`.
- Include `license: Apache-2.0 WITH LLVM-exception` in each `SKILL.md`.
- Add `compatibility` frontmatter when a skill requires a particular Slang feature, compiler generation, command-line option, external tool, or network access.
- Keep relative references inside the skill directory and verify that every link resolves.
- Add focused examples for language or tool behavior that can be checked mechanically.
- Keep scripts self-contained, document their dependencies and side effects, and avoid modifying user or agent configuration without an explicit user request.

When a skill depends on unreleased Slang behavior, say so in both its compatibility metadata and its instructions.
The Slang repository will separately decide when to pin that skill commit for a compiler release.

## Validate locally

Run the repository-controlled structural checks and the `gh skill` compatibility check:

```sh
python scripts/validate-skills.py
gh skill publish --dry-run
```

When examples are affected, validate them with a compatible compiler:

```sh
python scripts/validate-examples.py --slangc /path/to/slangc
```

The Slang integration additionally runs these examples when its pinned user-skills commit changes.

## Review and publication

Submit changes through a pull request and request review from the configured code owners.
Treat skill instructions and bundled scripts as executable-adjacent content: review their provenance, commands, dependencies, and possible side effects accordingly.

Stable releases of this repository use their own semantic versions and release cadence.
They are not created as a side effect of publishing a Slang compiler release.

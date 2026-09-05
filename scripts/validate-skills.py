#!/usr/bin/env python3
"""Validate repository skill layout without external dependencies."""

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILLS_ROOT = ROOT / "skills"
NAME_PATTERN = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
LINK_PATTERN = re.compile(r"\[[^]]+\]\(([^)]+)\)")


def parse_frontmatter(path: Path) -> tuple[dict[str, str], list[str]]:
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0] != "---":
        return {}, ["missing opening YAML frontmatter marker"]
    try:
        end = lines.index("---", 1)
    except ValueError:
        return {}, ["missing closing YAML frontmatter marker"]

    values: dict[str, str] = {}
    errors: list[str] = []
    for line in lines[1:end]:
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if ":" not in line:
            errors.append(f"unsupported frontmatter line: {line!r}")
            continue
        key, value = line.split(":", 1)
        values[key.strip()] = value.strip().strip("'\"")
    return values, errors


def validate_skill(skill: Path) -> list[str]:
    errors: list[str] = []
    entrypoint = skill / "SKILL.md"
    if not entrypoint.is_file():
        return [f"{skill}: missing SKILL.md"]

    frontmatter, frontmatter_errors = parse_frontmatter(entrypoint)
    errors.extend(f"{entrypoint}: {error}" for error in frontmatter_errors)
    name = frontmatter.get("name", "")
    description = frontmatter.get("description", "")
    if name != skill.name:
        errors.append(f"{entrypoint}: name {name!r} does not match directory {skill.name!r}")
    if not NAME_PATTERN.fullmatch(name) or len(name) > 64:
        errors.append(f"{entrypoint}: invalid Agent Skills name {name!r}")
    if not description or len(description) > 1024:
        errors.append(f"{entrypoint}: description must contain 1 through 1024 characters")

    for markdown in skill.rglob("*.md"):
        text = markdown.read_text(encoding="utf-8")
        for target in LINK_PATTERN.findall(text):
            if "://" in target or target.startswith("#"):
                continue
            relative_target = target.split("#", 1)[0]
            if relative_target and not (markdown.parent / relative_target).exists():
                errors.append(f"{markdown}: broken relative link {target!r}")
    return errors


def main() -> int:
    if not SKILLS_ROOT.is_dir():
        print(f"missing skills directory: {SKILLS_ROOT}", file=sys.stderr)
        return 1

    skills = sorted(path for path in SKILLS_ROOT.iterdir() if path.is_dir())
    if not skills:
        print(f"no skills found under {SKILLS_ROOT}", file=sys.stderr)
        return 1

    errors = [error for skill in skills for error in validate_skill(skill)]
    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1

    print(f"Validated {len(skills)} skills.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

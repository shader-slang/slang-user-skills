#!/usr/bin/env python3
"""Compile every Slang example against a selected compiler."""

from __future__ import annotations

import argparse
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EXPECTED_FAILURES = {
    "sealed-builtin-negative.slang": "__BuiltinArithmeticType",
}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--slangc", required=True, type=Path)
    parser.add_argument("--skills", type=Path, default=ROOT / "skills")
    args = parser.parse_args()

    examples = sorted(args.skills.glob("*/references/examples/*.slang"))
    if not examples:
        parser.error(f"no examples found under {args.skills}")

    failures: list[Path] = []
    with tempfile.TemporaryDirectory(prefix="slang-skill-examples-") as temporary_directory:
        output_directory = Path(temporary_directory)
        for index, source in enumerate(examples):
            command = [
                str(args.slangc),
                str(source),
                "-lang",
                "slang",
                "-experimental-feature",
                "-target",
                "spirv",
                "-entry",
                "main",
                "-stage",
                "compute",
                "-o",
                str(output_directory / f"{index:02d}-{source.stem}.spv"),
            ]
            completed = subprocess.run(command, capture_output=True, text=True, timeout=180)
            diagnostic = completed.stdout + completed.stderr
            expected_diagnostic = EXPECTED_FAILURES.get(source.name)
            if expected_diagnostic is None:
                passed = completed.returncode == 0
                expectation = "compile"
            else:
                passed = completed.returncode != 0 and expected_diagnostic in diagnostic
                expectation = "expected rejection"

            status = "PASS" if passed else "FAIL"
            print(f"{status}: {source.relative_to(args.skills)} ({expectation})")
            if not passed:
                failures.append(source)
                sys.stderr.write(diagnostic)

    if failures:
        print(f"{len(failures)} example validation failure(s)", file=sys.stderr)
        return 1
    print(f"Validated {len(examples)} examples.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

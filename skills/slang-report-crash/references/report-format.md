# Crash report format

A report is plain text. It has one header line and four sections.

```text
==== Slang crash report (format 1) ====
Slang stopped because of a bug in Slang, not in your code.
This report is plain text. Slang wrote it on this machine and sent it nowhere.

[report]
kind:        internal-error
signal-type: unexpected
location:    slang-example.cpp:42
slang:       2026.22.1
host:        linux-aarch64
front-end:   slangc
signature:   ice-d1a8d0d9

[stack]
#0  libslang-compiler.so+0x102dc
#1  libslang-compiler.so+0x10104

[details]
This part can hold names from your code. Read it before you share the report.
message:     unexpected: unhandled case for 'MyMaterial'

[how to report]
Known bug?   https://github.com/shader-slang/slang/issues?q=%22ice-d1a8d0d9%22
Report it:   https://github.com/shader-slang/slang/issues/new?template=crash-report.yml
```

## Sections

- `[report]` holds only values that Slang defines. It is safe to publish.
  - `kind`: `internal-error`, or `crash` for a signal such as a segmentation fault.
  - `signal-type`: the class of internal error.
  - `signal`: the signal name. It appears when `kind` is `crash`.
  - `location`: the file and line inside Slang where the error was raised.
  - `slang`: the Slang version.
  - `host`: the operating system and CPU family.
  - `front-end`: the program that hosted Slang, for example `slangc`.
  - `signature`: a short identifier for the bug. It starts with `ice-` for an internal error and `crash-` for a crash.
- `[stack]` holds return addresses as `module+0xoffset`, one per frame. It holds no argument values and no memory.
- `[details]` holds the error message and, when present, the command line. These can contain identifiers, file paths, user names, or project names.
- `[how to report]` holds two links: one that searches for the signature and one that opens the report form.

## Not in a report

Slang does not write source text, memory contents, environment variables, the user name, the machine name, or the exact time.

## Complete versus cut off

A complete report has the header line and all four section headings in order.
A report is cut off when a heading is missing or the last line of `[how to report]` is absent.
Later versions can add lines inside a section. Keep unknown lines as they are.

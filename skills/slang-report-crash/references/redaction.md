# Redaction checklist

Apply these checks to `[details]` and to any reproducer the user wants to attach.
In `[report]` and `[stack]`, check only for the name of the user's own application: the `front-end:` value and the module names of the stack frames.

## What to look for

| Kind | Examples | Placeholder |
| --- | --- | --- |
| Home directory or user name | `/Users/alex/...`, `C:\Users\alex\...`, `/home/alex/...` | `<path>` |
| Host or machine name | `build-box-17`, `alex-laptop.local` | `<host>` |
| Project, product, or codename | `Project Aurora`, `AcmeEngine`, a type named after a product | `<name>` |
| Company-internal path or URL | `//depot/acme/...`, `https://git.corp.example/...`, `\\fileserver\share` | `<path>` or `<url>` |
| Key, token, or password | `ghp_...`, `AKIA...`, `password=...`, long random strings | `<secret>` |
| Email address | `alex@acme.example` | `<email>` |
| Customer or partner name | a customer name inside a path or identifier | `<name>` |

Identifiers that come from Slang itself, such as `float4` or `StructuredBuffer`, are not findings.
Ask the user when a name could be either a public term or a private one.

## How to redact

- Replace the smallest span that holds the finding.
- Use the same placeholder for the same value everywhere, so the message keeps its meaning.
- Replace a whole path, directory and file name together. Keep the file extension, so the reader still knows the kind of file: `/Users/alex/acme/shaders/skin.slang` becomes `<path>.slang`.
- Do not guess. When unsure, list the span as a finding and let the user decide.

## Worked example

Before:

```text
[details]
This part can hold names from your code. Read it before you share the report.
message:     unexpected: unhandled case for 'AuroraMaterial'
command:     slangc /Users/alex/acme/aurora/shaders/skin.slang -target spirv -I /Users/alex/acme/aurora/include
```

Findings:

```text
line 3: 'AuroraMaterial'                           (project name)
line 4: /Users/alex/acme/aurora/shaders/skin.slang (home directory, user name)
line 4: /Users/alex/acme/aurora/include            (home directory, user name)
```

After, with the user's choice "redacted":

```text
[details]
This part can hold names from your code. Read it before you share the report.
message:     unexpected: unhandled case for '<name>'
command:     slangc <path>.slang -target spirv -I <path>
```

`[report]`, `[stack]`, and `[how to report]` stay as they were.

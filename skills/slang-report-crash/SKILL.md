---
name: slang-report-crash
description: Find, review, redact, and file the plain-text crash report that Slang writes when slangc or the Slang library stops on an internal compiler error or a crash. Use when a user says slangc crashed, reports a Slang internal error, or asks for help reporting a Slang crash.
license: Apache-2.0 WITH LLVM-exception
compatibility: Requires a Slang build that writes crash reports (a report starts with "==== Slang crash report"). Searching issues and filing need network access; creating an issue for the user needs an authenticated GitHub CLI.
---

# Report a Slang Crash

Help the user turn a Slang crash report into a safe, useful GitHub issue.
The report is plain text. Slang wrote it on the user's machine and sent it nowhere.
The user decides what leaves the machine.
Work through the six steps in order.

## Hard rules

- Never upload, post, attach, or send anything until the user confirms the exact final text in this conversation.
- Never include a source file unless the user names it.
- Never add, change, or "fix" a value in `[report]` or `[stack]`. The one permitted change is hiding the name of the user's own application, as step 4 describes.
- If the report is missing or cut off, say so and ask the user to run the failing command again.
  Do not rebuild a report from memory, from the terminal scroll-back, or from guesses.
- Do not search the user's disk for secrets beyond the report and the files the user names.

## 1. Find the report

Use the first source that applies:

1. A path or pasted text from the user.
2. The newest file matching `slang-report-*.txt` in the working directory.
   Sort by modification time and confirm the choice if several are close in age.
3. The block in terminal output that starts at the line `==== Slang crash report` and ends after the last line of `[how to report]`.

A complete report has a header line, then `[report]`, `[stack]`, `[details]`, and `[how to report]`.
If a section is missing, or the text stops early, follow the rule above and stop.
Read [references/report-format.md](references/report-format.md) for the layout.

## 2. Show it and explain it

Print the whole report to the user.
Then explain each part in plain words:

- `[report]`: values that Slang itself defines. The kind of failure, the source location inside Slang, the Slang version, the host platform, and a signature that names this bug. Safe to publish.
- `[stack]`: where Slang was running, as `module+0xoffset` addresses. No argument values and no memory. Safe to publish.
- `[details]`: the error message, and the command line when present. This part can hold names from the user's code.
- `[how to report]`: a link to search for this bug and a link to the report form.

State what Slang never puts in the file: source text, memory contents, environment variables, the user name, the machine name, and the exact time.
Say that identifiers, paths, and project names can still appear inside `[details]`.

## 3. Check for personal or confidential content

Scan `[details]` line by line.
Also scan every reproducer the user wants to attach.
Look for the kinds of content listed in [references/redaction.md](references/redaction.md).

Report the findings as a list.
Give each finding its line number, the exact text, and the kind, for example `line 14: "/Users/alex/acme/shaders/skin.slang" (home directory, user name)`.
If nothing is found, say so and name what you checked.

Then read the module names in `[stack]` and the `front-end:` value in `[report]`.
When Slang runs inside the user's own application, these two places name that application.
List every module that is not a Slang binary (`slangc`, `slangd`, a name that starts with `slang` or `libslang`) and not a system library, and list a `front-end:` value that is not `slangc` or `slangd`.
Ask the user whether each name may be published.
Do not change anything else in `[report]` or `[stack]`.

## 4. Offer a redacted version

Offer three choices:

1. **Redacted**: `[details]` with each finding replaced by a neutral placeholder such as `<path>`, `<name>`, `<url>`, `<email>`, or `<secret>`.
2. **Original**: `[details]` exactly as written.
3. **Dropped**: no `[details]` section. The report still identifies the bug through its signature and stack.

Show a before and after of every changed line.
Use one placeholder per kind and keep the rest of the line, so the message stays readable.
Apply the choice to a copy. Do not edit the original file unless the user asks.
Keep `[report]`, `[stack]`, and `[how to report]` byte for byte as they are, with one exception.
If the user does not want an application name from step 3 published, replace that module name in `[stack]` with `<module>` and that `front-end:` value with `<application>`.
Keep every offset, every other line, and the signature unchanged.

## 5. Search for the signature

Take the value after `signature:` in `[report]`.
Search the issues of `shader-slang/slang` for it, read-only.
Use the link in `[how to report]`, or run `gh search issues --repo shader-slang/slang "<signature>" --json number,title,state,url`.

Show every match with its title, state, and link.
If an issue matches the signature, offer to add the report to it as a comment instead of opening a duplicate.
If nothing matches, say so and go on.
If the search is not possible, give the user the search link and go on.

## 6. File the report

File only after the user confirms the exact final text.
Show the final text, name where it will go, and ask for a clear yes.
Treat silence, a question, or a request for changes as no.

Choose the route by what the user wants:

- **Link and paste** (default): give the user the report-form link and the text to paste.
  The link is `https://github.com/shader-slang/slang/issues/new?template=crash-report.yml`.
- **You file it**: only if the user asks and `gh auth status` succeeds.
  The GitHub CLI cannot fill an issue form, so write the body with the form's three headings: `### Crash report` with the confirmed text in a `text` code fence, then `### Reproducer` and `### Additional context`, each with the user's text or `_No response_`.
  Save the body to a file and run `gh issue create --repo shader-slang/slang --title "[crash report] <signature>" --body-file <file>`.
  For an existing issue, run `gh issue comment <number> --repo shader-slang/slang --body-file <file>` with the same body.
  Show the resulting link.
- **Code that cannot be public**: do not file anything.
  Tell the user to give the same confirmed text to their internal tracker or to their Slang contact.
  The report without `[details]` is the safest text to hand over.

Example of the confirmation message:

```text
Here is the exact text I will post as a new issue in shader-slang/slang
(no matching issue was found for ice-d1a8d0d9):

  <final report text>

[details] is redacted: 2 paths and 1 name were replaced.
Nothing has been sent. Reply "yes, post it" to create the issue,
or tell me what to change.
```

After filing, show the issue link and remind the user to attach a reproducer only when they are free to share it.
Name the files you would suggest and let the user choose.

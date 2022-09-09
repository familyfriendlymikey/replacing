## What Is This

`replacing` (`rp`) takes lines of file paths from stdin and prints their contents,
- optionally printing lines with text matching an ECMAScript regex pattern,
- optionally printing with replacements,
- optionally modifying the input files.

## Installation
```
npm i -g replacing
```

## Usage
The argument parsing for `rp` is positional, and any configuration other than what is specified here will throw.
```
cmd | rp [PATTERN [REPLACEMENT [MODIFY [FORCE]]]]
```
- If 0 arguments, simply print the contents of the files passed through stdin.
- If 1 argument, print lines with text matching the specified regex pattern.
- If 2 arguments, print matching text with replacements.
- If the 3rd argument is `-M`, and the working git directory is clean, modify the input files accordingly.
- If the 4th argument is `-F`, modify the input files regardless of git status.

## Examples

Print file contents of piped paths:
```
fd | rp
```

Print lines matching pattern `config`:
```
fd | rp 'config'
```

Print lines replacing matched pattern `config` with text `store.config`:
```
fd | rp 'config' 'store.config'
```

Modify files replacing matched pattern `config` with text `store.config`:
```
fd | rp 'config' 'store.config' -M
```

Modify regardless of git status:
```
fd | rp 'config' 'store.config' -M -F
```

Lookarounds and word boundaries work. Print lines matching the WORD `config` not after `store.`, replacing the WORD config with `store.config`:
```
fd | rp '(?<!store\.)\bconfig\b' 'store.config'
```

You can use all of the features of the piping program to narrow down your search.
For example, to only list files (so no directories),
and exclude any file containing `store`:
```
fd -t f -E '*store*'
```

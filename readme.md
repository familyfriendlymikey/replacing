## What Is This

`replace` (`rp`) takes lines of file paths from stdin and prints their contents,
- optionally printing lines with text matching an ECMAScript regex pattern,
- optionally printing with replacements,
- optionally modifying the input files.

Given that it is trivial to commit any currently existing changes to git,
`rp` will not so much as run unless your working git directory is clean.
If you want to run `rp` anyways, supply `--force` as the *very first* argument.

## Installation
```
npm i -g replacing
```

## Usage
```
rp [PATTERN] [REPLACEMENT] [FLAGS]
```
- If 0 arguments, simply print the contents of the files passed through stdin.
- If 1 argument, print lines with text matching an ECMAScript regex pattern.
- If 2 arguments, print lines with matching text with replacements.
- If the third argument is `-M`, modify the input files accordingly.

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

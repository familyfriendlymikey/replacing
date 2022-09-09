## What Is This

`replacing` (`rp`) takes lines of file paths from stdin, and incrementally
- prints lines with text matching an ECMAScript regex pattern,
- prints replacements, and
- modifies the input files.

## Installation
```
npm i -g replacing
```

## Usage
The argument parsing for `rp` is positional, and any configuration other than what is specified here will throw.
```
cmd | rp [PATTERN [REPLACEMENT [MODIFY [FORCE]]]]
```
- If 0 arguments, simply print the sorted file paths passed through stdin.
- If 1 argument, print lines with text matching the specified regex pattern.
- If 2 arguments, print matching text with replacements.
- If the 3rd argument is `-M` and you are in a clean working git directory, modify the input files accordingly.
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

Lookarounds and word boundaries work. Print lines matching the *word* `config` not after `store.`, replacing with `store.config`:
```
fd | rp '(?<!store\.)\bconfig\b' 'store.config'
```

## Tips

### Excluding Files
You can use all of the features of the piping program to narrow down your search.
For example, to exclude any file beginning with `store`:
```
fd -E store\*
```

### Clearing Scrollback
Part of the usefulness of this program is the ability to revise and view new changes.
Without clearing the terminal's scrollback buffer, that can get a little messy.
You might consider aliasing `fd` or whatever program you're using to clear the scrollback first:
```
alias fd='clear && fd'
```
If running `clear` doesn't clear your terminal's entire scrollback buffer, you can try:
```
alias fd='printf "\033c" && fd'
```

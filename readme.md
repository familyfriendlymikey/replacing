## What Is This

This is a search and replace tool that supports searching files with an ECMAScript regex pattern,
replacing that pattern with a string, and after printing to ensure everything is correct,
modifying the input files with replacements.

## Installation
```
npm i -g replacing
```

## Usage
```
cmd | rp [PATTERN [REPLACEMENT [MODIFY [FORCE]]]]
```
The argument parsing for `rp` is positional and depends on the number of arguments provided:

0. Simply print the sorted file paths passed through stdin.
1. Print lines with text matching the specified regex pattern. Default flags are `gi`.
To specify custom flags, end your pattern with `/flags`. Ending your pattern with `/` indicates no flags.

2. Print with replacements. Ampersands (`&`) in the replacement string will be substituted with the corresponding match.
Literal ampersands can be specified with `\&`.
3. Modify the input files accordingly. This argument *must* be `-M` and you must be in a clean working git directory.
4. Forcibly modify the input files regardless of git status. This argument *must* be `-F`.

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

Same as above:
```
fd | rp 'config' 'store.&'
```

Modify files, replacing matched pattern `config` with text `store.config`:
```
fd | rp 'config' 'store.&' -M
```

Forcibly modify regardless of git status:
```
fd | rp 'config' 'store.&' -M -F
```

Lookarounds and word boundaries work. Print lines matching the *word* `config` not after `store.`, replacing with `store.config`:
```
fd | rp '(?<!store\.)\bconfig\b' 'store.&'
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

## Replacing

This is a super lightweight CLI for searching and replacing file contents with
ECMAScript regex.

`replacing` does as little in the way of custom logic as possible. In fact, it
does not even search and replace linewise, it simply calls `replaceAll` on the
entire input text and prints the linewise diff.

## Installation

```sh
npm i -g replacing
```

Requires bun:

```sh
curl -fsSL https://bun.sh/install | bash
```

`replacing` expects lines of files piped through stdin. A great candidate for
this is [fd](https://github.com/sharkdp/fd). The rest of this readme will
assume the following shell alias:

```sh
alias r='fd|replacing'
```

## Usage

```
r [PATTERN [REPLACEMENT [MODIFY]]]
```

The argument parsing for `rp` is positional and depends on the number
of arguments provided:

0. Simply print the sorted file paths passed through stdin.

1. Print lines with text matching the specified regex pattern. Default flags
	 are `gm`, plus `i` if the pattern is all lowercase (smartcase). To specify
	 custom flags, end your pattern with `\/flags`. Ending your pattern with `\/`
	 indicates no flags.

2. Print with replacements. Ampersands (`&`) in the replacement string
	 will be substituted with the corresponding match. Literal
	 ampersands can be specified with `\&`.

3. Modify the input files accordingly with `-m`. You must be in a clean working
	 git directory.

	 If you want to forcibly modify the input files regardless of git status,
	 specify `-mf`.

### Examples

Print the piped file paths:

```sh
r
```

Print lines matching pattern `config`:

```sh
r config
```

Print lines replacing matched pattern `config` with text `store.config`:

```sh
r config store.config
```

Substitute back in the matching string with `&`. This has the same result as
the above example:

```sh
r config 'store.&'
```

Modify files, replacing matched pattern `config` with text `store.config` if
git status is clean:

```sh
r config 'store.&' -m
```

Forcibly modify regardless of git status:

```sh
r config 'store.&' -mf
```

Lookarounds and word boundaries work. Print lines matching the *word* `config`
not after `store.`, replacing with `store.config`:

```sh
r '(?<!store\.)\bconfig\b' 'store.&'
```

## Tips

### Clearing Scrollback

You might consider aliasing `fd` or whatever file-listing program you're using
to clear the scrollback first:

```sh
alias fd="printf '\33c\e[3J' && fd"
```

### Excluding Files

You can use all of the features of the piping program to narrow down your
search. For example, to exclude any file beginning with `store`:

```sh
fd -E 'store*' | replacing
```

### Git Working Directory Usage

You might find it cumbersome to commit any changes before making modifications.
One option is to make a commit before running replacing, then after making
modifications, you can just shove unstaged changes into the previous commit:

```sh
alias gfixup='git commit -a --amend --no-edit'
```

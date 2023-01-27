## What Is This

This is a super lightweight search and replace tool.

Simply put, the incremental workflow is:

```
list files -> print matches -> replace matches -> make modifications
```

`replacing` does as little in the way of custom logic as possible. In
fact, `replacing` does not even search and replace linewise; the
entire modification behavior of this program boils down to the
following code:

```imba
const data = readFileSync(filename).toString!
let new_data = data.replace(pattern) do
	replacement.replaceAll(/(?<!\\)&/g,$1).replaceAll('\\&','&')
writeFileSync(filename, new_data)
```

## Installation

```sh
npm i -g replacing
```

Requires bun:

```sh
curl -fsSL https://bun.sh/install | bash
```

## Usage

```
cmd | replacing [PATTERN [REPLACEMENT [MODIFY [FORCE]]]]
```

`replacing` expects lines of files piped through stdin.
A great candidate for this is [fd](https://github.com/sharkdp/fd).

The rest of this readme will assume the use of the following shell
alias:

```sh
alias r='fd|replacing'
```

The argument parsing for `rp` is positional and depends on the number
of arguments provided:

0. Simply print the sorted file paths passed through stdin.

1. Print lines with text matching the specified regex pattern. Default
	 flags are `gi`. To specify custom flags, end your pattern with
	 `\/flags`. Ending your pattern with `\/` indicates no flags.

2. Print with replacements. Ampersands (`&`) in the replacement string
	 will be substituted with the corresponding match. Literal
	 ampersands can be specified with `\&`.

3. Modify the input files accordingly. This argument *must* be `-M`
	 and you must be in a clean working git directory.

4. Forcibly modify the input files regardless of git status. This
	 argument *must* be `-F`.

## Examples

Print the piped file paths, filtered to existing files only and sorted
alphabetically:

```sh
r
```

Print lines matching pattern `config`:

```sh
r 'config'
```

Print lines replacing matched pattern `config` with text `store.config`:
```sh
r 'config' 'store.config'
```

Same as above:
```sh
r 'config' 'store.&'
```

Modify files, replacing matched pattern `config` with text `store.config`:
```sh
r 'config' 'store.&' -M
```

Forcibly modify regardless of git status:
```sh
r 'config' 'store.&' -M -F
```

Lookarounds and word boundaries work. Print lines matching the *word* `config` not after `store.`, replacing with `store.config`:
```sh
r '(?<!store\.)\bconfig\b' 'store.&'
```

## Tips

### Clearing Scrollback

Part of the usefulness of this program is the ability to revise and
view new changes. If your scrollback buffer has several iterations of
searches and replacements, it can feel a little messy. You might
consider aliasing `fd` or whatever file-listing program you're using
to clear the scrollback first:

```sh
alias fd="printf '\33c\e[3J' && fd"
```

### Excluding Files

You can use all of the features of the piping program to narrow down
your search. For example, to exclude any file beginning with `store`:

```sh
fd -E store\*
```

## Tips

### Git Working Directory Usage

You might find it annoying to make a commit before modifying.
Something to speed that up is an alias like this:

```sh
alias gfixup='git commit -a --amend --no-edit'
```

This just shoves all modifications into the previous commit. So, you
can make a commit for your changes before running `rp`, which you
would have done anyways, and then after running `rp`, once you make
sure the changes look good, you can just run `gfixup`.

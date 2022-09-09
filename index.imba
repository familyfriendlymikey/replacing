const p = console.log
const green = "\x1b[32m"
const pink = "\x1b[35m"
const red = "\x1b[31m"
const cyan = "\x1b[36m"
const clear = "\x1b[0m"

const help = '''
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
'''

let { readFileSync, writeFileSync } = require 'fs'
let { execSync } = require 'child_process'

let args = process.argv.slice(2)

main!

def main

	try
		let clean = !execSync 'git status --porcelain', { encoding: 'utf8' }
		throw '' unless (clean or args.shift! is '--force')
	catch
		return p "{help}\n\n{red}Git working directory is not clean, quitting.{clear}"

	let files
	try
		files = readFileSync(process.stdin.fd, 'utf8').trim!.split("\n")
	catch
		return p "{help}\n\n{red}Failed to read stdin, quitting.{clear}"
	
	let pattern
	let replacement
	let modify

	if args.length >= 1
		pattern = new RegExp args[0], "g"
		p "\nPATTERN: {cyan}{pattern}{clear}"

	if args.length >= 2
		replacement = args[1]
		p "\nREPLACEMENT: {cyan}{replacement}{clear}"

	if args.length >= 3
		if args.length is 3 and args[2] is '-M'
			modify = yes
		else
			return p "{help}\n\n{red}Invalid args, quitting.{clear}"

	for filename in files

		let data
		try
			data = readFileSync(filename, 'utf8')
		catch
			p "\n{red}Error reading path, skipping:{clear} {filename}"
			continue

		unless pattern
			p "\n{pink}{filename}{clear}"
			p data
			continue

		let lines = data.split("\n").filter do pattern.test($1)
		continue unless lines.length >= 1

		p "\n{pink}{filename}{clear}"
		let s = lines.join("\n").replaceAll(pattern) do "{green}{replacement or $1}{clear}"
		p s

		continue unless modify
		let new_data = data.replaceAll pattern, replacement
		writeFileSync(filename, new_data)

global.L = console.log

extend class String
	get green
		"\x1b[32m{self}\x1b[0m"
	get yellow
		"\x1b[33m{self}\x1b[0m"
	get pink
		"\x1b[35m{self}\x1b[0m"
	get red
		"\x1b[31m{self}\x1b[0m"
	get cyan
		"\x1b[36m{self}\x1b[0m"
	get blue
		"\x1b[34m{self}\x1b[0m"

global.E = do
	L "\nSee README for usage instructions: https://github.com/familyfriendlymikey/replacing\n"
	L "{$1}, quitting.\n".red
	process.exit!

const fs = require "fs"
const cp = require "child_process"
const { diffLines } = require "diff"

def main

	L!

	try
		var files = fs.readFileSync("/dev/stdin", "utf8").trim!.split("\n").sort!
	catch e
		E "Failed to read stdin:\n\n{e}"

	let args = process.argv.slice(2)
	let arg

	let pattern = args.shift!
	if typeof pattern is "string"
		let [re, flags] = pattern.split(/\\\//)
		try
			let default-flags = /[A-Z]/.test(re) ? 'gm' : 'gim'
			pattern = new RegExp(re, flags ?? default-flags)
		catch
			E "Invalid regex"
		L "PATTERN: {pattern}".blue

	let substitute-match
	let replacement = args.shift!
	if typeof replacement is "string"
		L "\nREPLACEMENT: {replacement}".blue
		substitute-match = do
			replacement.replaceAll(/(?<!\\)&/g,$1).replaceAll("\\&","&")
	else
		substitute-match = do $1

	let modify
	let force
	if arg = args.shift!
		if arg is "-m"
			modify = yes
		elif arg is "-mf"
			modify = force = yes
		else
			E "Invalid args"

	if modify and not force
		try
			if cp.execSync("git status --porcelain", { stdio: "pipe" }).toString!
				E "Git working directory is not clean (-mf to force)"
		catch e
			E "Failed to check git status (-mf to force)"

	E "Invalid args" if args.shift!

	let errors = []

	for filename in files

		try
			continue unless fs.statSync(filename).isFile!
		catch e
			errors.push "{e}"
			continue

		unless pattern
			L filename.pink
			continue

		let temp
		try
			temp = fs.readFileSync(filename,'utf8')
		catch e
			errors.push "{e}"
			continue
		const data = temp

		let replaced = data.replace(pattern) do
			substitute-match($1).green

		let to-print = ""
		diffLines(data, replaced).forEach do
			if $1.added
				if $1.value.length < 1000
					to-print += $1.value
				else
					to-print += "[Omitted line with > 1000 chars]".yellow
					to-print += "\n" # can't trim if this is wrapped with yellow
		continue unless to-print.length >= 1
		L "\n{filename.pink}\n{to-print.trim!}"

		continue unless modify
		try
			let new-data = data.replace(pattern, substitute-match)
			fs.writeFileSync(filename, new-data)
			L "Successfully wrote file".cyan
		catch e
			L "Failed to write file, see errors below".red
			errors.push "{e}"

	if errors.length > 0
		L "{errors.join("\n\n")}\n".red

main!

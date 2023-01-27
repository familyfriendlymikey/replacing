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

const { readFileSync, writeFileSync, statSync } = require "fs"
const { execSync } = require "child_process"
const { diffLines } = require "diff"

def quit
	L "\nSee README for usage instructions: https://github.com/familyfriendlymikey/replacing\n\n"
	L "{$1}, quitting.\n".red
	process.exit!

def main

	let output = "\n"

	try
		var files = readFileSync("/dev/stdin", "utf8").trim!.split("\n").sort!
	catch e
		return quit "Failed to read stdin:\n\n{e}"

	let args = process.argv.slice(2)

	if typeof (let pattern = args.shift!) is "string"
		let [re, flags] = pattern.split(/(?<!\\)\//)
		try
			pattern = new RegExp(re, flags ?? "gi")
		catch
			return quit "Invalid regex"
		output += "PATTERN: {pattern}\n".blue

	let substitute_match
	if typeof (let replacement = args.shift!) is "string"
		output += "\nREPLACEMENT: {replacement}\n".blue
		substitute_match = do
			replacement.replaceAll(/(?<!\\)&/g,$1).replaceAll("\\&","&")
	else
		substitute_match = do $1

	if let modify = args.shift!
		return quit "Invalid args" unless modify is "-M"

	if let force = args.shift!
		return quit "Invalid args" unless force is "-F"

	if modify and not force
		try
			if execSync("git status --porcelain", { stdio: "pipe" }).toString!
				return quit "Git working directory is not clean (-F to force)"
		catch e
			return quit "Failed to check git status (-F to force)"

	return quit "Invalid args" if args.shift!

	let errors = []

	for filename in files

		try
			continue unless statSync(filename).isFile!
		catch e
			errors.push "{e}"
			continue

		unless pattern
			output += "{filename.pink}\n"
			continue

		let temp
		try
			temp = readFileSync(filename).toString!
		catch e
			errors.push "{e}"
			continue
		const data = temp

		let replaced = data.replace(pattern) do
			substitute_match($1).green
		
		let to_print = ""
		diffLines(data, replaced).forEach do
			if $1.added
				if $1.value.length < 1000
					to_print += $1.value
				else
					to_print += "[Omitted line with > 1000 chars]\n".yellow
		continue unless to_print.length >= 1
		output += "\n{filename.pink}\n{to_print.trim!}\n"

		continue unless modify
		try
			let new_data = data.replace(pattern) do substitute_match($1)
			writeFileSync(filename, new_data)
			output += "Successfully wrote file\n".cyan
		catch e
			output += "Failed to write file, see errors below\n".red
			errors.push "{e}"

	L output
	if errors.length > 0
		L "{errors.join("\n\n")}\n".red

main!

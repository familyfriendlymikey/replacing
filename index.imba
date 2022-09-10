const p = console.log
const green = "\x1b[32m"
const pink = "\x1b[35m"
const red = "\x1b[31m"
const cyan = "\x1b[36m"
const blue = "\x1b[34m"
const clear = "\x1b[0m"
const help = "\nSee README for usage instructions: https://github.com/familyfriendlymikey/replacing"

const { readFileSync, writeFileSync, statSync } = require "fs"
const { execSync } = require "child_process"
const { diffLines } = require "diff"
const quit = do p("{help}\n\n{red}{$1}, quitting.{clear}\n") and process.exit!

main!

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
		output += "PATTERN: {blue}{pattern}{clear}\n"

	let substitute_match
	if typeof (let replacement = args.shift!) is "string"
		output += "\nREPLACEMENT: {blue}{replacement}{clear}\n"
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

	for filename in files

		try
			continue unless statSync(filename).isFile!
		catch e
			output += "{red}{e}{clear}"
			continue

		unless pattern
			output += "{pink}{filename}{clear}\n"
			continue

		let temp
		try
			temp = readFileSync(filename).toString!
		catch e
			output += "{red}{e}{clear}"
			continue
		const data = temp

		let replaced = data.replace(pattern) do
			"{green}{substitute_match($1)}{clear}"
		
		let to_print = ""
		diffLines(data, replaced).forEach do to_print += $1.value if $1.added
		continue unless to_print.length >= 1
		output += "\n{pink}{filename}{clear}\n{to_print.trim!}\n"

		continue unless modify
		try
			let new_data = data.replace(pattern) do substitute_match($1)
			writeFileSync(filename, new_data)
			output += "{cyan}Successfully wrote file{clear}\n"
		catch e
			output += "{red}Error writing file\n\n{e}{clear}"

	p output

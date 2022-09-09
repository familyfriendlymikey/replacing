const p = console.log
const green = "\x1b[32m"
const pink = "\x1b[35m"
const red = "\x1b[31m"
const cyan = "\x1b[36m"
const blue = "\x1b[34m"
const clear = "\x1b[0m"
const help = "\nSee README for usage instructions: https://github.com/familyfriendlymikey/replacing"

let { readFileSync, writeFileSync, statSync } = require 'fs'
let { execSync } = require 'child_process'
let quit = do p "{help}\n\n{red}{$1}, quitting.{clear}"

main!

def main

	try
		var files = readFileSync('/dev/stdin').toString!.trim!.split("\n").sort!
	catch e
		return quit "Failed to read stdin:\n\n{e}"
	
	let args = process.argv.slice(2)

	if typeof (let pattern = args.shift!) is 'string'
		let [re, flags] = pattern.split(/(?<!\\)\//)
		unless typeof flags is 'string'
			flags ||= 'gi'
		try
			pattern = new RegExp re, flags
		catch
			return quit "Invalid regex"
		p "\nPATTERN: {cyan}{pattern}{clear}"

	let substitute_match
	if typeof (let replacement = args.shift!) is 'string'
		p "\nREPLACEMENT: {cyan}{replacement}{clear}"
		substitute_match = do
			let r = replacement.replaceAll(/(?<!\\)&/g,"{blue}{$1}{green}")
			r.replaceAll('\\&','&')
	else
		substitute_match = do $1

	if let modify = args.shift!
		return quit 'Invalid args' unless modify is '-M'

	if let force = args.shift!
		return quit 'Invalid args' unless force is '-F'

	if modify and not force
		try
			let options = { stdio: 'ignore', encoding: 'utf8' }
			if execSync('git status --porcelain', options)
				return quit 'Git working directory is not clean (-F to force)'
		catch e
			return quit 'Not a git repository (-F to force)'

	return quit "Invalid args" if args.shift!

	for filename in files

		unless pattern
			p "{pink}{filename}{clear}"
			continue

		let data
		try
			continue unless statSync(filename).isFile!
			data = readFileSync(filename).toString!
		catch e
			p "{red}{e}{clear}"
			continue

		let lines_with_match = data.split("\n").filter do pattern.test($1)
		continue unless lines_with_match.length >= 1

		p "\n{pink}{filename}{clear}"
		p lines_with_match.join("\n").replace(pattern) do
			"{green}{substitute_match($1)}{clear}"

		continue unless modify
		try
			let new_data = data.replace(pattern) do substitute_match($1)
			writeFileSync(filename, new_data)
			p "{cyan}Successfully wrote file{clear}"
		catch e
			p "{red}Error writing file\n\n{e}{clear}"

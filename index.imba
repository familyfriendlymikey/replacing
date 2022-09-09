const p = console.log
const green = "\x1b[32m"
const pink = "\x1b[35m"
const red = "\x1b[31m"
const cyan = "\x1b[36m"
const clear = "\x1b[0m"
const help = "\nSee README for usage instructions: https://github.com/familyfriendlymikey/replacing"

const { readFileSync, writeFileSync, statSync } = require 'fs'
const { execSync } = require 'child_process'
const { diffLines } = require 'diff'
const quit = do p "{help}\n\n{red}{$1}, quitting.{clear}"

main!

def main

	try
		var files = readFileSync('/dev/stdin','utf8').trim!.split("\n").sort!
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
			replacement.replaceAll(/(?<!\\)&/g,$1).replaceAll('\\&','&')
	else
		substitute_match = do $1

	if let modify = args.shift!
		return quit 'Invalid args' unless modify is '-M'

	if let force = args.shift!
		return quit 'Invalid args' unless force is '-F'

	if modify and not force
		try
			let options = { encoding: 'utf8' }
			if execSync('git status --porcelain', options)
				return quit 'Git working directory is not clean (-F to force)'
		catch e
			return quit 'Not a git repository (-F to force)'

	return quit "Invalid args" if args.shift!

	p!
	for filename in files

		try
			continue unless statSync(filename).isFile!
		catch e
			p "{red}{e}{clear}"
			continue

		unless pattern
			p "{pink}{filename}{clear}"
			continue

		let temp
		try
			temp = readFileSync(filename).toString!
		catch e
			p "{red}{e}{clear}"
			continue
		const data = temp

		let replaced = data.replace(pattern) do
			"{green}{substitute_match($1)}{clear}"
		
		let to_print = ""
		diffLines(data, replaced).forEach do
			to_print += $1.value if $1.added

		continue unless to_print.length >= 1
		let dashes = "".padStart(filename.length, "-")
		p "{pink}{filename}\n{dashes}{clear}\n{to_print.trim!}\n"

		continue unless modify
		try
			let new_data = data.replace(pattern) do substitute_match($1)
			writeFileSync(filename, new_data)
			p "{cyan}Successfully wrote file{clear}"
		catch e
			p "{red}Error writing file\n\n{e}{clear}"

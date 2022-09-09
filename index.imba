const p = console.log
const green = "\x1b[32m"
const pink = "\x1b[35m"
const red = "\x1b[31m"
const cyan = "\x1b[36m"
const clear = "\x1b[0m"
const help = "\nSee README for usage instructions: https://github.com/familyfriendlymikey/replacing"

let { readFileSync, writeFileSync } = require 'fs'
let { execSync } = require 'child_process'

main!

def main

	let files
	try
		files = readFileSync(process.stdin.fd, 'utf8').trim!.split("\n")
	catch
		return p "{help}\n\n{red}Failed to read stdin, quitting.{clear}"
	
	let args = process.argv.slice(2)

	if let pattern = args.shift!
		pattern = new RegExp pattern, "g"
		p "\nPATTERN: {cyan}{pattern}{clear}"

	if let replacement = args.shift!
		p "\nREPLACEMENT: {cyan}{replacement}{clear}"

	if let modify = args.shift!
		try
			throw '' unless modify is '-M'
			let clean = !execSync 'git status --porcelain', { encoding: 'utf8' }
			let force = args.shift! is '-F'
			throw '' unless (clean or force)
		catch
			return p "{help}\n\n{red}Git working directory is not clean or invalid args, quitting.{clear}"

	if args.shift!
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

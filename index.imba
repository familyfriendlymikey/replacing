const p = console.log
const green = "\x1b[32m"
const pink = "\x1b[35m"
const red = "\x1b[31m"
const cyan = "\x1b[36m"
const blue = "\x1b[34m"
const clear = "\x1b[0m"
const help = "\nSee README for usage instructions: https://github.com/familyfriendlymikey/replacing"

const { readFileSync, writeFileSync } = require "fs"
const { execSync } = require "child_process"
const { diffLines } = require "diff"
const { fdir } = require "fdir"

let args =
	exclude: []
	include: []

let excluded_dirs = []
let excluded_paths = []
let implicitly_excluded_dirs = []
let implicitly_excluded_paths = []

let output = []
let errors = []

def fatal
	errors.push "Fatal: {$1}"
	exit!

def exit
	for group in output
		p group.join("\n") + "\n"
	if errors.length > 0
		p "{red}{errors.join("\n\n")}{clear}\n"
	process.exit!

def create_regex_e pat, default_flags="gi"
	let [re, flags] = pat.split(/(?<!\\)\//)
	return new RegExp(re, flags ?? default_flags)

def get_files_e

	let files

	if args.stdin
		files = readFileSync("/dev/stdin", "utf8").trim!.split("\n").sort!

	else

		def exclude dir_name, dir_path
			if args.exclude.some(do $1.test dir_path)
				excluded_dirs.push dir_path
				yes
			else
				no

		def filter path, isdir
			if args.exclude.some(do $1.test path)
				excluded_paths.push path
				return no
			return yes unless args.include.length >= 1
			if args.include.some(do $1.test path)
				yes
			else
				implicitly_excluded_paths.push path
				no

		const api = new fdir!
			.withRelativePaths!
			.exclude(exclude)
			.filter(filter)
			.crawl("./")

		files = await api.withPromise()
		if args.verbose

			let group = []
			let excluded = excluded_dirs.concat excluded_paths
			if args.exclude.length
				group.push "Explicit Exclusions: {blue}{args.exclude.join(" ")}{clear}"
				if excluded.length
					group.push "{red}{excluded.join("\n")}{clear}"
			if group.length
				output.push group

			group = []
			let implicitly_excluded = implicitly_excluded_dirs.concat implicitly_excluded_paths
			if args.include.length
				group.push "Implicit Exclusions: {blue}{args.include.join(" ")}{clear}"
				if implicitly_excluded.length
					group.push "{red}{implicitly_excluded.join("\n")}{clear}"
			if group.length
				output.push group

		output.push [ "Matching Paths:\n{green}{files.join("\n")}{clear}" ]
		files

def parse_args_e
	let arg
	let argv = process.argv.slice(2)
	while arg = argv.shift!
		if arg is '-c'
			args.noclear = yes
		elif arg is '-e'
			args.exclude.push create_regex_e(argv.shift!, "i")
		elif arg is '-i'
			args.include.push create_regex_e(argv.shift!, "i")
		elif arg is '-s'
			args.stdin = yes
		elif arg is '-v'
			args.verbose = yes
		elif arg is '-M'
			args.modify = yes
			arg = argv.shift!
			if arg == null
				break
			elif arg is '-F' and argv.shift! == null
				args.force = yes
				break
			else
				throw "`-M` and `-F` args must come last"
		elif arg is '-p'
			throw "Pattern specified twice" if args.pattern
			args.pattern = create_regex_e(argv.shift!)
		elif arg is '-r'
			throw "replacement specified twice" if args.replacement
			let arg = argv.shift!
			if arg == null
				throw 'no replacement specified with `-r` flag'
			else
				args.replacement = arg
		elif args.pattern and not args.replacement
			args.replacement = arg
		elif not args.pattern
			args.pattern = create_regex_e(arg)
		else
			throw "Too many arguments"
	args

def main

	try
		parse_args_e!
	catch e
		fatal e

	unless args.noclear
		p '\x1bc'

	let files
	try
		files = await get_files_e args
	catch e
		fatal "{e}"

	if args.pattern
		output.push [ "Pattern: {blue}{args.pattern}{clear}" ]

	if args.replacement
		output.push [ "Replacement: {blue}{args.replacement}{clear}" ]

	exit! unless args.pattern

	if args.modify and not args.force
		try
			if execSync("git status --porcelain", { stdio: "pipe" }).toString!
				fatal "Git working directory is not clean (-F to force)"
		catch
			fatal "Failed to check git status (-F to force)"

	let substitute_match
	if args.replacement == null
		substitute_match = do $1
	else
		substitute_match = do
			args.replacement.replaceAll(/(?<!\\)&/g,$1).replaceAll("\\&","&")

	for filename in files

		let data
		try
			data = readFileSync(filename).toString!
		catch e
			errors.push "{e}"
			continue

		let replaced = data.replace(args.pattern) do
			"{green}{substitute_match($1)}{clear}"

		let to_print = ""
		diffLines(data, replaced).forEach do to_print += $1.value if $1.added
		continue unless to_print.length >= 1
		output.push [
			"{pink}{filename}{clear}"
			to_print.trim!
		]

		continue unless args.modify
		try
			let new_data = data.replace(args.pattern) do substitute_match($1)
			writeFileSync(filename, new_data)
			output[-1].push "{cyan}Successfully wrote file{clear}"
		catch e
			output[-1].push "{red}Failed to write file, see errors below{clear}"
			errors.push "{e}"

	exit!

main!

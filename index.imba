let p = console.log
let green = "\x1b[32m"
let pink = "\x1b[35m"
let clear = "\x1b[0m"

let args = process.argv.slice(2)
if args.length is 0
	process.exit!

if args.length >= 1
	var re = new RegExp args[0], "g"
	p re

if args.length >= 2
	var replacement = args[1]
	p replacement

if args.length >= 3
	var modify = yes

import glob from 'glob'
import { readFileSync, writeFileSync } from 'fs'

# let dir = '**/*'
let dir = 'test/**'

let ignore = [
	"node_modules/**"
]

let nodir = yes

let options = { ignore, nodir }

glob(dir, options) do |e, files|
	for filename in files
		p "\n{pink}{filename}{clear}"
		let data = readFileSync(filename, 'utf8')
		let lines = data.split "\n"
		lines = lines.filter do re.test($1)
		let s = lines.join("\n").replaceAll(re) do "{green}{replacement or $1}{clear}"
		p s
		if modify
			let new_data = data.replaceAll re, replacement
			writeFileSync(filename, new_data)

#!/usr/bin/env coffee

Transform = require('stream').Transform
class LineStream extends Transform
  constructor: (opts) ->
    if @ not instanceof LineStream then return new LineStream opts
    else Transform.call @, opts

    @buf = ''

  _transform: (chunk, enc, cb) ->
    @buf += chunk.toString()
    ind = @buf.indexOf '\n'
    if ind isnt -1
      @push @buf[..ind]
      @buf = @buf[(ind + 1)..]
    cb()

  _flush: (cb) ->
    if @buf[-1..] isnt '\n' then @buf += '\n'
    @push @buf

argv = process.argv[2..]
spawn = require('child_process').spawn
yaourt = spawn 'yaourt', argv

process.on 'exit', -> yaourt.kill 'SIGHUP'
process.on 'uncaughtException', (err) ->
  console.error err.stack
  yaourt.kill 'SIGHUP'
  process.exit 1
yaourt.on 'exit', (code) -> process.exit code

yaourt.stdout.pipe process.stdout
yaourt.stderr.pipe process.stderr

prevString = ''
yaourt.stderr.pipe(new LineStream).on 'data', (line) ->
  line = line.toString()
  if line.match /y\/n/i
    prevString = switch
      when line.match /PKGBUILD/i then 'n\n'
      when line.match /Continue/i then 'y\n'
      when line.match /Proceed/i then 'y\n'
      else null
  if prevString? and line.match /==>/i
    yaourt.stdin.write prevString

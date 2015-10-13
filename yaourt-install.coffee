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

process.stdin.pipe yaourt.stdin
canWrite = yes
yaourt.stdin.on 'finish', ->
  process.stdin.unpipe yaourt.stdin
  canWrite = no

# for any normal application, this wouldn't work; however, yaourt will actually
# flush its stdin buffer in between [y/n] queries. i don't know why it does
# this, but i suspect it's to make it more difficult to automate installation
# (it's not "the arch way" or whatever). if it didn't do this, we could just
# write all our responses to stdin immediately and not have a prevString at all.
prevString = ''
onData = (line) ->
  line = line.toString()
  if line.match /y\/n/i
    prevString = switch
      when line.match /PKGBUILD/ then 'n\n'
      when line.match /Continue/ then 'y\n'
      when line.match /Proceed/ then 'y\n'
      when line.match /Restart/ then 'y\n'
      else null
  if prevString? and canWrite and line.match /==>/i
    yaourt.stdin.write prevString for [0..4]
yaourt.stderr.pipe(new LineStream).on 'data', onData
yaourt.stdout.pipe(new LineStream).on 'data', onData

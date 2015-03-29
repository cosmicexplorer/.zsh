finalList = []

toTitleCase = (str) ->
  str.replace /\w\S*/g, (txt) ->
    txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()

require('fs').readFile process.argv[2], (err, data) =>
  throw err if err
  for word in data.toString().split /\n/
    if word != ""
      finalList.push word.toUpperCase()
      finalList.push word.toLowerCase()
      finalList.push toTitleCase(word)
  console.log "\"" + finalList.join("|") + "\""

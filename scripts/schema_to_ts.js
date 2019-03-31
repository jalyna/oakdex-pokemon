const compileFromFile = require('json-schema-to-typescript').compileFromFile
const fs = require('fs')

// compile from file
compileFromFile('lib/oakdex/pokemon/schema.json')
  .then(ts => fs.writeFileSync('schema.d.ts', ts))
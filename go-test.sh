#!/bin/bash
set -e 1

mv $TEST_FILE_NAME /home/damner/code/codedamn_evaluation_test.go

# run test
cd /home/damner/code
go mod init codedamn # assuming you used "codedamn" as the package
go test -json -parallel 1 > codedamn_evaluation_output.json || true 

# process results file
cat > processGoResults.js << EOF
const fs = require('fs')

// Read the test results file into memory as a string
const testResults = fs.readFileSync('./codedamn_evaluation_output.json', 'utf8').filter(Boolean)
const lines = testResults.split('\n')

// Create an empty array to store the pass/fail status of each test
const results = []

// Loop through each line and parse it as JSON and check if it is a result line
lines.forEach(line => {
  const output = JSON.parse(line).Output?.trim()
  const valid = output === 'PASS' || output === 'FAIL'
  if(!valid) return

  const passed = output === 'PASS'

  // Add the pass/fail status to the array
  results.push(passed)
})

// Write results
fs.writeFileSync(process.env.UNIT_TEST_OUTPUT_FILE, JSON.stringify(results))
EOF

# process results
node processGoResults.js

# remove files
rm /home/damner/code/codedamn_evaluation_test.go codedamn_evaluation_output.json processGoResults.js

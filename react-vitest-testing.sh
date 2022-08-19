# setup package.json
cat > /home/damner/.test/package.json << EOF
{
  "dependencies": {
    "vite": "^3.0.9",
    "vitest": "^0.22.1",
    "@vitejs/plugin-react": "^2.0.1"
  }
}
EOF

# install vitest and vite
yarn install

# Move test file
mv $TEST_FILE_NAME check.test.js

# run test
yarn vitest run --threads=false --reporter=json --outputFile=payload.json

cat > /home/damner/.test/process.js << EOF
const fs = require('fs')
const payload = require('./payload.json')
const answers = payload.testResults[0].assertionResults.map(test => test.status === 'passed')

fs.writeFileSync(process.env.UNIT_TEST_OUTPUT_FILE, JSON.stringify(answers))
EOF

# Write results to UNIT_TEST_OUTPUT_FILE to communicate to frontend
node /home/damner/.test/process.js
#!/bin/bash
set -e 1

# Assumes you are running a react vite playground on codedamn

# Install vitest and testing util
cd /home/damner/code
yarn add vitest@0.22.1 jsdom@20.0.0 @testing-library/jest-dom@5.16.4 @testing-library/react@13.3.0 --dev
mkdir -p /home/damner/code/__labtests
 
# Move test file
mv $TEST_FILE_NAME /home/damner/code/__labtests/reactcheck.test.jsx

# setup file
cat > /home/damner/code/__labtests/setup.js << EOF
import '@testing-library/jest-dom'
EOF

# vitest config file
cat > /home/damner/code/__labtests/config.js << EOF
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
	plugins: [react()],
    test: {
        globals: true,
        environment: 'jsdom',
        setupFiles: '/home/damner/code/__labtests/setup.js',
    }
})
EOF

# process.js file
cat > /home/damner/code/__labtests/process.js << EOF
const fs = require('fs')
const payload = require('./payload.json')
const answers = payload.testResults[0].assertionResults.map(test => test.status === 'passed')

fs.writeFileSync(process.env.UNIT_TEST_OUTPUT_FILE, JSON.stringify(answers))
EOF

# run test
yarn vitest run --config=/home/damner/code/__labtests/config.js --threads=false --reporter=json --outputFile=/home/damner/code/__labtests/payload.json || true



# Write results to UNIT_TEST_OUTPUT_FILE to communicate to frontend
node /home/damner/code/__labtests/process.js
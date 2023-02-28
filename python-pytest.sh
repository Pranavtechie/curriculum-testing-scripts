#!/bin/bash
set -e 1

mkdir -p /home/damner/code/__labtests

mv $TEST_FILE_NAME /home/damner/code/__labtests/pytest.py
echo "" > /home/damner/code/__labtests/__init__.py

# run test
cd /home/damner/code/__labtests
pytest --json-report pytest.py || true

# process results file
cat > processPythonResults.js << EOF
const payload = require('./.report.json')
const answers = payload.tests.map(test => test.outcome === 'passed')
require('fs').writeFileSync(process.env.UNIT_TEST_OUTPUT_FILE, JSON.stringify(answers))
EOF



# Write results to UNIT_TEST_OUTPUT_FILE to communicate to frontend
node /home/damner/code/__labtests/processPythonResults.js

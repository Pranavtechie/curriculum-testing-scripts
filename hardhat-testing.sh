# move the test file to user directory (hardhat testing util requires it)
mkdir -p $USER_CODE_DIR/test
mv $TEST_FILE_NAME $USER_CODE_DIR/test

# run hardhat testing util assuming we have correct mocha settings
cd $USER_CODE_DIR
yarn --silent hardhat test > $UNIT_TEST_OUTPUT_FILE

# run a light node script to extract out results and write them back in expected format

cat > /home/damner/.test/process-results.js << EOF
const fs = require('fs')
const payload = JSON.parse(fs.readFileSync(process.env.UNIT_TEST_OUTPUT_FILE, { encoding: 'utf8' }))
const answers = payload?.tests?.map((result, i) => {
    if(result.err.stack) {
        console.error(result.err.message)
        return false
    } else {
        console.log(\`Test ${i} passed\`)
        return true
    }
}) || []
fs.writeFileSync(process.env.UNIT_TEST_OUTPUT_FILE, JSON.stringify(answers))
EOF

node /home/damner/.test/process-results.js

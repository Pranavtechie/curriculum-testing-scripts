# move the test file to user directory (hardhat testing util requires it)
mkdir -p $USER_CODE_DIR/test
mv $TEST_FILE_NAME $USER_CODE_DIR/test

# run hardhat testing util assuming we have correct mocha settings
yarn --silent hardhat test > $UNIT_TEST_OUTPUT_FILE

# run a light node script to extract out results and write them back in expected format

cat << EOF
const payload = require(process.env.UNIT_TEST_OUTPUT_FILE)
const answers = []
payload.tests.forEach((result, i) => {
    if(result.err.stack) {
        answers.push(false)
        console.error(result.err.message)
    } else {
        answers.push(true)
        console.log(`Test ${i} passed`)
    }
})
require('fs').writeFileSync(process.env.UNIT_TEST_OUTPUT_FILE, JSON.stringify(answers))
EOF > /home/damner/.test/process-results.js

node /home/damner/.test/process-results.js
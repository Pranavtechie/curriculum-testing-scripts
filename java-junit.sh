#!/bin/bash
set -e 1

# Compile user code
cd /home/damner/code
javac -cp . *.java

# setup test env
mkdir -p /home/damner/.javatest
mv $TEST_FILE_NAME /home/damner/.javatest/TestFile.java

# Download the junit5main.jar binary if not present
[ -e "/home/damner/.javatest/junit5main.jar" ] || curl https://raw.githubusercontent.com/codedamn-classrooms/java-junit-files/main/junit5main.jar -o /home/damner/.javatest/junit5main.jar

# Compile test file
cd /home/damner/.javatest
javac -cp .:junit5main.jar TestFile.java

# Run the test file
cd /home/damner/.javatest
java -jar junit5main.jar -cp .:/home/damner/code --select-class TestFile --reports-dir . || true

# Convert TEST-junit-jupiter.xml to JSON
cd /home/damner/.javatest
yarn add xml2js
cat > processJavaResults.js << EOF
const fs = require('fs')
const xmlFile = fs.readFileSync('./TEST-junit-jupiter.xml', 'utf8')
const { parseString } = require('xml2js')
parseString(xmlFile, (err, data) => {
    const results = []
    console.log(data.testsuite.testcase[0])
    for (let i = 0; i < data.testsuite.testcase.length; i++) {
        results.push(!data.testsuite.testcase[i].failure)
    }

    fs.writeFileSync(process.env.UNIT_TEST_OUTPUT_FILE, JSON.stringify(results))
})

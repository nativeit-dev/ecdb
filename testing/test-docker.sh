#!/bin/sh

# Set ecdb environment
ecdb_HOSTNAME=${TESTSUITE_HOSTNAME:=localhost}
ecdb_PORT=${TESTSUITE_PORT:=80}
ecdb_URL=http://${ecdb_HOSTNAME}:${ecdb_PORT}/

# Set database environment
ecdb_DB_HOSTNAME=${ECDB_HOST:=localhost}
ecdb_DB_PORT=${ECDB_PORT:=3306}

if [ ! -z "${TESTSUITE_HOSTNAME_ARBITRARY}" ]; then
    SERVER="--server ${ecdb_DB_HOSTNAME}"
fi

# Find test script
if [ -f ./ecdb_test.py ] ; then
    FILENAME=./ecdb_test.py
else
    FILENAME=./testing/ecdb_test.py
fi

mysql -h "${ecdb_DB_HOSTNAME}" -P"${ecdb_DB_PORT}" -u"${TESTSUITE_USER:=root}" -p"${TESTSUITE_PASSWORD}" -e "SELECT @@version;" > /dev/null
ret=$?

if [ $ret -ne 0 ] ; then
    echo "Could not connect to ${ecdb_DB_HOSTNAME} on port ${ecdb_DB_PORT}"
    exit $ret
fi

curl -fsSL --output /dev/null "${ecdb_URL}"
ret=$?

if [ $ret -ne 0 ] ; then
    echo "Could not connect to ${ecdb_URL}"
    exit $ret
fi

# Perform tests
ret=0
pytest -p no:cacheprovider -q --url "$ecdb_URL" --username ${TESTSUITE_USER:=root} --password "$TESTSUITE_PASSWORD"  $SERVER $FILENAME
ret=$?

# Show debug output in case of failure
if [ $ret -ne 0 ] ; then
    ${COMMAND_HOST} ps faux
    echo "Result of ${ecdb_DB_HOSTNAME} tests: FAILED"
    exit $ret
fi

echo "Result of ${ecdb_DB_HOSTNAME} tests: SUCCESS"

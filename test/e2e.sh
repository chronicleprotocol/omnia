#!/bin/bash
set - e

E2E_START_DELAY="${E2E_START_DELAY:-61}"

echo "======================================"
echo "Starting E2E Omnia tests"
echo "Start delay: $E2E_START_DELAY seconds"
echo "======================================"

# We have to wait till whole env will be runnig and only then start tests
sleep $E2E_START_DELAY

for f in "$(cd "${BASH_SOURCE[0]%/*}"; pwd)"/e2e/*.sh;
do
  echo "======================================"
  echo "Running E2E: $f"
  echo "======================================"
  # Running unit test
  bash "$f"

  # Cehcking result
  res=$?
  if [ $res -ne 0 ]; then
    echo "--------------------------------------"
    echo "Failed to run E2E: $f"
    echo "--------------------------------------"
    exit $res
  fi
done
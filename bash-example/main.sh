#!/bin/bash

source auth_client.sh
source launch_client.sh
source item_client.sh

HOST=$1
USERNAME=$2
PASSWORD=$3
PROJECT=$4

START_LAUNCH_BODY_PATH=./json/start-launch.json
START_SUITE_BODY_PATH=./json/start-suite.json
START_TEST_BODY_PATH=./json/start-test.json
START_STEP_BODY_PATH=./json/start-step.json
FINISH_STEP_BODY_PATH=./json/finish-step.json
FINISH_TEST_BODY_PATH=./json/finish-test.json
FINISH_SUITE_BODY_PATH=./json/finish-suite.json
FINISH_LAUNCH_BODY_PATH=./json/finish-launch.json

UI_TOKEN=$(get_ui_token ${HOST} ${USERNAME} ${PASSWORD})

API_TOKEN=$(get_api_token ${HOST} ${UI_TOKEN})

LAUNCH_UUID=$(start_launch ${HOST} ${PROJECT} ${API_TOKEN} ${START_LAUNCH_BODY_PATH})
echo "Launch  - $LAUNCH_UUID"

SUITE_UUID=$(start_root_item ${HOST} ${PROJECT} ${API_TOKEN} ${LAUNCH_UUID} ${START_SUITE_BODY_PATH})
echo "Suite - $SUITE_UUID"

TEST_UUID=$(start_child_item ${HOST} ${PROJECT} ${API_TOKEN} ${LAUNCH_UUID} ${SUITE_UUID} ${START_TEST_BODY_PATH})
echo "Test - $TEST_UUID"

STEP_UUID=$(start_child_item ${HOST} ${PROJECT} ${API_TOKEN} ${LAUNCH_UUID} ${TEST_UUID} ${START_STEP_BODY_PATH})
echo "Step - $STEP_UUID"

finish_item ${HOST} ${PROJECT} ${API_TOKEN} ${STEP_UUID} ${FINISH_STEP_BODY_PATH}

finish_item ${HOST} ${PROJECT} ${API_TOKEN} ${TEST_UUID} ${FINISH_TEST_BODY_PATH}

finish_item ${HOST} ${PROJECT} ${API_TOKEN} ${SUITE_UUID} ${FINISH_SUITE_BODY_PATH}

finish_launch ${HOST} ${PROJECT} ${API_TOKEN} ${LAUNCH_UUID} ${FINISH_LAUNCH_BODY_PATH}


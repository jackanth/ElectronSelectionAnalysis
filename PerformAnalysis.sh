#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
LIGHT_GREY='\033[0;37m'
NORMAL='\033[0m'

function EchoMessage() {
    local message=$1
    local colour=${2:-${NORMAL}}
    echo -e "${colour}${message}${NORMAL}" >&1
    return 0
}

function EchoWarning() {
    local message=$1
    echo -e "${YELLOW}${message}${NORMAL}" >&2
    return 0
}

function EchoError() {
    local message=$1
    echo -e "${RED}${message}${NORMAL}" >&2
    return 0
}

function RunCommand() {
    local cmd=$1
    local logFile=$2
    local errFile=$3
    local fullCmd="$cmd > $logFile 2> $errFile"

    if ! eval "$fullCmd"; then
        EchoError "Command failed: ${LIGHT_GREY}$fullCmd"
        exit 1
    fi
}

# Set up
cwd=$(pwd)
outputDir="outputs"
archiveDir="archive"
logFile="out.log"
errFile="err.log"

EchoMessage "Running LEE analysis with output dir ${LIGHT_GREY}$cwd/$outputDir"
EchoMessage "Writing stdout to ${LIGHT_GREY}$logFile${NORMAL} and stderr to ${LIGHT_GREY}$errFile${NORMAL}"

# Archive any existing output directory
if [ -d "$outputDir" ]; then
    mkdir -p $archiveDir
    timestamp=$(date +%s)
    archivedOutputDir=$archiveDir/${outputDir}_$timestamp
    mv $outputDir $archivedOutputDir
    EchoWarning "Moved existing output directory to $archivedOutputDir"
fi

mkdir -p $outputDir 

# Produce the energy estimator training sets
energyEstimatorTrainingDir=$outputDir/EnergyEstimatorTrainingOutput
EchoMessage "Writing energy estimator training sets: ${LIGHT_GREY}$energyEstimatorTrainingDir"
RunCommand "pndr event_lists/events.txt $energyEstimatorTrainingDir ./settings/ProduceEnergyEstimatorTrainingSets.xml -n200" $logFile $errFile
#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
LIGHT_GREY='\033[0;37m'
NORMAL='\033[0m'
LIGHT_GREY_BOLD='\033[1;37m'

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

    if ! eval "$cmd"; then
        EchoError "Command failed: ${LIGHT_GREY}$cmd"
        exit 1
    fi
}

function RunCommandAndPipe() {
    local cmd=$1
    local logFile=$2
    local fullCmd="$cmd &> $logFile"

    if ! eval "$fullCmd"; then
        EchoError "Command failed: ${LIGHT_GREY}$fullCmd"
        exit 1
    fi
}

# Issue welcome
cat << "EOF"                                                                          
                                                  ,--.                         
,-.----.                 ___                    ,--.'|                         
\    /  \              ,--.'|_    ,--,      ,--,:  : |                         
;   :    \             |  | :,' ,--.'|   ,`--.'`|  ' :         ,--,            
|   | .\ :             :  : ' : |  |,    |   :  :  | |       ,'_ /|            
.   : |: |    ,---.  .;__,'  /  `--'_    :   |   \ | :  .--. |  | :    ,---.   
|   |  \ :   /     \ |  |   |   ,' ,'|   |   : '  '; |,'_ /| :  . |   /     \  
|   : .  /  /    /  |:__,'| :   '  | |   '   ' ;.    ;|  ' | |  . .  /    /  | 
;   | |  \ .    ' / |  '  : |__ |  | :   |   | | \   ||  | ' |  | | .    ' / | 
|   | ;\  \'   ;   /|  |  | '.'|'  : |__ '   : |  ; .':  | : ;  ; | '   ;   /| 
:   ' | \.''   |  / |  ;  :    ;|  | '.'||   | '`--'  '  :  `--'   \'   |  / | 
:   : :-'  |   :    |  |  ,   / ;  :    ;'   : |      :  ,      .-./|   :    | 
|   |.'     \   \  /    ---`-'  |  ,   / ;   |.'       `--`----'     \   \  /  
`---'        `----'              ---`-'  '---'                        `----'   
                                                                               

EOF

EchoMessage "RetiNue | MicroBooNE nue selection analysis steering scripts" $LIGHT_GREY_BOLD
EchoMessage "Author: Jack Anthony <anthony@hep.phy.cam.ac.uk>\n" $LIGHT_GREY
sleep 2

# Set up
cwd=$(pwd)
outputDir="outputs"
archiveDir="archive"
logFile="out.log"

EchoMessage "Running analysis with output dir ${LIGHT_GREY}$cwd/$outputDir"
EchoMessage "Writing stdout to ${LIGHT_GREY}$logFile${NORMAL}"

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
RunCommandAndPipe "pndr event_lists/events.txt $energyEstimatorTrainingDir ./settings/ProduceEnergyEstimatorTrainingSets.xml -n10" $logFile

#mkdir $energyEstimatorTrainingDir
#valgrind --tool=massif pandora -i ./.settings.tmp.xml -n10 -pN -rFull
#valgrind --num-callers=30 --log-file=valgrind.log --suppressions=$ROOTSYS/etc/valgrind-root.supp pandora -i ./.settings.tmp.xml -n10 -pN -rFull


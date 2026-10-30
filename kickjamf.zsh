#!/bin/zsh --no-rcs
# set -x

##################################### VARIABLES ##########################################

vers="1.01"
myPID=$$
scriptName=$( /usr/bin/basename ${0} )
myTimeStamp()
{
	/bin/date | /usr/bin/awk  '{ printf "%02s %02s %02s %02s\n", $1,$2,$3,$4 }'
}
Numb_Arguments=$#
argument_1="${1}"
myHost=$( /usr/sbin/scutil --get ComputerName )
myLog="/var/log/jamf.log"

##################################### FUNCTIONS ##########################################

function logging()
{

    /bin/echo "$(myTimeStamp) ${myHost} ${scriptName}[${myPID}]: ${1}" | /usr/bin/tee -a "${myLog}"
}
function START_SCRIPT()
{
	/bin/echo "" | /usr/bin/tee -a "${myLog}"
	logging "Starting ${scriptName}, Version: ${vers}."
}
function EXIT_SCRIPT()
{
	logging "Ending ${scriptName}, Version: ${vers}."
	/bin/echo "" | /usr/bin/tee -a "${myLog}"
	exit 0
}
function MY_VERSION()
{
	if [[ "$1" -eq 1 ]]; then
		case $2 in
			(-v|--version)
				/bin/echo "${vers}"
				exit 0
				;;
			(*)
				exit 0
				;;
		esac
	fi
}
function CHECK_JSS_CONNECTION()
{
	logging "CHECK_JSS_CONNECTION: Starting CHECK_JSS_CONNECTION."
	/usr/local/bin/jamf checkJSSConnection -retry 24
	if [ $? -eq 1 ]; then
		logging "CHECK_JSS_CONNECTION: No network connection detected."
		logging "CHECK_JSS_CONNECTION: Ending CHECK_JSS_CONNECTION."
		EXIT_SCRIPT
	else
		logging "CHECK_JSS_CONNECTION: Network connection has been established."
	fi
	logging "CHECK_JSS_CONNECTION: Ending CHECK_JSS_CONNECTION."
}
function FORCE_JAMF()
{
	/usr/local/bin/jamf manage
	/usr/bin/wait 1
	/usr/local/bin/jamf policy
}

##################################### MAIN ##########################################

MY_VERSION ${Numb_Arguments} ${argument_1}

START_SCRIPT
CHECK_JSS_CONNECTION
#FORCE_JAMF
EXIT_SCRIPT

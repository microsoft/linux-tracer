#!/bin/bash
#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! DISCLAIMER !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# This sample script is not supported under any Microsoft standard support program or service.
# The sample script is provided “AS IS” without warranty of any kind. Microsoft further disclaims 
# all implied warranties including, without limitation, any implied warranties of merchantability 
# or of fitness for a particular purpose. The entire risk arising out of the use or performance of 
# the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, 
# or anyone else involved in the creation, production, or delivery of the scripts be liable for any 
# damages whatsoever (including, without limitation, damages for loss of business profits, business 
# interruption, loss of business information, or other pecuniary loss) arising out of the use of or 
# inability to use the sample scripts or documentation, even if Microsoft has been advised of the 
# possibility of such damages.
#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! DISCLAIMER !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#############################################################
#                   START Define vars     				    #
#############################################################

# Test "$1" content: must have a value and must be a number.
RE='^[0-9]+$'

# Define number of seconds to capture 
LIMIT=$1

# Define number of MDATP processes we're checking
NR_OF_PIDS=4

# Define main log file name
MAIN_LOGFILENAME=main.txt

# Define dir file name
DIRNAME=mdatp_performance_data

# Define 'high_cpu_parser.py' URL for download
HI_CPU_PARSER_URL=https://raw.githubusercontent.com/microsoft/mdatp-xplat/master/linux/diagnostic/high_cpu_parser.py

# Define 'high_cpu_parser.py' download path
HI_CPU_PARSER_FILE=${DIRNAME}/high_cpu_parser.py

# Define vars to work with python detection function
PYTHON_V=$(which python 2> /dev/null)
PYTHON2_V=$(which python2 2> /dev/null)
PYTHON3_V=$(which python3 2> /dev/null)
PYTHON=""

# Test upfront time capture parameter. If we don't provide a number of seconds, exit.
#
if ! [[ $1 =~ $RE ]]
	then
		echo -e " *** Usage: ./linux_cpu_tracer_v1.sh <capture time in seconds>"
		exit 0
fi

#############################################################
#                   END Define vars     					#
#############################################################

#############################################################
#                  START Define Functions				    #
#############################################################

# Feeding CPU statistics inside each PID file
#
feed_stats () {

for (( i = 1; i <= $NR_OF_PIDS; i++ ))
	do
		cat $DIRNAME/pid$i.txt | awk -F ' ' '{ print $9 }' | grep -v CPU > $DIRNAME/pid$i.t
		SUM=$(awk '{Total=Total+$1} END{print Total}' $DIRNAME/pid${i}.t)
		TOTAL=$(cat $DIRNAME/pid${i}.t | wc -l)
		OUT=$(echo "scale=2; $SUM/$TOTAL" | bc -l)
		echo " Total of lines is: $TOTAL" | tee -a $DIRNAME/pid$i.txt
		echo " Sum of values in column: $SUM" | tee -a $DIRNAME/pid$i.txt
		echo " Percentage Average = SUM/TOTAL" | tee -a $DIRNAME/pid$i.txt
		echo " CPU Percentage Average is $OUT%" | tee -a $DIRNAME/pid$i.txt
	done
}

# Check if ZIP is installed
#
check_zip () {

echo -e " *** Checking if 'zip' is installed..."
which zip > /dev/null 2>&1

if [ $? != 0 ]
    then
        echo -e " *** Cannot find 'zip'."
			echo -e " *** Please confirm 'zip' is installed on your system."
			exit 0
    else
        echo -e " *** Found 'zip'. [OK]"
fi
}

# Check if SED is installed
#
check_sed () {

echo -e " *** Checking if 'sed' is installed..."
which sed > /dev/null 2>&1

if [ $? != 0 ]
	then
		echo -e " *** Cannot find 'sed'."
		echo -e " *** Please confirm 'sed' is installed on your system."
		exit 0
	else
		echo -e " *** Found 'sed'. [OK]"
fi
}

# Check if AWK is installed
#
check_awk () {

echo -e " *** Checking if 'awk' is installed..."
which awk > /dev/null 2>&1

if [ $? != 0 ]
	then
		echo -e " *** Cannot find 'awk'."
		echo -e " *** Please confirm 'awk' is installed on your system."
		exit 0
	else
		echo -e " *** Found 'awk'. [OK]"
fi
}

# Check if TOP is installed
#
check_top () {

echo -e " *** Checking if 'top' is installed..."
which top > /dev/null 2>&1

if [ $? != 0 ]
	then
		echo -e " *** Cannot find 'top'."
		echo -e " *** Please confirm 'top' is installed on your system."
		exit 0
	else
		echo -e " *** Found 'top'. [OK]"
fi
}

# Check if GREP is installed
#
check_grep () {

echo -e " *** Checking if 'grep' is installed..."
which grep > /dev/null 2>&1

if [ $? != 0 ]
	then
		echo -e " *** Cannot find 'grep'."
		echo -e " *** Please confirm 'grep' is installed on your system."
		exit 0
	else
		echo -e " *** Found 'grep'. [OK]"
fi
}

# Check if TEE is installed
#
check_tee () {

echo -e " *** Checking if 'tee' is installed..."
which tee > /dev/null 2>&1

if [ $? != 0 ]
	then
		echo -e " *** Cannot find 'tee'."
		echo -e " *** Please confirm 'tee' is installed on your system."
		exit 0
	else
		echo -e " *** Found 'tee'. [OK] "
fi
}

# Checks if MDATP is installed
# 
check_mdatp_running () {

echo -e " *** Checking if MDAPT is installed..."

which mdatp > /dev/null 2>&1

if [ $? != 0 ]
	then
		echo -e " *** Cannot find 'mdatp'."
		echo -e " *** Please confirm 'mdatp' is installed on your system."
		exit 0
	else
		echo -e " *** Found 'mdatp'. [OK]"
fi

echo -e " *** Checking if MDAPT service is running... "

systemctl list-units --type=service \
                     --state=running | grep mdatp.service | grep "loaded active running" > /dev/null 2>&1

if [ $? != 0 ]
	then
		echo -e " *** 'mdatp' service is not running on your system."
		echo -e " *** Please start 'mdatp' service."
		exit 0
	else
		echo -e " *** 'mdatp' service is running."
fi
}

# Wait function
#
pause_ () {
	sleep 1
 }

# Function to gather CPU load, and RAM data
#
loop() {

for (( i = 1; i <= $LIMIT; i++ ))
	do
	  echo $(date)
	  echo -e "    PID USER      PR   NI   VIRT    RES    SHR S  %CPU  %MEM   TIME+   COMMAND"
	  top -bn1 -w512 | grep -e mdatp -e wdavdaemon 
	  sleep 1
	done
}

# Function to inform user on data gathering progress
#
count() {

INIT=1
while [ $INIT -lt $LIMIT ]
	do
		echo -ne "     $INIT/$LIMIT \033[0K\r"
		sleep 1
		: $((INIT++))
	done
}
#############################################################
#                   END Define Functions				    #
#############################################################

#############################################################
#                   Run Functions and Co.        			#
#############################################################

# Check if MDATP service is installed and running
#
check_mdatp_running

# Check required base files
#
check_zip
check_sed
check_awk
check_top
check_grep
check_tee

# Create dir to host performance files (if it does not exist yet)
#
echo -e " *** Checking if '$DIRNAME' dir exists..."
pause_
if [ -d "$DIRNAME" ]
   then
		# Dir exists. No need to create. Clean existent files and moving on.
		#
		echo -e " *** $DIRNAME exists. Deleting old files..."
		pause_
		rm -rf $DIRNAME/*
		pause_
		echo -e " *** Done deleting old files."
		
	else
		# Dir does nor exist. Create.
		#
		echo -e " *** $DIRNAME does not exist. Creating..." 
		pause_  
		mkdir $DIRNAME
fi

echo -e " *** Collecting information about base OS..."
cp /etc/os-release $DIRNAME/os-release.txt
pause_

echo -e " *** Collecting information about memory resources..."
free -h > $DIRNAME/free.txt
pause_

echo -e " *** Collecting information about CPU resources..."
cat /proc/cpuinfo | grep processor > $DIRNAME/cpuinfo.txt
		
echo -e " *** Gathering data for $LIMIT seconds..."
pause_
		
loop > $DIRNAME/$MAIN_LOGFILENAME | count

# Define PID extraction vars (after main file $MAIN_LOGFILENAME' is created)
#
PID1=$(cat $DIRNAME/$MAIN_LOGFILENAME | head -n6 | awk -F ' ' '{ print $1 }' | tail -n +3 | sed '1q;d')
PID2=$(cat $DIRNAME/$MAIN_LOGFILENAME | head -n6 | awk -F ' ' '{ print $1 }' | tail -n +3 | sed '2q;d')
PID3=$(cat $DIRNAME/$MAIN_LOGFILENAME | head -n6 | awk -F ' ' '{ print $1 }' | tail -n +3 | sed '3q;d')
PID4=$(cat $DIRNAME/$MAIN_LOGFILENAME | head -n6 | awk -F ' ' '{ print $1 }' | tail -n +3 | sed '4q;d')

echo -e " *** Creating log files for analysis..."
pause_

# Populating files with header 
#
echo -e "    PID USER      PR   NI   VIRT    RES    SHR S  %CPU  %MEM   TIME+   COMMAND" | tee $DIRNAME/pid1.txt $DIRNAME/pid2.txt $DIRNAME/pid3.txt $DIRNAME/pid4.txt > /dev/null

# Feeding data to files
#
cat $DIRNAME/$MAIN_LOGFILENAME | grep $PID1 >> $DIRNAME/pid1.txt
cat $DIRNAME/$MAIN_LOGFILENAME | grep $PID2 >> $DIRNAME/pid2.txt
cat $DIRNAME/$MAIN_LOGFILENAME | grep $PID3 >> $DIRNAME/pid3.txt
cat $DIRNAME/$MAIN_LOGFILENAME | grep $PID4 >> $DIRNAME/pid4.txt

feed_stats > /dev/null 2>&1

##################################################################
#               START Create files for plotting                  #
##################################################################

# Create X axis
#
for (( i = 1; i <= $LIMIT; i++ ))
	do	
		echo $i >> $DIRNAME/merge.t
	done

# Merging X with Y
#
for (( i = 1; i <= $NR_OF_PIDS; i++ ))
	do
		paste $DIRNAME/merge.t $DIRNAME/pid$i.t > $DIRNAME/pid$i.plt
	done

# Rename plotting files from pid<nr>.plt, to plt file with pid name
#
PID1_NAME=$(head -n 2 $DIRNAME/pid1.txt | grep -v CPU | awk -F ' ' '{print $12}')
mv $DIRNAME/pid1.plt $DIRNAME/1"_"$PID1_NAME.plt
PID2_NAME=$(head -n 2 $DIRNAME/pid2.txt | grep -v CPU | awk -F ' ' '{print $12}')
mv $DIRNAME/pid2.plt $DIRNAME/2"_"$PID2_NAME.plt
PID3_NAME=$(head -n 2 $DIRNAME/pid3.txt | grep -v CPU | awk -F ' ' '{print $12}')
mv $DIRNAME/pid3.plt $DIRNAME/3"_"$PID3_NAME.plt
PID4_NAME=$(head -n 2 $DIRNAME/pid4.txt | grep -v CPU | awk -F ' ' '{print $12}')
mv $DIRNAME/pid4.plt $DIRNAME/4"_"$PID4_NAME.plt

# Create plot.plt script
#
NR_CPU=$(cat ${DIRNAME}/cpuinfo.txt | wc -l)
echo "set size 1,0.7" > $DIRNAME/plot.plt
echo "set terminal wxt size 1800,500"  >> $DIRNAME/plot.plt 
echo "set title 'CPU Load for MDATP Processes (Max. CPU% = $NR_CPU"00%")'"  >> $DIRNAME/plot.plt
echo "set xlabel 'seconds'" >> $DIRNAME/plot.plt
echo "set ylabel 'CPU %'" >> $DIRNAME/plot.plt
echo "plot 'graphs/1_$PID1_NAME.plt' with linespoints, 'graphs/2_$PID2_NAME.plt' with linespoints, 'graphs/3_$PID3_NAME.plt' with linespoints, 'graphs/4_$PID4_NAME.plt' with linespoints" >> $DIRNAME/plot.plt

##############################################################
#               END creating files for plotting              #    
##############################################################

# Renaming PID files to process name
#
PID1_NAME=$(head -n 2 $DIRNAME/pid1.txt | grep -v CPU | awk -F ' ' '{print $12}')
mv $DIRNAME/pid1.txt $DIRNAME/1"_"$PID1_NAME.log
PID2_NAME=$(head -n 2 $DIRNAME/pid2.txt | grep -v CPU | awk -F ' ' '{print $12}')
mv $DIRNAME/pid2.txt $DIRNAME/2"_"$PID2_NAME.log
PID3_NAME=$(head -n 2 $DIRNAME/pid3.txt | grep -v CPU | awk -F ' ' '{print $12}')
mv $DIRNAME/pid3.txt $DIRNAME/3"_"$PID3_NAME.log
PID4_NAME=$(head -n 2 $DIRNAME/pid4.txt | grep -v CPU | awk -F ' ' '{print $12}')
mv $DIRNAME/pid4.txt $DIRNAME/4"_"$PID4_NAME.log

# Generate report
#
echo -e " *** Creating 'report.txt' file..."

for (( i = 1; i <= $NR_OF_PIDS; i++ ))
	do
		ls $DIRNAME/$i"_"*.log >> $DIRNAME/report.txt
		tail -n4 $DIRNAME/$i"_"*.log >> $DIRNAME/report.txt
		echo "" >> $DIRNAME/report.txt
	done

##############################################################
#         START Generate RTP statistics and top scans        # 
##############################################################

# Detect Python version available. If more than one version found
# we'll go with the most recent version
#
if ! [ -z $PYTHON_V ]
	 then 
		PYTHON="$PYTHON_V"
fi

if ! [ -z $PYTHON2_V ]
	 then 
		PYTHON="$PYTHON2_V"
fi

if ! [ -z $PYTHON3_V ]
	 then 
		PYTHON="$PYTHON3_V"
fi

if ! [ -z $PYTHON ]
	 then 
		echo -e " *** Using Python version $PYTHON."
	 else
		echo -e " *** Python required to generate RTP statistics, but not found."
		echo -e " *** Exiting..."
		exit 0
fi

# Download cpu parser
#
echo -e " *** Downloading CPU parser..."

wget -c $HI_CPU_PARSER_URL -P $DIRNAME/ > /dev/null 2>&1

# Checking download status
#
if [ $? != 0 ]
    then
        echo -e " *** CPU parser was not downloaded successfully."
		echo -e " *** Exiting."
        exit 0
    else
        echo -e " *** Successfully downloaded CPU parser."
fi

# Fixing parser permissions
#
if [ -f $HI_CPU_PARSER_FILE ]
	then	
		echo -e " *** Fixing script permissions..."
		chmod +x $HI_CPU_PARSER_FILE
	else
		echo -e " *** Could not fix script permissions."
		echo -e	" *** Exiting."
		exit 0
fi

# Check RTP enabled
#
mdatp health --field real_time_protection_enabled > /dev/null 2>&1

if [ $? != 0 ]
    then
        echo -e " *** Real Time Protection is not enabled."
        echo -e " *** Please enable RTP and re-run script."
        exit 0
    else
        echo -e " *** Real Time Protection is enabled. [OK]"
fi

# Create top scaned files
#
echo -e " *** Creating statistics..."
mdatp diagnostic real-time-protection-statistics --output json > $DIRNAME/real_time_protection.json

echo -e " *** Building real_time_protection.txt..."
echo "PID-- Process-- Scans-- Path--" > $DIRNAME/real_time_protection_temp.log
cat $DIRNAME/real_time_protection.json | $PYTHON $DIRNAME/high_cpu_parser.py  >> $DIRNAME/real_time_protection_temp.log
cat $DIRNAME/real_time_protection_temp.log | column -t > $DIRNAME/real_time_protection.txt

# Clean helper files
#
rm -rf $DIRNAME/real_time_protection.json $DIRNAME/high_cpu_parser.py $DIRNAME/real_time_protection_temp.log

##############################################################
#       END Generate RTP statistics and top scans            #  
##############################################################

# Tidy up
#
mkdir $DIRNAME/plot $DIRNAME/report $DIRNAME/log $DIRNAME/main $DIRNAME/raw $DIRNAME/rtp_statistics
mkdir $DIRNAME/plot/graphs
mv $DIRNAME/real_time_protection.txt $DIRNAME/rtp_statistics
mv $DIRNAME/*.plt $DIRNAME/plot
mv $DIRNAME/report.txt $DIRNAME/report
mv $DIRNAME/*.log $DIRNAME/log
mv $DIRNAME/main.txt $DIRNAME/main
mv $DIRNAME/*.t $DIRNAME/raw
mv $DIRNAME/free.txt $DIRNAME/os-release.txt $DIRNAME/report
mv $DIRNAME/plot/*.plt $DIRNAME/plot/graphs
mv $DIRNAME/plot/graphs/plot.plt $DIRNAME/plot/

# Silently clean house. The deleted files are raw files used to plot
# and to calculate statistics. Case debuging the script is needed,
# these files will help in fixing existing issues. We will be deleting 
# unecessary files and keep only what the user needs to see for now.
# If debuging is needed, just comment the below line.
rm -rf $DIRNAME/log $DIRNAME/main $DIRNAME/raw $DIRNAME/cpuinfo.txt

echo -e " *** Packaging & compressing '$DIRNAME'... "

DATE_Z=$(date +%d.%m.%Y_%HH%MM%Ss)
PACKAGE_NAME=$DIRNAME"-"$DATE_Z.zip

zip -r $PACKAGE_NAME $DIRNAME > /dev/null 2>&1

echo -e " *** Done. "

#
# EOF
#
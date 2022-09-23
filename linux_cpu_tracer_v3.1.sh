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

HITS=$2
WAIT=$3

# Test "$2" content: must have a value and must be a number.
#RE='^[0-9]+$'
RE='^[0-9]*(\.[0-9]+)?$'

# Define number of seconds to capture 
LIMIT=$2

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

#############################################################
#                   END Define vars     					#
#############################################################

#############################################################
#                  START Define Functions				    #
#############################################################

# Create dir to host performance files (if it does not exist yet)
#
create_dir_struct () {
echo -e " *** Checking if '$DIRNAME' dir exists..."

if [ -d "$DIRNAME" ]
   then
		# Dir exists. No need to create. Clean existent files and moving on.
		#
		echo -e " *** $DIRNAME exists. Deleting..."
		rm -rf $DIRNAME/*
		
		echo -e " *** Done deleting old files."
		
	else
		# Dir does nor exist. Create.
		#
		echo -e " *** $DIRNAME does not exist. Creating..." 	  
		mkdir $DIRNAME
fi
}

check_time_param () {

# Test time capture parameter. If we don't provide a number of seconds, exit.
#
if ! [[ $LIMIT =~ $RE ]]
	then
		echo -e " *** Usage: ./linux_cpu_tracer_v2.sh -s <capture time in seconds>"
		exit 0
fi
}

check_time_param_long () {

# Test time capture parameter. If we don't have meaningful parameters, exit.
#
if [[ $HITS == 0 || $WAIT == 0 ]]
	then
		echo " *** Invalid parameter: zero is not a valid option."
		echo " *** Usage: ./linux_cpu_tracer.sh -l <nr. of samples> <interval in seconds>"
		exit 0
fi

if ! [[ $HITS =~ $RE ]]
	then
	    echo " *** Invalid parameter for number of samples: not a number"
		echo " *** Usage: ./linux_cpu_tracer.sh -l <nr. of samples> <interval in seconds>"
		exit 0
fi

if ! [[ $WAIT =~ $RE ]]
	then
		echo " *** Invalid parameter for interval in seconds: not a number"
		echo " *** Usage: ./linux_cpu_tracer.sh -l <nr. of samples> <interval in seconds>"
		exit 0
fi

if [ -z $HITS ]
	then
	    echo " *** Invalid parameter for number of samples: empty"
		echo " *** Usage: ./linux_cpu_tracer.sh -l <nr. of samples> <interval in seconds>"
		exit 0
fi

if [ -z $WAIT ]
	then
		echo " *** Invalid parameter for interval in seconds: empty"
		echo " *** Usage: ./linux_cpu_tracer.sh -l <nr. of samples> <interval in seconds>"
		exit 0
fi
}

# Feed CPU and RAM statistics inside each PID file.
#
feed_stats () {

for (( i = 1; i <= $NR_OF_PIDS; i++ ))
do
	cat $DIRNAME/pid$i.txt | awk -F ' ' '{ print $2 }' > $DIRNAME/pid$i.cpu.t
	SUM_CPU=$(awk '{Total=Total+$1} END{print Total}' $DIRNAME/pid${i}.cpu.t)
	TOTAL_CPU=$(cat $DIRNAME/pid${i}.cpu.t | wc -l)
	OUT_CPU=$(echo "scale=2; $SUM_CPU/$TOTAL_CPU" | bc -l)
	
	cat $DIRNAME/pid$i.txt | awk -F ' ' '{ print $3 }' > $DIRNAME/pid$i.mem.t
	SUM_MEM=$(awk '{Total=Total+$1} END{print Total}' $DIRNAME/pid${i}.mem.t)
	TOTAL_MEM=$(cat $DIRNAME/pid${i}.mem.t | wc -l)
	OUT_MEM=$(echo "scale=2; $SUM_MEM/$TOTAL_MEM" | bc -l)
	
	echo " Total of lines is for Memory: $TOTAL_MEM" | tee -a $DIRNAME/pid$i.txt
	echo " Sum of values in column for Memory: $SUM_MEM" | tee -a $DIRNAME/pid$i.txt
	echo " Memory Percentage Average is $OUT_MEM%" | tee -a $DIRNAME/pid$i.txt
	
	echo " Total of lines for CPU: $TOTAL_CPU" | tee -a $DIRNAME/pid$i.txt
	echo " Sum of values in column for CPU: $SUM_CPU" | tee -a $DIRNAME/pid$i.txt
	echo " CPU Percentage Average is $OUT_CPU%" | tee -a $DIRNAME/pid$i.txt
done
}

# Check if ZIP is installed
#
check_requirements () {

ZIP=$(which zip 2>/dev/null)
SED=$(which sed 2>/dev/null)
AWK=$(which awk 2>/dev/null)
TOP=$(which top 2>/dev/null)
GREP=$(which grep 2>/dev/null)
TEE=$(which tee 2>/dev/null)

echo " *** Checking base requirements..."

if [[ -z $ZIP || -z $SED ||  -z $AWK || -z $TOP || -z $GREP || -z $TEE ]]
then
	echo -e " *** Base requirements check failed."
		if [ -z $ZIP ]
		then
				echo " *** 'zip' is not installed."
				echo " *** Please install 'zip'."
		fi

		if [ -z $SED ]
		then
				echo " *** 'sed' is not installed."
				echo " *** Please install 'sed'."
		fi

		if [ -z $AWK ]
		then
				echo " *** 'awk' is not installed."
				echo " *** Please install 'sed'."
		fi

		if [ -z $TOP ]
		then
				echo " *** 'top' is not installed."
				echo " *** Please install 'sed'."
		fi

		if [ -z $GREP ]
		then
				echo " *** 'grep' is not installed."
				echo " *** Please install 'sed'."
		fi

		if [ -z $TEE ]
		then
				echo " *** 'tee' is not installed."
				echo " *** Please install 'sed'."
		fi

		exit 0

	else
        echo -e " *** Base requirements met."
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
  top -cbn1 -w512 | grep -e mdatp_audisp_pl -e wdavdaemon | grep -v grep
  sleep 1
done
}

loop_long() {

for (( i = 1; i <= $HITS; i++ ))
do
  echo $(date)
  echo -e "    PID USER      PR   NI   VIRT    RES    SHR S  %CPU  %MEM   TIME+   COMMAND"
  top -cbn1 -w512 | grep -e mdatp_audisp_pl -e wdavdaemon | grep -v grep
  sleep $WAIT
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

collect_info () {

# Collect information about system 
#
echo -e " *** Collecting information..."

cp /etc/os-release $DIRNAME/os-release.txt
free -h > $DIRNAME/free.txt
cat /proc/cpuinfo | grep processor > $DIRNAME/cpuinfo.txt
mdatp health > $DIRNAME/health.txt
df -h > $DIRNAME/df.txt
pstree > $DIRNAME/pstree.txt
ps -ef > $DIRNAME/psef.txt
uname -a > $DIRNAME/uname-a.txt

}

feed_data () {

# Define PID extraction vars (after main file $MAIN_LOGFILENAME' is created)
#
PID1=$(cat $DIRNAME/$MAIN_LOGFILENAME | head -n6 | awk -F ' ' '{ print $1 }' | tail -n +3 | sed '1q;d')
PID2=$(cat $DIRNAME/$MAIN_LOGFILENAME | head -n6 | awk -F ' ' '{ print $1 }' | tail -n +3 | sed '2q;d')
PID3=$(cat $DIRNAME/$MAIN_LOGFILENAME | head -n6 | awk -F ' ' '{ print $1 }' | tail -n +3 | sed '3q;d')
PID4=$(cat $DIRNAME/$MAIN_LOGFILENAME | head -n6 | awk -F ' ' '{ print $1 }' | tail -n +3 | sed '4q;d')

echo -e " *** Creating log files for analysis..."

# Feeding data to files
#
cat $DIRNAME/$MAIN_LOGFILENAME | awk -F ' ' '{ print $1, $9, $10, $12, $13 }' | grep $PID1 >> $DIRNAME/pid1.txt
cat $DIRNAME/$MAIN_LOGFILENAME | awk -F ' ' '{ print $1, $9, $10, $12, $13 }' | grep $PID2 >> $DIRNAME/pid2.txt
cat $DIRNAME/$MAIN_LOGFILENAME | awk -F ' ' '{ print $1, $9, $10, $12, $13 }' | grep $PID3 >> $DIRNAME/pid3.txt
cat $DIRNAME/$MAIN_LOGFILENAME | awk -F ' ' '{ print $1, $9, $10, $12, $13 }' | grep $PID4 >> $DIRNAME/pid4.txt
}

create_plotting_files () {

echo " *** Creating plotting files..."

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
	paste $DIRNAME/merge.t $DIRNAME/pid$i.cpu.t > $DIRNAME/pid$i.cpu.plt
	paste $DIRNAME/merge.t $DIRNAME/pid$i.mem.t > $DIRNAME/pid$i.mem.plt
done

# Rename plotting files from pid<nr>.plt, to plt file with pid name
#
mv $DIRNAME/pid1.cpu.plt $DIRNAME/1"_"$PID1_NAME.cpu.plt
mv $DIRNAME/pid2.cpu.plt $DIRNAME/2"_"$PID2_NAME.cpu.plt
mv $DIRNAME/pid3.cpu.plt $DIRNAME/3"_"$PID3_NAME.cpu.plt
mv $DIRNAME/pid4.cpu.plt $DIRNAME/4"_"$PID4_NAME.cpu.plt

mv $DIRNAME/pid1.mem.plt $DIRNAME/1"_"$PID1_NAME.mem.plt
mv $DIRNAME/pid2.mem.plt $DIRNAME/2"_"$PID2_NAME.mem.plt
mv $DIRNAME/pid3.mem.plt $DIRNAME/3"_"$PID3_NAME.mem.plt
mv $DIRNAME/pid4.mem.plt $DIRNAME/4"_"$PID4_NAME.mem.plt

}
create_plot_graph () {
# Create plot.cpu.plt script
#
NR_CPU=$(cat ${DIRNAME}/cpuinfo.txt | wc -l)
echo "set terminal wxt size 1800,600"  >> $DIRNAME/cpu_plot.plt 
echo "set title 'CPU Load for MDATP Processes (Max. CPU% = $NR_CPU"00%")'"  >> $DIRNAME/cpu_plot.plt
echo "set xlabel 'seconds'" >> $DIRNAME/cpu_plot.plt
echo "set ylabel 'CPU %'" >> $DIRNAME/cpu_plot.plt
echo "set key noenhanced" >> $DIRNAME/cpu_plot.plt
echo "set key right top outside" >> $DIRNAME/cpu_plot.plt
echo "plot 'graphs/1_$PID1_NAME.cpu.plt' with linespoints title '$PID1_NAME','graphs/2_$PID2_NAME.cpu.plt' with linespoints title '$PID2_NAME','graphs/3_$PID3_NAME.cpu.plt' with linespoints title '$PID3_NAME','graphs/4_$PID4_NAME.cpu.plt' with linespoints title '$PID4_NAME'" >> $DIRNAME/cpu_plot.plt

# Create plot.mem.plt script
#
echo "set terminal wxt size 1800,600"  >> $DIRNAME/mem_plot.plt
echo "set title 'Memory Load for MDATP Processes'"  >> $DIRNAME/mem_plot.plt
echo "set xlabel 'seconds'" >> $DIRNAME/mem_plot.plt
echo "set ylabel 'Memory %'" >> $DIRNAME/mem_plot.plt
echo "set key noenhanced" >> $DIRNAME/mem_plot.plt
echo "set key right top outside" >> $DIRNAME/mem_plot.plt
echo "plot 'graphs/1_$PID1_NAME.mem.plt' with linespoints title '$PID1_NAME','graphs/2_$PID2_NAME.mem.plt' with linespoints title '$PID2_NAME', 'graphs/3_$PID3_NAME.mem.plt' with linespoints title '$PID3_NAME','graphs/4_$PID4_NAME.mem.plt' with linespoints title '$PID4_NAME'" >> $DIRNAME/mem_plot.plt
}

create_plot_graph_long () {
# Create plot.cpu.plt script
#
NR_CPU=$(cat ${DIRNAME}/cpuinfo.txt | wc -l)
echo "set terminal wxt size 1800,600"  >> $DIRNAME/cpu_plot.plt 
echo "set title 'CPU Load for MDATP Processes (Max. CPU% = $NR_CPU"00%")'"  >> $DIRNAME/cpu_plot.plt
echo "set xlabel 'Samples in $WAIT second intervals'" >> $DIRNAME/cpu_plot.plt
echo "set ylabel 'CPU %'" >> $DIRNAME/cpu_plot.plt
echo "set key noenhanced" >> $DIRNAME/cpu_plot.plt
echo "set key right top outside" >> $DIRNAME/cpu_plot.plt
echo "plot 'graphs/1_$PID1_NAME.cpu.plt' with linespoints title '$PID1_NAME','graphs/2_$PID2_NAME.cpu.plt' with linespoints title '$PID2_NAME', 'graphs/3_$PID3_NAME.cpu.plt' with linespoints title '$PID3_NAME','graphs/4_$PID4_NAME.cpu.plt' with linespoints title '$PID4_NAME'" >> $DIRNAME/cpu_plot.plt

# Create plot.mem.plt script
#
echo "set terminal wxt size 1800,600"  >> $DIRNAME/mem_plot.plt
echo "set title 'Memory Load for MDATP Processes'"  >> $DIRNAME/mem_plot.plt
echo "set xlabel 'Samples in $WAIT second intervals'" >> $DIRNAME/mem_plot.plt
echo "set ylabel 'Memory %'" >> $DIRNAME/mem_plot.plt
echo "set key noenhanced" >> $DIRNAME/mem_plot.plt
echo "set key right top outside" >> $DIRNAME/mem_plot.plt
echo "plot 'graphs/1_$PID1_NAME.mem.plt' with linespoints title '$PID1_NAME','graphs/2_$PID2_NAME.mem.plt' with linespoints title '$PID2_NAME', 'graphs/3_$PID3_NAME.mem.plt' with linespoints title '$PID3_NAME','graphs/4_$PID4_NAME.mem.plt' with linespoints title '$PID4_NAME'" >> $DIRNAME/mem_plot.plt
}

rename_pid_to_process () {

# Renaming PID files to process name
#
PID1_NAME_TMP=$(head -n 1 ${DIRNAME}/pid1.txt | awk -F ' ' '{print $4, $5}' | awk -F '/' '{print $6}' | sed 's/ *$//')
PID1_NAME=$(tr -s ' ' '_' <<< ${PID1_NAME_TMP})
mv $DIRNAME/pid1.txt $DIRNAME/1"_"$PID1_NAME.log
PID2_NAME_TMP=$(head -n 1 ${DIRNAME}/pid2.txt | awk -F ' ' '{print $4, $5}' | awk -F '/' '{print $6}' | sed 's/ *$//')
PID2_NAME=$(tr -s ' ' '_' <<< ${PID2_NAME_TMP})
mv $DIRNAME/pid2.txt $DIRNAME/2"_"$PID2_NAME.log
PID3_NAME_TMP=$(head -n 1 ${DIRNAME}/pid3.txt | awk -F ' ' '{print $4, $5}' | awk -F '/' '{print $6}' | sed 's/ *$//')
PID3_NAME=$(tr -s ' ' '_' <<< ${PID3_NAME_TMP})
mv $DIRNAME/pid3.txt $DIRNAME/3"_"$PID3_NAME.log
PID4_NAME_TMP=$(head -n 1 ${DIRNAME}/pid4.txt | awk -F ' ' '{print $4, $5}' | awk -F '/' '{print $6}' | sed 's/ *$//')
PID4_NAME=$(tr -s ' ' '_' <<< ${PID4_NAME_TMP})
mv $DIRNAME/pid4.txt $DIRNAME/4"_"$PID4_NAME.log
}

generate_report () {

# Generate report
#
echo -e " *** Creating 'report.txt' file..."

for (( i = 1; i <= $NR_OF_PIDS; i++ ))
	do
		ls $DIRNAME/$i"_"*.log >> $DIRNAME/report.txt
		tail -n6 $DIRNAME/$i"_"*.log >> $DIRNAME/report.txt
		echo "" >> $DIRNAME/report.txt
	done
}

detect_python_version ()  {

# Define vars to work with python detection function
PYTHON_V=$(which python 2> /dev/null)
PYTHON2_V=$(which python2 2> /dev/null)
PYTHON3_V=$(which python3 2> /dev/null)
PYTHON=""

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
}

download_cpu_parser () {

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
}

check_rtp_enabled () {

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
}

create_top_scanned_files () {

# Create top scanned files
#
echo -e " *** Creating statistics..."
mdatp diagnostic real-time-protection-statistics --output json > $DIRNAME/real_time_protection.json

echo -e " *** Building real_time_protection.txt..."
echo "PID-- Process-- Scans-- Path--" > $DIRNAME/real_time_protection_temp.log
cat $DIRNAME/real_time_protection.json | $PYTHON $DIRNAME/high_cpu_parser.py  >> $DIRNAME/real_time_protection_temp.log
cat $DIRNAME/real_time_protection_temp.log | column -t > $DIRNAME/real_time_protection.txt
}

tidy_up () {

# Tidy up
#
mkdir $DIRNAME/plot $DIRNAME/report $DIRNAME/log $DIRNAME/main $DIRNAME/raw $DIRNAME/rtp_statistics  
mkdir $DIRNAME/plot/graphs
mv $DIRNAME/real_time_protection.txt $DIRNAME/rtp_statistics
mv $DIRNAME/main.txt $DIRNAME/main
mv $DIRNAME/*.txt $DIRNAME/report
mv $DIRNAME/*.plt $DIRNAME/plot
mv $DIRNAME/*.log $DIRNAME/log
mv $DIRNAME/*.t $DIRNAME/raw
mv $DIRNAME/plot/*.plt $DIRNAME/plot/graphs
mv $DIRNAME/plot/graphs/cpu_plot.plt $DIRNAME/plot/graphs/mem_plot.plt $DIRNAME/plot/
}

tidy_up_long () {

mkdir $DIRNAME/plot $DIRNAME/report $DIRNAME/log $DIRNAME/main $DIRNAME/raw  
mkdir $DIRNAME/plot/graphs
mv $DIRNAME/main.txt $DIRNAME/main
mv $DIRNAME/*.txt $DIRNAME/report
mv $DIRNAME/*.plt $DIRNAME/plot
mv $DIRNAME/*.log $DIRNAME/log
mv $DIRNAME/*.t $DIRNAME/raw
mv $DIRNAME/plot/*.plt $DIRNAME/plot/graphs
mv $DIRNAME/plot/graphs/cpu_plot.plt $DIRNAME/plot/graphs/mem_plot.plt $DIRNAME/plot/
}

clean_house () {

	rm -rf $DIRNAME/log $DIRNAME/main $DIRNAME/raw
	rm -rf $DIRNAME/real_time_protection.json $DIRNAME/high_cpu_parser.py $DIRNAME/real_time_protection_temp.log
}

package_and_compress () {

echo -e " *** Packaging & compressing '$DIRNAME'... "

DATE_Z=$(date +%d.%m.%Y_%HH%MM%Ss)
PACKAGE_NAME=$DIRNAME"-"$DATE_Z.zip

zip -r $PACKAGE_NAME $DIRNAME > /dev/null 2>&1

echo -e " *** Done. "
}

long_run () {

for (( i = 1; i <= $HITS; i++ ))
do
  echo $(date)
  echo -e "    PID USER      PR   NI   VIRT    RES    SHR S  %CPU  %MEM   TIME+   COMMAND"
  top -cbn1 -w512 | grep -e mdatp_audisp_pl -e wdavdaemon | grep -v grep
  sleep $WAIT
done
}

echo_loop () {

echo -e " *** Collecting data for $LIMIT seconds..."
}

echo_loop_long () {

echo -e " *** Collecting $HITS samples in $WAIT second intervals"
}

get_pid_init () {
DATE_START=$(date +%d.%m.%Y_%HH%MM%Ss)
rm -rf /tmp/linux_cpu_tracer*
bash -c 'echo $PPID' > /tmp/linux_cpu_tracer_start-$DATE_START.pid
}

get_pid_stop () {
DATE_STOP=$(date +%d.%m.%Y_%HH%MM%Ss)
cp /tmp/linux_cpu_tracer_start-$DATE_START.pid /tmp/linux_cpu_tracer_stop-$DATE_STOP.pid
}

disclaimer () {
echo "********************************** DISCLAIMER ***************************************************"
echo "This sample script is not supported under any Microsoft standard support program or service."
echo "The sample script is provided “AS IS” without warranty of any kind. Microsoft further disclaims"
echo "all implied warranties including, without limitation, any implied warranties of merchantability" 
echo "or of fitness for a particular purpose. The entire risk arising out of the use or performance of"
echo "the sample scripts and documentation remains with you. In no event shall Microsoft, its authors,"
echo "or anyone else involved in the creation, production, or delivery of the scripts be liable for any" 
echo "damages whatsoever (including, without limitation, damages for loss of business profits, business"
echo "interruption, loss of business information, or other pecuniary loss) arising out of the use of or" 
echo "inability to use the sample scripts or documentation, even if Microsoft has been advised of the "
echo "possibility of such damages."
echo "*************************************************************************************************"
}

#############################################################
#                   END Define Functions				    #
#############################################################

case $1 in

		-s)
			check_time_param
			check_mdatp_running
			check_requirements
			create_dir_struct
			collect_info
			echo_loop
			loop > $DIRNAME/$MAIN_LOGFILENAME | count
			feed_data
			feed_stats > /dev/null 2>&1
			rename_pid_to_process
			create_plotting_files
			create_plot_graph
			generate_report
			detect_python_version
			download_cpu_parser
			check_rtp_enabled
			create_top_scanned_files
			tidy_up
			clean_house
			package_and_compress
		;;
		
		-l) 
			get_pid_init
			check_time_param_long
			check_mdatp_running
			check_requirements
			create_dir_struct
			collect_info
			echo_loop_long
			loop_long > $DIRNAME/$MAIN_LOGFILENAME
			feed_data
			feed_stats > /dev/null 2>&1
			rename_pid_to_process
			create_plotting_files
			create_plot_graph_long
			generate_report
			tidy_up_long
			clean_house
			package_and_compress
			get_pid_stop
		;;
		
		-d) 
			disclaimer
		;;
		
		-h) 
			echo " *** Usage: ./linux_cpu_tracer.sh -s <time to capture in seconds>."
		    echo "            ./linux_cpu_tracer.sh -l <nr. of samples> <sampling interval in seconds>"
			echo "            ./linux_cpu_tracer.sh -d, to read disclaimer"            
		;;
		
		*) 
			echo " *** Invalid parameter. Please check script usage with '-h' option." 
		;;
esac

#
# EOF
#
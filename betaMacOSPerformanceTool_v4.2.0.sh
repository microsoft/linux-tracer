#!/bin/bash
#
echo "$0 $@" > betaMacOSPerformanceTool.log
(
#############################################################
#                   START Define vars     				    #
#############################################################

SCRIPT_VERSION=4.2.0

HITS=$2
WAIT=$3

# Test "$2" content: must have a value and must be a number.
RE='^[0-9]+$'
FLOAT='^[0-9]*(\.[0-9]+)?$'

# Define number of seconds to capture 
LIMIT=$2

# Define number of MDATP processes to check
NR_OF_PIDS=3

# Define main log file name
MAIN_LOGFILENAME=main.txt

# Define dir file name
DIRNAME=betaMacOSPerformanceTool

#############################################################
#                   END Define vars     					#
#############################################################

#############################################################
#                  START Define Functions				    #
#############################################################

create_dir_struct () {
echo -e " *** Checking if '$DIRNAME' dir exists..."

if [ -d "$DIRNAME" ]
   then
		echo -e " *** '$DIRNAME' exists. Deleting..."
		sudo rm -rf $DIRNAME/*
		
		echo -e " *** Done deleting old files."
		
	else
		echo -e " *** '$DIRNAME' does not exist. Creating..." 	  
		mkdir $DIRNAME
fi
}

check_time_param () {
if ! [[ $LIMIT =~ $RE ]]
	then
		echo -e " *** Usage: ./betaMacOSPerformanceTool.sh -ps <capture time in seconds>"
		exit 0
fi
}

check_time_param_long () {
if [[ $HITS == 0 || $WAIT == 0 ]]
	then
		echo " *** Invalid parameter: zero is not a valid option."
		echo " *** Usage: ./betaMacOSPerformanceTool.sh -pl <nr. of samples> <interval in seconds>"
		exit 0
fi

if ! [[ $HITS =~ $RE ]]
	then
	    echo " *** Invalid parameter for number of samples: not a number or not an integer."
		echo " *** Usage: ./betaMacOSPerformanceTool.sh -pl <nr. of samples> <interval in seconds>"
		exit 0
fi

if ! [[ $WAIT =~ $FLOAT || $WAIT =~ $RE ]]
	then
		echo " *** Invalid parameter for interval in seconds: not a number"
		echo " *** Usage: ./betaMacOSPerformanceTool.sh -pl <nr. of samples> <interval in seconds>"
		exit 0
fi

if [ -z $HITS ]
	then
	    echo " *** Invalid parameter for number of samples: empty"
		echo " *** Usage: ./betaMacOSPerformanceTool.sh -pl <nr. of samples> <interval in seconds>"
		exit 0
fi

if [ -z $WAIT ]
	then
		echo " *** Invalid parameter for interval in seconds: empty"
		echo " *** Usage: ./betaMacOSPerformanceTool.sh -pl <nr. of samples> <interval in seconds>"
		exit 0
fi
}

feed_stats () {
for (( i = 1; i <= $NR_OF_PIDS; i++ ))
do
	cat $DIRNAME/pid$i.txt | awk -F ' ' '{ print $3 }' > $DIRNAME/pid$i.cpu.t
	SUM_CPU=$(awk '{Total=Total+$1} END{print Total}' $DIRNAME/pid${i}.cpu.t)
	TOTAL_CPU=$(cat $DIRNAME/pid${i}.cpu.t | wc -l)
	OUT_CPU=$(echo "scale=2; $SUM_CPU/$TOTAL_CPU" | bc -l)

	cat $DIRNAME/pid$i.txt | awk -F ' ' '{ print $4 }' > $DIRNAME/pid$i.mem.t
	
	echo " Total CPU samples fetched: $TOTAL_CPU" | tee -a $DIRNAME/pid$i.txt
	echo " Sum of values in column for CPU: $SUM_CPU" | tee -a $DIRNAME/pid$i.txt
	echo " CPU Percentage Average is $OUT_CPU%" | tee -a $DIRNAME/pid$i.txt
done
}

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

collect_info () {
sysctl -n machdep.cpu.brand_string > $DIRNAME/cpu_brand.txt
sysctl -n hw.ncpu > $DIRNAME/cpu_count.txt
df -h > $DIRNAME/df.txt
ps -ef > $DIRNAME/psef.txt
sudo dmesg > $DIRNAME/dmesg.txt
}

check_mdatp_running () {
echo -e " *** Checking if 'mdatp' is installed..."
which mdatp > /dev/null 2>&1

if [ $? != 0 ]
	then
		echo -e " *** Cannot find 'mdatp'."
		echo -e " *** Please confirm 'mdatp' is installed on your system."
		exit 0
	else
		echo -e " *** 'mdatp' is installed."
fi

echo -e " *** Checking if 'wdavdaemon privileged' process is running..."

ps aux | grep "wdavdaemon privileged" | grep -v grep > /dev/null 2>&1

if [ $? != 0 ]
	then
		echo -e " *** 'wdavdaemon privileged' process is not running."
		echo -e " ***  Exiting."
		exit 0
	else
		echo -e " *** 'wdavdaemon privileged' process is running."
fi

echo -e " *** Checking if 'wdavdaemon_enterprise edr' process is running..."

ps aux | grep "wdavdaemon_enterprise edr" | grep -v grep > /dev/null 2>&1

if [ $? != 0 ]
	then
		echo -e " *** 'wdavdaemon_enterprise edr' process is not running."
		echo -e " ***  Exiting."
		exit 0
	else
		echo -e " *** 'wdavdaemon_enterprise edr' process is running."
fi

echo -e " *** Checking if 'wdavdaemon_unprivileged' process is running..."

ps aux | grep "wdavdaemon_unprivileged unprivileged" | grep -v grep > /dev/null 2>&1

if [ $? != 0 ]
	then
		echo -e " *** 'wdavdaemon_unprivileged' process is not running."
		echo -e " ***  Exiting."
		exit 0
	else
		echo -e " *** 'wdavdaemon_unprivileged' process is running."
fi
}

get_rtp_stats () {
echo " *** Creating statistics..."
sudo mdatp config real-time-protection-statistics --value enabled > /dev/null 2>&1
mdatp diagnostic real-time-protection-statistics > $DIRNAME/rtp_stats_tmp1.log # Gather mdatp statistics

totalFiles=$(cat $DIRNAME/rtp_stats_tmp1.log | grep -e "Total" | awk '{print $4}') # Get Array with total files;
sortedFiles=($(printf '%s\n' "${totalFiles[@]}" | sort -nru))

for ((c=0; c<=4; c++))
do       
	if ((! ${sortedFiles[$c]} == 0))
	then
		nl=$(grep -n -w "Total files scanned: ${sortedFiles[$c]}" $DIRNAME/rtp_stats_tmp1.log | head -1 | awk -F ':' '{print $1}') # Get number of line
		awk "NR==$(($nl-4)), NR==$(($nl+3))" $DIRNAME/rtp_stats_tmp1.log >> $DIRNAME/rtp_statistics.txt # Get Initiator

	else
		echo "No statistics available." > $DIRNAME/rtp_statistics.txt
	fi
done
}

loop() {
for (( i = 1; i <= $LIMIT; i++ ))
do
  echo $(date)
  echo -e "  PID COMMAND     %CPU   %MEM"
  top -l1 | grep -e wdavdaemon_enter -e wdavdaemon_unpri -e wdavdaemon | awk '{print $1,$2,$3,$8}'
  # (processing time)+(wait time)=1 <=> 0.2+0.8=1 second
  sleep 0.8
done
}

loop_long() {
for (( i = 1; i <= $HITS; i++ ))
do
  echo $(date)
  echo -e "  PID COMMAND     %CPU   %MEM"
  top -l1 | grep -e wdavdaemon_enter -e wdavdaemon_unpri -e wdavdaemon | awk '{print $1,$2,$3,$8}'
  sleep $WAIT
done
}

count() {
INIT=1
while [ $INIT -lt $LIMIT ]
do
	echo -ne "     $INIT/$LIMIT \033[0K\r"
	sleep 1
	: $((INIT++))
done
}

count_long() {
INIT=1
while [ $INIT -lt $HITS ]
do
	echo -ne "     $INIT/$HITS \033[0K\r"
	sleep $WAIT
	: $((INIT++))
done
}

feed_data () {
PID1=$(cat $DIRNAME/$MAIN_LOGFILENAME | head -n6 | awk -F ' ' '{ print $1 }' | tail -n +3 | sed '1q;d')
PID2=$(cat $DIRNAME/$MAIN_LOGFILENAME | head -n6 | awk -F ' ' '{ print $1 }' | tail -n +3 | sed '2q;d')
PID3=$(cat $DIRNAME/$MAIN_LOGFILENAME | head -n6 | awk -F ' ' '{ print $1 }' | tail -n +3 | sed '3q;d')

echo -e " *** Creating log files for analysis..."

cat $DIRNAME/$MAIN_LOGFILENAME | awk -F ' ' '{ print $1, $2, $3, $4 }' | grep $PID1 >> $DIRNAME/pid1.txt
cat $DIRNAME/$MAIN_LOGFILENAME | awk -F ' ' '{ print $1, $2, $3, $4 }' | grep $PID2 >> $DIRNAME/pid2.txt
cat $DIRNAME/$MAIN_LOGFILENAME | awk -F ' ' '{ print $1, $2, $3, $4 }' | grep $PID3 >> $DIRNAME/pid3.txt
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

mv $DIRNAME/pid1.mem.plt $DIRNAME/1"_"$PID1_NAME.mem.plt
mv $DIRNAME/pid2.mem.plt $DIRNAME/2"_"$PID2_NAME.mem.plt
mv $DIRNAME/pid3.mem.plt $DIRNAME/3"_"$PID3_NAME.mem.plt

}

create_plot_graph () {

# Declare function vars
#
NR_CPU=$(sysctl -n hw.ncpu)
PLOT_DATE=$(date)
HOSTNAME=$(hostname)
OS=$(sw_vers |  grep ProductVersion | awk -F ':' '{ print $2  }' |  tail -c +2)
RTP_TEST=$(mdatp health | grep "real_time_protection_enabled" | awk -F ':' '{ print $2 }')
PASSV_M_TEST=$(mdatp health | grep passive_mode | awk -F ':' '{ print $2 }')
APP_VERSION=$(mdatp health | grep app_version | awk -F ':' '{ print $2  }' | tail -c +3 | sed 's/.$//')

# Create plot.cpu.plt script
#
echo "set terminal wxt size 1800,600"  >> $DIRNAME/cpu_plot.plt 
echo "set title 'CPU Load for MDATP Processes (Max. CPU% = $NR_CPU"00%")   -   $PLOT_DATE'"  >> $DIRNAME/cpu_plot.plt
echo "set xlabel 'seconds'" >> $DIRNAME/cpu_plot.plt
echo "set ylabel 'CPU %'" >> $DIRNAME/cpu_plot.plt
echo "set key noenhanced" >> $DIRNAME/cpu_plot.plt
echo "set key right top outside" >> $DIRNAME/cpu_plot.plt
echo "set rmargin 40" >> $DIRNAME/cpu_plot.plt
echo "set label '       ------ System information ------' at graph 1, graph 0.75" >> $DIRNAME/cpu_plot.plt
echo "set label '       $PLOT_DATE' at graph 1, graph 0.70" >> $DIRNAME/cpu_plot.plt
echo "set label '    Hostname: $HOSTNAME' at graph 1, graph 0.63" >> $DIRNAME/cpu_plot.plt
echo "set label '    OS: $OS' at graph 1, graph 0.58" >> $DIRNAME/cpu_plot.plt
echo "set label '    Real Time Protection: $RTP_TEST' at graph 1, graph 0.53" >> $DIRNAME/cpu_plot.plt
echo "set label '    Passive Mode: $PASSV_M_TEST' at graph 1, graph 0.48" >> $DIRNAME/cpu_plot.plt
echo "set label '    App. Version: $APP_VERSION' at graph 1, graph 0.38" >> $DIRNAME/cpu_plot.plt
echo "plot 'graphs/1_$PID1_NAME.cpu.plt' with linespoints title '$PID1_NAME','graphs/2_$PID2_NAME.cpu.plt' with linespoints title '$PID2_NAME','graphs/3_$PID3_NAME.cpu.plt' with linespoints title '$PID3_NAME','graphs/4_$PID4_NAME.cpu.plt' with linespoints title '$PID4_NAME'" >> $DIRNAME/cpu_plot.plt

# Create plot.mem.plt script
#
echo "set terminal wxt size 1800,600"  >> $DIRNAME/mem_plot.plt
echo "set title 'Memory Load for MDATP Processes'"  >> $DIRNAME/mem_plot.plt
echo "set xlabel 'seconds'" >> $DIRNAME/mem_plot.plt
echo "set ylabel 'Memory MB'" >> $DIRNAME/mem_plot.plt
echo "set key noenhanced" >> $DIRNAME/mem_plot.plt
echo "set key right top outside" >> $DIRNAME/mem_plot.plt
echo "set rmargin 40" >> $DIRNAME/mem_plot.plt
echo "set label '       ------ System information ------' at graph 1, graph 0.75" >> $DIRNAME/mem_plot.plt
echo "set label '       $PLOT_DATE' at graph 1, graph 0.70" >> $DIRNAME/mem_plot.plt
echo "set label '    Hostname: $HOSTNAME' at graph 1, graph 0.63" >> $DIRNAME/mem_plot.plt
echo "set label '    OS: $OS' at graph 1, graph 0.58" >> $DIRNAME/mem_plot.plt
echo "set label '    Real Time Protection: $RTP_TEST' at graph 1, graph 0.53" >> $DIRNAME/mem_plot.plt
echo "set label '    Passive Mode: $PASSV_M_TEST' at graph 1, graph 0.48" >> $DIRNAME/mem_plot.plt
echo "set label '    App. Version: $APP_VERSION' at graph 1, graph 0.38" >> $DIRNAME/mem_plot.plt
echo "plot 'graphs/1_$PID1_NAME.mem.plt' with linespoints title '$PID1_NAME','graphs/2_$PID2_NAME.mem.plt' with linespoints title '$PID2_NAME', 'graphs/3_$PID3_NAME.mem.plt' with linespoints title '$PID3_NAME','graphs/4_$PID4_NAME.mem.plt' with linespoints title '$PID4_NAME'" >> $DIRNAME/mem_plot.plt
}

create_plot_graph_long () {

# Declare function vars
#
NR_CPU=$(sysctl -n hw.ncpu)
PLOT_DATE=$(date)
HOSTNAME=$(hostname)
OS=$(sw_vers |  grep ProductVersion | awk -F ':' '{ print $2  }' |  tail -c +2)
RTP_TEST=$(mdatp health | grep "real_time_protection_enabled" | awk -F ':' '{ print $2 }')
PASSV_M_TEST=$(mdatp health | grep passive_mode | awk -F ':' '{ print $2 }')
APP_VERSION=$(mdatp health | grep app_version | awk -F ':' '{ print $2  }' | tail -c +3 | sed 's/.$//')

# Create mem.cpu.plt script for long running flag
#
echo "set terminal wxt size 1800,600"  >> $DIRNAME/cpu_plot.plt 
echo "set title 'CPU Load for MDATP Processes (Max. CPU% = $NR_CPU"00%")'"  >> $DIRNAME/cpu_plot.plt
echo "set xlabel 'Samples in $WAIT second intervals'" >> $DIRNAME/cpu_plot.plt
echo "set ylabel 'CPU %'" >> $DIRNAME/cpu_plot.plt
echo "set key noenhanced" >> $DIRNAME/cpu_plot.plt
echo "set key right top outside" >> $DIRNAME/cpu_plot.plt
echo "set rmargin 40" >> $DIRNAME/cpu_plot.plt
echo "set label '       ------ System information ------' at graph 1, graph 0.75" >> $DIRNAME/cpu_plot.plt
echo "set label '       $PLOT_DATE' at graph 1, graph 0.70" >> $DIRNAME/cpu_plot.plt
echo "set label '    OS: $OS' at graph 1, graph 0.63" >> $DIRNAME/cpu_plot.plt
echo "set label '    Real Time Protection: $RTP_TEST' at graph 1, graph 0.58" >> $DIRNAME/cpu_plot.plt
echo "set label '    Passive Mode: $PASSV_M_TEST' at graph 1, graph 0.53" >> $DIRNAME/cpu_plot.plt
echo "set label '    App. Version: $APP_VERSION' at graph 1, graph 0.38" >> $DIRNAME/cpu_plot.plt
echo "plot 'graphs/1_$PID1_NAME.cpu.plt' with linespoints title '$PID1_NAME','graphs/2_$PID2_NAME.cpu.plt' with linespoints title '$PID2_NAME', 'graphs/3_$PID3_NAME.cpu.plt' with linespoints title '$PID3_NAME','graphs/4_$PID4_NAME.cpu.plt' with linespoints title '$PID4_NAME'" >> $DIRNAME/cpu_plot.plt

# Create plot.mem.plt script for long running flag
#
echo "set terminal wxt size 1800,600"  >> $DIRNAME/mem_plot.plt
echo "set title 'Memory Load for MDATP Processes'"  >> $DIRNAME/mem_plot.plt
echo "set xlabel 'Samples in $WAIT second intervals'" >> $DIRNAME/mem_plot.plt
echo "set ylabel 'Memory MB'" >> $DIRNAME/mem_plot.plt
echo "set key noenhanced" >> $DIRNAME/mem_plot.plt
echo "set key right top outside" >> $DIRNAME/mem_plot.plt
echo "set rmargin 40" >> $DIRNAME/mem_plot.plt
echo "set label '       ------ System information ------' at graph 1, graph 0.75" >> $DIRNAME/mem_plot.plt
echo "set label '       $PLOT_DATE' at graph 1, graph 0.70" >> $DIRNAME/mem_plot.plt
echo "set label '    OS: $OS' at graph 1, graph 0.63" >> $DIRNAME/mem_plot.plt
echo "set label '    Real Time Protection: $RTP_TEST' at graph 1, graph 0.58" >> $DIRNAME/mem_plot.plt
echo "set label '    Passive Mode: $PASSV_M_TEST' at graph 1, graph 0.53" >> $DIRNAME/mem_plot.plt
echo "set label '    App. Version: $APP_VERSION' at graph 1, graph 0.38" >> $DIRNAME/cpu_plot.plt
echo "plot 'graphs/1_$PID1_NAME.mem.plt' with linespoints title '$PID1_NAME','graphs/2_$PID2_NAME.mem.plt' with linespoints title '$PID2_NAME', 'graphs/3_$PID3_NAME.mem.plt' with linespoints title '$PID3_NAME','graphs/4_$PID4_NAME.mem.plt' with linespoints title '$PID4_NAME'" >> $DIRNAME/mem_plot.plt
}

rename_pid_to_process () {

# Renaming PID files to process name
#
PID1_NAME_TMP=$(head -n 1 ${DIRNAME}/pid1.txt | awk -F ' ' '{print $2}')
PID1_NAME=$(tr -s ' ' '_' <<< ${PID1_NAME_TMP})
cp $DIRNAME/pid1.txt $DIRNAME/1"_"$PID1_NAME.log
PID2_NAME_TMP=$(head -n 1 ${DIRNAME}/pid2.txt | awk -F ' ' '{print $2}')
PID2_NAME=$(tr -s ' ' '_' <<< ${PID2_NAME_TMP})
cp $DIRNAME/pid2.txt $DIRNAME/2"_"$PID2_NAME.log
PID3_NAME_TMP=$(head -n 1 ${DIRNAME}/pid3.txt | awk -F ' ' '{print $2}')
PID3_NAME=$(tr -s ' ' '_' <<< ${PID3_NAME_TMP})
cp $DIRNAME/pid3.txt $DIRNAME/3"_"$PID3_NAME.log
}

generate_report () {
echo -e " *** Creating 'report.txt' file..."

for (( i = 1; i <= $NR_OF_PIDS; i++ ))
	do
		ls $DIRNAME/$i"_"*.log >> $DIRNAME/report.txt
		tail -n3 $DIRNAME/$i"_"*.log >> $DIRNAME/report.txt
		echo "" >> $DIRNAME/report.txt
	done
}

check_rtp_enabled () {
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

tidy_up () {
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
	rm -rf $DIRNAME/report/pid1.txt $DIRNAME/report/pid2.txt $DIRNAME/report/pid3.txt
}

package_and_compress () {
echo -e " *** Packaging & compressing '$DIRNAME'... "

DATE_Z=$(date +%d.%m.%Y_%HH%MM%Ss)
PACKAGE_NAME=$DIRNAME"-"$DATE_Z.zip

sudo zip -r $PACKAGE_NAME $DIRNAME > /dev/null 2>&1

echo -e " *** Done. "
}

append_log_file () {

sudo zip $PACKAGE_NAME betaMacOSPerformanceTool.log
}

append_pid_files () {

if [ -f /tmp/betaMacOSPerformanceTool_start-$DATE_START.pid ]
	then 
		cp /tmp/betaMacOSPerformanceTool_start-$DATE_START.pid .
		sudo zip -g $PACKAGE_NAME betaMacOSPerformanceTool_start-$DATE_START.pid
fi

if [ -f /tmp/betaMacOSPerformanceTool_stop-$DATE_STOP.pid ]
	then 
		cp /tmp/betaMacOSPerformanceTool_stop-$DATE_STOP.pid .
		sudo zip -g $PACKAGE_NAME betaMacOSPerformanceTool_stop-$DATE_STOP.pid
fi
}

echo_loop () {

echo " *** Collecting data for $LIMIT seconds..."
}

echo_loop_long () {

echo " *** Collecting $HITS samples in $WAIT second intervals"
}

get_pid_init () {
DATE_START=$(date +%d.%m.%Y_%HH%MM%Ss)
rm -rf /tmp/betaMacOSPerformanceTool*
bash -c 'echo $PPID' > /tmp/betaMacOSPerformanceTool_start-$DATE_START.pid
}

get_pid_stop () {
DATE_STOP=$(date +%d.%m.%Y_%HH%MM%Ss)
cp /tmp/betaMacOSPerformanceTool_start-$DATE_START.pid /tmp/betaMacOSPerformanceTool_stop-$DATE_STOP.pid
}

disclaimer () {

if ! [ -f .consent.txt ]
then 

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
	echo "Do you agree with running the script after reading the above disclaimer? [y]Yes [n]No"

	read consent
	if  [ ! $consent == "y" ]
	then
		exit 0
	fi
	
	touch .consent.txt
fi
}

calc () {

    hour_minute () {
        read -p  " *** How long do you want to capture for? (hours): " CAPTURE_PERIOD

		if ! [[ $CAPTURE_PERIOD =~ ^[0-9]+$ ]]
        then    
            echo " *** Invalid parameter. Re-run script and try again."
            exit 0
        fi

        echo "   > Capture period will be $CAPTURE_PERIOD hours."

        read -p  " *** What will be your capture interval? (minutes): " CAPTURE_INTERVAL

		if ! [[ $CAPTURE_INTERVAL =~ ^[0-9]+$ ]]
        then    
            echo " *** Invalid parameter. Re-run script and try again."
            exit 0
        fi

        echo "   > Capture interval will be $CAPTURE_INTERVAL minutes."

        PARAM1_UP=$(echo "scale=0; ${CAPTURE_PERIOD}*3600" | bc -l)
        #echo $PARAM1_UP
        PARAM1_DWN=$(echo "scale=0; ${CAPTURE_INTERVAL}*60" | bc -l)
        #echo $PARAM1_DWN
        PARAM1=$(echo "scale=0; $PARAM1_UP/$PARAM1_DWN" | bc -l)
        #echo $PARAM1

        echo " *** For a $CAPTURE_PERIOD hours capture in $CAPTURE_INTERVAL minutes interval, this is your command: './betaMacOSPerformanceTool.sh -pl $PARAM1 $PARAM1_DWN'"
        echo " *** Use 'nohup ./betaMacOSPerformanceTool.sh -pl $PARAM1 $PARAM1_DWN &' to be able to disconnect your remote session and keep capture going"
    }

    minute_second () {

        read -p  " *** How long do you want to capture for? (minutes): " CAPTURE_PERIOD
        

        if ! [[ $CAPTURE_PERIOD =~ ^[0-9]+$ ]]
        then    
            echo " *** Invalid parameter. Re-run script and try again."
            exit 0
        fi

		echo "   > Capture period will be $CAPTURE_PERIOD minutes."

        read -p  " *** What will be your capture interval? (seconds): " CAPTURE_INTERVAL
        
        if ! [[ $CAPTURE_INTERVAL =~ ^[0-9]*(\.[0-9]+)?$ ]]
        then    
            echo " *** Invalid parameter. Re-run script and try again."
            exit 0
        fi

		echo "   > Capture interval will be $CAPTURE_INTERVAL seconds."

        PARAM1_UP=$(echo "scale=1; ${CAPTURE_PERIOD}*60" | bc -l)
        PARAM1_DWN=${CAPTURE_INTERVAL}
        PARAM1=$(echo "scale=0; $PARAM1_UP/$PARAM1_DWN" | bc -l)

        echo " *** For a $CAPTURE_PERIOD minutes capture in $CAPTURE_INTERVAL seconds interval, this is your command: './betaMacOSPerformanceTool.sh -pl $PARAM1 $PARAM1_DWN'"
        echo " *** Use 'nohup ./betaMacOSPerformanceTool.sh -pl $PARAM1 $PARAM1_DWN &' to be able to disconnect your remote session and keep capture going"
    }

    hour_second () {

        read -p  " *** How long do you want to capture for? (hours): " CAPTURE_PERIOD
        
        if ! [[ $CAPTURE_PERIOD =~ ^[0-9]+$ ]]
        then    
            echo " *** Invalid parameter. Re-run script and try again."
            exit 0
        fi

		echo "   > Capture period will be $CAPTURE_PERIOD hours."

        read -p  " *** What will be your capture interval? (seconds): " CAPTURE_INTERVAL
        echo "   > Capture interval will be $CAPTURE_INTERVAL seconds."

        if ! [[ $CAPTURE_INTERVAL =~ ^[0-9]+$ ]]
        then    
            echo " *** Invalid parameter. Re-run script and try again."
            exit 0
        fi

        PARAM1_UP=$(echo "scale=1; ${CAPTURE_PERIOD}*3600" | bc -l)
        PARAM1_DWN=${CAPTURE_INTERVAL}
        PARAM1=$(echo "scale=0; $PARAM1_UP/$PARAM1_DWN" | bc -l)

        echo " *** For a $CAPTURE_PERIOD hours capture in $CAPTURE_INTERVAL seconds interval, this is your command: './betaMacOSPerformanceTool.sh -pl $PARAM1 $PARAM1_DWN'"
        echo " *** Use 'nohup ./betaMacOSPerformanceTool.sh -pl $PARAM1 $PARAM1_DWN &' to be able to disconnect your remote session and keep capture going"
    }

    echo " *** Pick 1, 2 or 3, according to time format to use:"
    select option in hour-minute minute-second hour-second
    do 

        if [ $option = hour-minute ]
        then
            hour_minute
        fi
        

        if [ $option = minute-second ]
        then
            minute_second
        fi
        
        if [ $option = hour-second ]
        then
            hour_second
        fi
        exit
    done
}

header_macos () {
echo " ---------------- $(date) -----------------"
echo " ---------- Running betaMacOSPerformanceTool (v$SCRIPT_VERSION) ----------"
}

#############################################################
#                   END Define Functions				    #
#############################################################

case $1 in

		-ps)
			disclaimer
			header_macos
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
			get_rtp_stats
			tidy_up
			clean_house
			package_and_compress
			append_log_file
		;;
		
		-pl)
			disclaimer
			get_pid_init
			header_macos
			check_time_param_long
			check_mdatp_running
			check_requirements
			create_dir_struct
			collect_info
			echo_loop_long
			loop_long > $DIRNAME/$MAIN_LOGFILENAME | count_long
			feed_data
			feed_stats > /dev/null 2>&1
			rename_pid_to_process
			create_plotting_files
			create_plot_graph_long
			generate_report
			get_rtp_stats
			tidy_up
			clean_house
			package_and_compress
			append_log_file
			get_pid_stop
			append_pid_files
		;;
		
		-m)
			calc
		;;

		-d) 
			disclaimer
		;;
		
		-h) 
			echo "     ======================================= beta Xplat Performance Tool ==========================================="
			echo "     Usage:./betaMacOSPerformanceTool.sh -ps <time to capture in seconds>, performance short-mode."
		    echo "	   ./betaMacOSPerformanceTool.sh -pl <nr. of samples> <sampling interval in seconds>, performance long-mode." 
			echo "                   Can  be used with 'nohup' and sent to background [&] in long run captures, when remote "
			echo "                   sessions need to be disconnected."
			echo "           ./betaMacOSPerformanceTool.sh -m, calculator for time parameters for '-pl' option."
			echo ""
			echo "     Note on '-pl' parameters:"
			echo "              - sampling interval: ( 0 < [int|float])"
			echo "	      - nr. of samples: ( 0 < [int])"
			echo "     ==============================================================================================================="
		;;
		
		*) 
			echo " *** Invalid parameter. Please check script usage with '-h' option." 
		;;
esac

#
# EOF
#
) 2>&1 | tee -a betaMacOSPerformanceTool.log


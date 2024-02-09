# beta Xplat Performance Tool
- Last version is v4.2.0

# Context:
The 'beta Xplat Performance Tool' is intended for Linux performance data collection, CPU and Memory load investigation and analysis, when high CPU or Memory load is reported. It aims at quickly being able to determine a device’s CPU and Memory load and ellaborate on mitigation, as well as propose fixes. It's very intuitive and easy to use, returns results that are easy to interpret and relies on very basic set of tools existent in virtually all Linux minimal installations.

# What it does:
'beta Xplat Performance Tool' captures CPU and Memory data for a period of time and is at the moment, independent of “Client Analyzer” for Linux: it does not depend on python or "Client Analyzer" code to be executed. It’s a command-line tool, shellscript, that receives an interval of time as parameter, and captures CPU and Memory activity for that specified period. The processes being monitored are wdavdaemon (edr, rtp and av components) and audisp plugin. Can also be used in a 'long run' mode in the background, to spot memory leaks or track resource behavior for a long time.

# Main advantages
- Easy to use and to interpret data
- Light-wheight
- Fast to execute
- Does not depend on python
- Basic Shell Script using 'awk', 'sed', 'grep', 'tee' base install available Linux tools
- Easily adaptable and scalable code
- Simply execute the script and collect resulting package for investigation

# Examples of performance graphs for RAM and CPU

![194161484-c04fece5-ac7a-440f-b1f4-b221bdd6a344](https://user-images.githubusercontent.com/113130572/198121620-8c1ed95d-b36e-4686-9dd8-5a5c8f127fd5.png)
![194161566-7e2be150-c480-485f-9eef-eee6941277b9](https://user-images.githubusercontent.com/113130572/198121631-efa6f791-ebe0-4cf1-8bc1-10e69d6639ea.png)
![194161596-32769f74-9035-4a47-9f71-4d5c160de1a5](https://user-images.githubusercontent.com/113130572/198121645-ca0e0ccf-96ef-4055-874f-64351839cb2c.png)
![194161620-09b648ce-4eb1-4e3b-bb7c-6586fdc95263](https://user-images.githubusercontent.com/113130572/198121656-92c6ae3c-4667-429c-81e5-6834f63d4e89.png)

# Usage:
### Download the script to MacOS or Linux:
MacOS: 
- curl https://raw.githubusercontent.com/microsoft/linux-tracer/download/betaMacOSPerformanceTool_v4.2.0.sh -o betaMacOSPerformanceTool_v4.2.0.sh && chmod a+x betaMacOSPerformanceTool_v4.2.0.sh

Linux:
- wget -O betaLinuxPerformanceTool_v4.2.0.sh https://raw.githubusercontent.com/microsoft/linux-tracer/download/betaLinuxPerformanceTool_v4.2.0.sh && chmod a+x betaLinuxPerformanceTool_v4.2.0.sh
  
### Read 'help' dialog for instructions:
MacOS:
- ./betaMacOSPerformanceTool_v4.2.0.sh -h
    
Linux:
- ./betaLinuxPerformanceTool_v4.2.0.sh -h
  
### Run script as needed. Below example runs for 1 minute (60 seconds):
- ./beta-<--OS-->-PerformanceTool_v4.2.0.sh -ps 60
### If you need to collect data for 5 minutes (300 seconds):
- ./beta-<--OS-->-PerformanceTool_v4.2.0.sh -ps 300
### Confirm investigation package is created:
- You should find a package named beta-<--OS-->-PerformanceTool_v4.2.0.sh-<--date-->.zip

# Future work:
- I'm planning on merging the two diagnostic tools in one single file that will called betaXplatPerformanceTool_-<-version>.sh

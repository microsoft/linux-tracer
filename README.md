## beta Xplat Performance Tool
Last version is v4.0

## Context:
The 'beta Xplat Performance Tool' is intended for Linux performance data collection, CPU and Memory load investigation and analysis, when high CPU or Memory load is reported. 
It aims at quickly being able to determine a device’s CPU and Memory load and ellaborate on mitigation, as well as propose fixes.
It's very intuitive and easy to use, returns results that are easy to interpret and relies on very basic set of tools existent in virtually all Linux minimal installations.
## What it does:
'beta Xplat Performance Tool' captures CPU and Memory data for a period of time and is at the moment, independent of “Client Analyzer” for Linux: it does not depend on python or "Client Analyzer" code to be executed. 
It’s a command-line tool, shellscript, that receives an interval of time as parameter, and captures CPU and Memory activity for that specified period. The processes being monitored are wdavdaemon (edr, rtp and av components) and audisp plugin. Can also be used in a 'long run' mode in the background, to spot memory leaks or track resource behavior for a long time.

## Main advantages 
- Easy to use and to interpret data
- Light-wheight
- Fast to execute
- Does not depend on python
- Basic Shell Script using 'awk', 'sed', 'grep', 'tee' base install available Linux tools
- Easily adaptable and scalable code
- Simply execute the script and collect resulting package for investigation 

## Examples of performance graphs for RAM and CPU:
![image](https://user-images.githubusercontent.com/113130572/194161484-c04fece5-ac7a-440f-b1f4-b221bdd6a344.png)

![image](https://user-images.githubusercontent.com/113130572/194161566-7e2be150-c480-485f-9eef-eee6941277b9.png)

![image](https://user-images.githubusercontent.com/113130572/194161596-32769f74-9035-4a47-9f71-4d5c160de1a5.png)

![image](https://user-images.githubusercontent.com/113130572/194161620-09b648ce-4eb1-4e3b-bb7c-6586fdc95263.png)

## Usage:
### From the Linux server to collect logs from, do as follows:
- Get script:
  - wget https://aka.ms/betaxplatperformancetool -O betaXplatPerformanceTool.sh
  - wget https://github.com/microsoft/linux-tracer/archive/refs/heads/download.zip
- Unzip download.zip
  - unzip download.zip
- Change directory into sccript path
  - cd linux-tracer-download
- Adjust permissions:
  - chmod +x betaXplatPerformanceTool.sh
- Read 'help' dialog:
  - ./betaXplatPerformanceTool.sh -h
- Accept disclaimer by hitting 'y'
- Run 'beta Xplat Performance Tool' based on your needs (below example runs for 5 minutes, 300 seconds):
  - ./betaXplatPerformanceTool.sh -ps 300
- Confirm investigation package is created and share it with us:
  - You should find a package named betaXplatPerformanceTool-<--date-->.zip

## Tested and known to have produced the expected results in the following systems:
- RHEL 8.2 (Ootpa) 
- Ubuntu 20.04.4 LTS (Focal Fossa)
- CentOS 7.9
- Debian 11.5
- Oracle Enterprise Linux 7.9
- Oracle Enterprise Linux 8.6
- RHEL 7.8
- RHEL 8

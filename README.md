# beta Xplat Performance Tool
Last version is v4.1

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
### From the Linux server, get script:
 - wget https://aka.ms/betaxplatperformancetool -O betaXplatPerformanceTool.sh && chmod +x betaXplatPerformanceTool.sh
### Read 'help' dialog for instructions:
- ./betaXplatPerformanceTool.sh -h
### Run script as needed. Below example runs for 5 minutes, 300 seconds:
- ./betaXplatPerformanceTool.sh -ps 300
### Confirm investigation package is created:
- You should find a package named betaXplatPerformanceTool-<--date-->.zip

# Known to work in the following systems:
- RHEL 8.2 (Ootpa)
- Ubuntu 20.04.4 LTS (Focal Fossa)
- CentOS 7.9
- Debian 11.5
- Oracle Enterprise Linux 7.9
- Oracle Enterprise Linux 8.6
- RHEL 7.8
- RHEL 8

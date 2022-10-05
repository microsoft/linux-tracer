# LCMT
Linux CPU & Memory Tracer

# LCMT last available version
Last version is v3.8

## Context:
LCMT is intended for Linux performance data collection, CPU and Memory load investigation and analysis, when high CPU or Memory load is reported. 
It aims at quickly being able to determine a device’s CPU and Memory load and ellaborate on mitigation, as well as propose fixes.
It's very intuitive and easy to use, returns results that are easy to interpret and relies on very basic set of tools existent in virtually all Linux minimal installations.
## What it does:
LCMT captures CPU and Memory data for a period of time and is at the moment, independent of “Client Analyzer” for Linux: it does not depend on python or "Client Analyzer" code to be executed. 
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

## Help dialog for LCMT v3.8:
![image](https://user-images.githubusercontent.com/113130572/194181096-f3ac1fba-f8e7-472c-948f-b91e997df396.png)

## Executing LCMT:
![image](https://user-images.githubusercontent.com/113130572/194163405-f1d9c038-dce2-4da3-aa41-126849ace0bb.png)

## Investigation package content:
![image](https://user-images.githubusercontent.com/113130572/194172441-2f072ffb-9360-40b4-8291-bc1a43a259cf.png)
![image](https://user-images.githubusercontent.com/113130572/194172355-9d9f2ac5-ad07-4a38-9534-9561164a151c.png)

## Usage:
### From the Linux server to collect logs from, do as follows:
- Get script package:
  - wget https://github.com/microsoft/linux-tracer/archive/refs/heads/download.zip
- Unzip package:
  - unzip download.zip
- Go into script directory:
  - cd linux-tracer-download
- Set execution permissions:
  - chmod +x linux_cpu_tracer.sh
- Read disclaimer:
  - ./linux_cpu_tracer.sh -d
- Read help dialog:
  - ./linux_cpu_tracer.sh -h
- Run LCMT based on your needs (below example runs for 5 minutes, 300 seconds):
  - ./linux_cpu_tracer.sh -ps 300

### Console example of above steps:
![image](https://user-images.githubusercontent.com/113130572/194175150-fa8c89f8-cf3f-4148-814c-157e0226a2af.png)
After having the investigation package available as per above, transfer it to your local device and investigate data.

## Tested and known to have produced the expected results in the following systems:
- RHEL 8.2 (Ootpa) 
- Ubuntu 20.04.4 LTS (Focal Fossa)
- CentOS 7.9
- Debian 11.5
- Oracle Enterprise Linux 7.9
- Oracle Enterprise Linux 8.6
- RHEL 7.8
- RHEL 8

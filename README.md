# LCMT
Linux CPU & Memory Tracer

## Context:
This tool is intended for Linux performance data collection, CPU and memory load investigation and analysis or when high CPU or memory load is reported. 
It aims to quickly being able to determine a device’s CPU and memory load and ellaborate on mitigation, as well as propose fixes.
It's very intuitive and easy to use, returns results that are easy to interpret and relies on very basic tools existent in all Linux base installations.
## What it does:
The script linux_cpu_tracer.sh, captures CPU and memory data for a period of time and is at the moment, independent of “Client Analyzer” for Linux: it does not depend on python or "Client Analyzer" code to be executed. 
It’s a command-line tool, shellscript, that receives an interval of time, and captures CPU and memory activity for that specified period. The processes being monitored are wdavdaemon (edr, rtp and av components) and audisp plugin. Can also be used in a long run mode in the background, to spot memory leaks or track resource behavior for a long time.

## Examples of performance graphs for RAM and CPU:
![image](https://user-images.githubusercontent.com/113130572/194161484-c04fece5-ac7a-440f-b1f4-b221bdd6a344.png)

![image](https://user-images.githubusercontent.com/113130572/194161566-7e2be150-c480-485f-9eef-eee6941277b9.png)

![image](https://user-images.githubusercontent.com/113130572/194161596-32769f74-9035-4a47-9f71-4d5c160de1a5.png)

![image](https://user-images.githubusercontent.com/113130572/194161620-09b648ce-4eb1-4e3b-bb7c-6586fdc95263.png)

## Help dialog for v3.8 of the script:
![image](https://user-images.githubusercontent.com/113130572/194162759-8c2fc984-f49c-44bb-ae65-92cdf2fa21f0.png)

## Tracer in action:
![image](https://user-images.githubusercontent.com/113130572/194163405-f1d9c038-dce2-4da3-aa41-126849ace0bb.png)

## Usage:
### From the Linux server:
- Get script package:
  - wget https://github.com/microsoft/linux-tracer/archive/refs/heads/download.zip
- Unzip package:
  - unzip download.zip
- Go into script directory:
  - cd linux-tracer-download
- Adjust executions permissions
  - chmod +x linux_cpu_tracer.sh
- Read disclaimer:
  - ./linux_cpu_tracer.sh -d
- Read help dialog:
  - ./linux_cpu_tracer.sh -h
- Run LCMT based on your needs
  - ./linux_cpu_tracer.sh -ps 300

## Tested and known to have produced the expected results in the following systems:
- RHEL 8.2 (Ootpa) 
- Ubuntu 20.04.4 LTS (Focal Fossa)
- CentOS 7.9
- Debian 11.5
- Oracle Enterprise Linux 7.9
- Oracle Enterprise Linux 8.6
- RHEL 7.8
- RHEL 8

Let me know if you have more systems to add to the above list (or if you come accross a system that doesn't behave as expected). :)

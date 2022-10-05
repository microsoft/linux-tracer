# linux-tracer
Linux CPU tracer for MDATP processes

## Context:
This tool is intended for Linux performance data collection, CPU and memory load investigation and analysis or when high CPU or memory load is reported. 
It aims to quickly being able to determine a device’s CPU and memory load and ellaborate on mitigation, as well as propose fixes.
It's very intuitive and easy to use, returns results that are easy to interpret and relies on very basic tools existent in all Linux base installations.
## What it does:
The script linux_cpu_tracer.sh, captures CPU and memory data for a period of time and is at the moment, independent of “Client Analyzer” for Linux. 
It’s a command-line tool, shellscript, that receives an interval of time, in seconds, as its only parameter, and captures CPU and memory activity for that specified period every second. The processes being monitored are wdavdaemon and MDATP auditd plugin. Can also be used in a long run mode in the background, to spot memory leaks.
The script gathers data, by looping through the top command periodically, and filtering out relevant data regarding MDATP processes. Gathered data is then processed and organized so as to present human-readable log files and graphs.

## Examples of performance graphs for RAM and CPU:
![image](https://user-images.githubusercontent.com/113130572/194161484-c04fece5-ac7a-440f-b1f4-b221bdd6a344.png)

![image](https://user-images.githubusercontent.com/113130572/194161566-7e2be150-c480-485f-9eef-eee6941277b9.png)

![image](https://user-images.githubusercontent.com/113130572/194161596-32769f74-9035-4a47-9f71-4d5c160de1a5.png)

![image](https://user-images.githubusercontent.com/113130572/194161620-09b648ce-4eb1-4e3b-bb7c-6586fdc95263.png)

## Help dialog for v3.8 of the script:
![image](https://user-images.githubusercontent.com/113130572/194162759-8c2fc984-f49c-44bb-ae65-92cdf2fa21f0.png)

## Tracer in action:
![image](https://user-images.githubusercontent.com/113130572/194163405-f1d9c038-dce2-4da3-aa41-126849ace0bb.png)





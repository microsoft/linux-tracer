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

#  Solid-Dispensing Station

This repo is the implementation of paper "Autonomous Biomimetic Solid Dispensing Using a Dual Arm Robotic Manipulator" as well as the follow-ups. The following diagram shows Communication between devices and the control flow of the dispensing station :
![image](https://github.com/fourteenjiang/Solid-dispensing/blob/774c3ac7bde8079ef39fa76b310030d253df1c91/readme.png)

It currently the following contents including station CAD models, dispensing results and code, please see the content tree. 

- Station CAD models
- Dispensing results
- Code
  - FLCBalance_client.py
  - File_client.py
  - Robot YuMi code
    - Backinfo
    - CS
    - Home
    - RAPID
    - SYSPAR




## Station CAD models

Please see  [./Custom Designed Model./README.md](https://github.com/fourteenjiang/Solid-dispensing/tree/main/Custom%20Designed%20Model#readme).

## Dispensing results

Dispensing result includes of three different dispensing methods and the percentage dispensing error for thirteen solids with different target dispensing weights. The naming rules for the files within the folder are: solid_platform.json, each file consists of four different allocation weights 20, 200, 500 and 1000mg. 

The content of the exported files varies slightly from different platforms, but all probably include the following key elements:

 - Time: The time taken to complete a solid dispensing cycle
 - Target weight: unit mg
 - Accuracy: should be error here = difference / target value

## Code 

Three categories of program files are included, the first two are mainly python files and are primarily responsible for the transfer of data between the different devices (robot, control PC, and scales) while the third contains all robot-related programs, written by the author using Robotstudio 2019.

  - FLCBalance_client.py：Responsible for the transfer of the FLC output parameters from the control PC to the robot and the real-time transmission of the balance readings to the robot YuMi via the control PC.

  - File_client.py： The result of each material dispensing is stored on the control PC.

  - Robot YuMi code： Please see [./Code/Robot YuMi code/README.md](https://github.com/fourteenjiang/Solid-dispensing/blob/a98ddb8d75d227b740be9f4c79dc72d7ddf37493/Robot_RAPID_code/README.md)


 ## Robot YuMi code
 For robot YuMi-related programs, the folder contains mainly the following contents:

  - Robot YuMi code
    - Backinfo: all the background information.
      -  pls see [backinfo.txt](https://github.com/fourteenjiang/Solid-dispensing/blob/b1df850d1c950538c4c322425e7276ad39ae3769/Robot_RAPID_code/BACKINFO/backinfo.txt)
      - license, see [license](https://github.com/fourteenjiang/Solid-dispensing/tree/main/Robot_RAPID_code/BACKINFO/license)
      - controller, see [controller.rsf](https://github.com/fourteenjiang/Solid-dispensing/blob/main/Robot_RAPID_code/BACKINFO/controller.rsf)
      -  xml version, encoding type, see [version.xml](https://github.com/fourteenjiang/Solid-dispensing/blob/main/Robot_RAPID_code/BACKINFO/version.xml)
      - some id info
    - CS: controller setting info
      - controller settings, see 
[ctrlsettings.xml](https://github.com/fourteenjiang/Solid-dispensing/blob/main/Robot_RAPID_code/CS/ctrlsettings.xml)
      - user authorization groups template, see [uas_groups_template.xml](https://github.com/fourteenjiang/Solid-dispensing/blob/main/Robot_RAPID_code/CS/uas_groups_template.xml) 
    
    - Home: all public files and directories
    - RAPID: robot task and system program
       - task1 : robot right arm system  modules ([SYSMOD](https://github.com/fourteenjiang/Solid-dispensing/tree/main/Robot_RAPID_code/RAPID/TASK1/SYSMOD)
), program modules ([PROGMOD](https://github.com/fourteenjiang/Solid-dispensing/tree/main/Robot_RAPID_code/RAPID/TASK1/PROGMOD)).
       - task2 : robot left arm system modules([SYSMOD](https://github.com/fourteenjiang/Solid-dispensing/tree/main/Robot_RAPID_code/RAPID/TASK2/SYSMOD)) and program modules([PROGMOD](https://github.com/fourteenjiang/Solid-dispensing/tree/main/Robot_RAPID_code/RAPID/TASK2/PROGMOD)).
       - task3: socket system modules([SYSMOD](https://github.com/fourteenjiang/Solid-dispensing/tree/main/Robot_RAPID_code/RAPID/TASK3/SYSMOD)) and program modules([PROGMOD](https://github.com/fourteenjiang/Solid-dispensing/tree/main/Robot_RAPID_code/RAPID/TASK3/PROGMOD)).
      
    - SYSPAR： system configuration files including system parameters, processor, multimedia card, external Input/Output, serial Input/Output and main operation control configuration files, pls see ([SYSPAR](https://github.com/fourteenjiang/Solid-dispensing/tree/main/Robot_RAPID_code/SYSPAR)).
  

  - Robot YuMi code： Please see [./Code/Robot YuMi code/README.md](https://github.com/fourteenjiang/Solid-dispensing/blob/a98ddb8d75d227b740be9f4c79dc72d7ddf37493/Robot_RAPID_code/README.md)

#  Solid-Dispensing Station

This repo is the implementation of paper "Autonomous Biomimetic Solid Dispensing Using a Dual Arm Robotic Manipulator" as well as the follow-ups. The following diagram shows the control flow of the dispensing station :
![readme1.png](https://github.com/fourteenjiang/Solid-dispensing/blob/main/readme1.png)

This figure explains the communication between different devices:
![readme2.png](https://github.com/fourteenjiang/Solid-dispensing/blob/main/readme2.png)


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


Please see  [./Custom Designed Model./README.md](https://github.com/fourteenjiang/Solid-dispensing/blob/main/Station%20CAD%20models/README.md).

## Dispensing results

Dispensing result includes of three different dispensing methods and the percentage dispensing error for thirteen solids with different target dispensing weights. The naming rules for the files within the folder are: solid_platform.json, each file consists of four different allocation weights 20, 200, 500 and 1000mg. 

The content of the exported files varies slightly from different platforms, but all probably include the following key elements:

 - Time: The time taken to complete a solid dispensing cycle
 - Target weight: unit mg
 - Accuracy: should be error here = difference / target value

## Code 

Three categories of program files are included, the first two are mainly python files and are primarily responsible for the transfer of data between the different devices (robot, control PC, and scales) while the third contains all robot-related programs, written by the author using Robotstudio 2019.

  - FLCBalance_client.py：Responsible for the transfer of the FLC output parameters from the control PC to the robot and the real-time transmission of the balance readings to the robot YuMi via the control PC.

  - File_client.py： Responsible for transferring the result of each material dispensing to PC and send the target weight from PC to robot YuMi.

  - Robot YuMi code： Please see [./Code/Robot YuMi code/README.md](https://github.com/fourteenjiang/Solid-dispensing/blob/172dcfe219b5fe842aeb9c061d4efa964f9e0266/Code/Robot%20YuMi%20code/README.md)




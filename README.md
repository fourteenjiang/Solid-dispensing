#  Solid-Dispensing Station

This repo contains the codebase for the paper "Autonomous Biomimetic Solid Dispensing Using a Dual Arm Robotic Manipulator" as well as the acquired experimental results and the developed CAD assets.

This repo is structured as follows: 
- [Code](#code)
- [Experimental results](#experimental-results)
- [Station CAD models](#station-cad-models)


## Code

The diagram below shows the controller design for the solid dispensing process, which is reflected in the code structure:
![readme](https://github.com/fourteenjiang/Solid-dispensing/assets/86227785/a0136920-74c6-4a9f-b274-d4e3f88ffbd6)

Futhermore, the figure below illustrates the system setup in terms of communication and data flow:
![readme2](https://github.com/fourteenjiang/Solid-dispensing/assets/86227785/5629f46d-e11d-4449-8f17-f99b07ddb4a7)


To clarify, two programs are primarily responsible for the transfer of data between the different devices (robot, control PC, and balance) while the third program contains all robot-related code for task execution. Inside the code folder you will find:

  - FLCBalance_client.py：This contains the Fuzzy Logic Controller (FLC) implementation and the driver responsible for communicating with the Balance. In other words, it sends the FLC output from the control PC to the robot. At the same time, it allows real-time transmission of the balance readings acquired by the driver back to the control PC.

  - File_client.py： Responsible for setting the target weight for the solid dispensing operation and to store the results of the dispensing process to json files.

  - Robot YuMi code： Contains all the code for robot task execution. For more info, please see [here](https://github.com/fourteenjiang/Solid-dispensing/blob/172dcfe219b5fe842aeb9c061d4efa964f9e0266/Code/Robot%20YuMi%20code/README.md) for more info.

## Experimental results

This includes results of the solid dispensing processes of the three platforms discussed in the paper. These include Chemspeed, Quantos and our developed method. Each platform was tested with 13 solids and 4 different target weights (20, 200, 500 and 1000mg). Consequently, for each platform there are exists 13 files that has all the acquired results. This is reflected in the filenames, where each is structured as follows: [solid_name]_[platform_name].json. Finally, all the files include the following json keys:

 - Time: The time taken to complete a solid dispensing cycle
 - Target weight: unit mg
 - Accuracy: should be error here = difference / target value

## Station CAD models
For more info, please see [here](https://github.com/fourteenjiang/Solid-dispensing/blob/main/Station%20CAD%20models/README.md).


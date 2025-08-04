# Design and implementation of a space-efficient robotic workcell for industrial applications

This repository contains all the CAD designs, STL models, and Structured Text (ST) code developed for my master's thesis at Hochschule Schmalkalden, as well as a demonstration video of the robotic workcell in action. The project involves building a compact robotic workcell for automated pick-and-place operations using a Pilz PRBT6 robot, a Schunk electric gripper, and a conveyor system, all coordinated through a Berghof B-Nimis industrial controller.

---

## 📁 Repository structure

```
├── 2D_Drawings/           # Technical manufacturing drawings of fixtures and parts
├── 3D CAD Models/         # 3D assemblies and part models designed in SolidWorks
├── STL files/             # Printable STL files for 3D-printed custom components
├── coding/                # CoDeSys PLC code (Structured Text) for robot, gripper, and conveyor
├── IMG_5395.MOV           # Video: Full pick-and-place cycle with Pilz PRBT6 robot (Git LFS)
├── LICENSE                # MIT License for academic use
└── README.md              # This project overview file
```

---

## 🛠️ Project description

This thesis demonstrates how a space-constrained robotic workcell can be engineered with mechanical precision and software modularity. It focuses on:

- Implementing a pick-and-place sequence using a Pilz PRBT6 robotic arm
- Gripping objects of varying widths using a Schunk EGP 40 electric gripper with custom-designed fingers
- Detecting workpieces using a proximity sensor mounted with a custom 3D-printed holder
- Coordinating conveyor and gripper logic via Structured Text programming in CoDeSys on a Berghof B-Nimis controller
- Using a state-machine-driven control architecture for safety, accuracy, and modularity

All parts were modeled in SolidWorks and some were 3D printed for actual deployment and testing.

---

## 💻 Code overview

The `coding/` folder contains selected parts of the CoDeSys program used to control the robot, gripper, and conveyor system. These files are written in Structured Text (ST) and structured using modular, state-machine-driven logic.

Included files:
- `Example_Pick_EGP.st`: Main program structured around a state machine
- `FB_MoveToTargetPosition.st`: Function block for coordinated robot movement
- `ST_WorkpiecePlacement.typ`: Custom data type for managing positional memory

> ⚠️ **Important:**  
> To make this code functional, you must configure the correct hardware setup in CoDeSys, including:
> - Adding all required `Axis Function Blocks` for each robot axis
> - Setting up the correct device tree with controller, EtherCAT devices, and I/O modules
> - Mapping variables to actual hardware or simulation targets  
>
> The full project file is **not shared** publicly due to confidentiality, as it contains sensitive configuration and controller-specific details. Only key logic files are included for educational reference.

---
🎥 Demonstration Video
A video of the full pick-and-place operation cycle using the Pilz PRBT6 robot is included in this repository as IMG_5395.MOV (downloadable with Git LFS).

You can also view and download the video directly from Google Drive here:
[Pick-and-place full cycle video](https://drive.google.com/file/d/1d2Tzha2PRA3JoMwxCZ5N9d68g4B4LuIS/view?usp=drive_link)

## 🔷 CAD and STL files

- `3D CAD Models/`: Contains SolidWorks models for:
  - Gripper fingers
  - Conveyor aligners
  - Sensor holder
  - Vertical stacking structure
  - Alignment station

- `STL files/`: Exported models for 3D printing of the above components

- `2D_Drawings/`: Technical drawings with exact dimensions for manufacturing and documentation

---

## 🖌️ Licensing

This repository is released under the **MIT License**. All files are free to use for academic, research, or personal learning purposes. Commercial use is not permitted without explicit permission.

---

## 👨‍🎓 Author

**Narasimha Sai Jaswanth Pendala**  
M.Sc. Mechatronics and Robotics  
Hochschule Schmalkalden, Germany

---

## 📧 Contact

For academic inquiries, feedback, or collaboration, feel free to reach out via [LinkedIn](https://www.linkedin.com/in/narasimha-sai-jaswanth-pendala/) or contact through university channels.

---

Thank you for visiting this repository. If you found the content useful or inspiring, feel free to star the repo or share it with others in the automation and robotics community!

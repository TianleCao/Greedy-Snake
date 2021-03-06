# Greedy-Snake
An implementaion of Greedy Snake on FPGA
## Introduction
### Authors
The demo was implemented by Dingkun Liu and Tianle Cao.
### Purpose
For this project, we aim to implement the game Greedy Snake via FPGA. An OLED screen would be used for showing the snake and food, while the Triaxial accelerometer would indicate our gestures and provide the information for snake controllment. Certain buttons on the FPGA could be used to stop/start the game and speed up (for more game difficulties).
### Hardwares
You will need DE2-70FPGA, Pmod OLED and Pmod ACL2 (SPI would apply for both) for this game. The pins are specified in *greedy snake pin.xlsx*
### Design Concept
The flow chart of this project is shown below:
![Alt text](/imgs/Greedy_Snake.png)
The FPGA board would take turns to retrieve motion information of x and y axis, which would be used for updating the screen.

## Code Structure
The whole project is built on *quartus*. Therefore both HDL files and bdf files (top level circuit connection) are provided.    

name | Description
:---- | :--------
*judge_y.vhd* | Direction judgement in y-axis
*judge_x.vhd* | Direction judgement in x-axis
*EDA_Mission.v*          | Top level file
*direction_output.bdf*   | Top level file of direction module
*sweep.vhd*              | Generate signal axis and CS'for communication
*freq_divi.vhd*          | Generate the SCLK for communication of ACL2
*direction.vhd*          | Judge the current direction using data from judge_x & judge_y
*data_acquire.vhd*       | Obtain data using SPI
*communication.vhd*      | Output command and address to ACL2 using SPI
*My_OLED_EX.v*           | Oled display and snake calculation
*Delay.v*                | Screen updating delay control module
*SpiCtrl.v*              | Spi control module
*PmodOLEDCtrl.v*         | Top level file of Oled display module
*OledInit.v Oled*        | Initialize module
*CountDisplay.v*         | Controller of Seven Sections of Difital Tubes used to display score
*RanGen.v*               | Random number generator (for generating food on the screen)
## Simulations
Simulation is performed for SPI protocal with *communication.vwf*. A demo result is shown below, in which case the master tries to read the data from a register in the slave device with command 00001011 and 8-bit address 00001010
![Alt text](/imgs/simulation.jpg)
## Results
A photo with explanation for buttons could be seen below:
![Alt text](/imgs/demo.jpg)

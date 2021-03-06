# SECTION 1, 2

* **</u>fis_model_improved.m</u>**
Contains the FIS: Variables, MFs, RB of the improved FIR model
which saves to fis_model_improved.fis

* **</u>fis_model_improved.fis</u>**
The improved FIS model

* **</u>fis_model_initial.m</u>**
Contains the FIS: Variables, MFs, RB of the initial FIR model
which saves to fis_model_initialfis

* **</u>fis_model_initial.fis</u>**
The initial FIS model

* **</u>get_distances.m</u>**
Given the coordinates x, y, this function calculates the distances dH, dV

* **</u>simulate.m</u>**
Given an initial and a desired position, the velocity and an array of
starting angles, this function simulates the route of the car and plots
the result

* **</u>main.m</u>**
Makes call to the above function. First it creates and saves the FIR model, 
then it load the FIR model and simulates the car route.

# Note
Scripts tested in MATLAB 2019a

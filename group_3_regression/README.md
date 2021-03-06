# Functions

* **<u>split_scale.m</u>**
Preprocess of data function

* **<u>plotMFs.m</u>**
Plot the MFs of a FIS

# Section 1

* **<u>TSK_model_1.m</u>**
A TSK model with specific requirements for airfoil self noise dataset

* **<u>TSK_model_2.m</u>**
A TSK model with specific requirements for airfoil self noise dataset

* **<u>TSK_model_3.m</u>**
A TSK model with specific requirements for airfoil self noise dataset

* **<u>TSK_model_4.m</u>**
A TSK model with specific requirements for airfoil self noise dataset

* **<u>airfoil_self_noise.csv</u>**
The dataset

# Section 2

* **<u>grid_search.m</u>**
Grid Search: SC for clustering, Relieff for feature selection, 5-Fold CV
Find number of features, their indexes and cluster's radius
Note than in order to make the scirpt faster, we run 4 instances of MATLAB, each with a different feature - see folder grid_search_bf

* **<u>opt_model.mat</u>**
The optimal model from grid_search_2.m

* **<u>opt_model.m</u>**
TSK with the opt_model_2.mat

* **<u>metrics_opt.mat</u>**
Metrics of the optimal model saved as matlab variables

* **<u>superconductivity.csv</u>**
The dataset

# REPORT

* **<u>report.pdf</u>**
The report of the assignment

* **<u>report (folder)</u>**
Folder where the plots are saved. Also contains the initial lyx file

# Note
Before running the script make sure the following path exists:

* ~/report/plots_1
* ~/report/plots_2
* ~/report/plots_3
* ~/report/plots_4
* ~/report/plots_grid_search
* ~/report/plots_opt

Scripts tested in MATLAB 2020a


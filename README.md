# CompareModels
Compare octane rating/fuel blends/functional groups as dimensions for ignition delay model training

Example code used for my research. In this repo, I take an IDT dataset that has octane rating as input features and convert the RON/MON values to the fuel blend ratios and then convert the fuel blend ratios to ratios of methyl, methylene, and benzyl-type functional groups as the physical properties for the fuel blends. I take the resulting datasets and train random forest and neural network models and compare results through stats and graphing.

I am still playing around and may or may not update this repo more.

To those who use this to reproduce my results:

0) Go into CreateSets.R and Analysis.R and set the proper working directory

0.5) Download required packages if you don't have them
1) Run CreateSets.R, it will take the ON set in Datasets and create a fuel blends set and a functional group set
2) Run Analysis.R, models will be trained and results will be graphed and appropriate files will be created


If you have any questions or concerns or tips feel free to contact me.

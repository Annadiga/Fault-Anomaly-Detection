# Fault and anomaly detection of a fixed-wing aircraft

Main goal of this project was creating a diagnostic classificator to detecte anomalies during flight tests.
 Dataset used is the ALFA dataset, containing flight data of a fixed-wing UAV. 
 
 ## Steps
 ### Preprocessing 

 - Dataset structure analysis
 - Fault-free flight and faulty flight split
 - Removal od first second of each flight
 - Variables selection
 - Data synchronization at 25 Hz


### Diagnostic features extraction
- Tests division in frames
- Creation of power spectrum and frequency domain features extraction
- Time domain features extraction
- Features ranking with One-way ANOVA and Kruskal-Wallis
- Features selection


### Classification
- Dataset split into training (90%) and test set (10%) with stratification
- Application of SMOTE technique to training set
- Models evaluation with 5-fold Cross Validation
- Test of trained models

### Results
 
 Best classifier seems to be the Ensemble, here the results on test set:

| Class | Precision | Recall | F1-score
|--|--|--|--|
|  	0	|   0.97	|	0.92 | 0.95
|  	1	|  	0.75	|	0.92 | 0.83
|  	2	|  0.50		|	0.25 | 0.33
|  	3	|  	0.25	|	0.50 | 0.33
|  	4	|  	1.0		|	1.0	  | 1.0
|  	5	|  	0.0		|	0.0	  | 0.0
|  	6	|  	1.0		|	1.0	  |1.0
|  	7	|  	1.0		|	1.0	  |1.0
|  	8	|  	1.0		|	1.0	  |1.0





## Future develops
A possible future development of the project could involve collecting flight tests corresponding to the minority fault classes, to obtain a more balanced starting dataset.
  
 
# Tools

For ALFA Dataset manipulation "alfa-tools" is needed. Download it at this [repository](https://github.com/castacks/alfa-dataset-tools) inside folder "alfa-matlab".

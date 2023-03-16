pyenv('Version','C:\Users\Anna\AppData\Local\Programs\Python\Python310\python.exe')
%z = load("carbonZ_2018-07-18-12-10-11_no_ground_truth.mat");
pe = pyenv;
pe.Version
%load carbonZ_2018-07-18-12-10-11_no_ground_truth.mat;

%variabile = Sequence.Topics; % salvo Topics in una variabile perchè sono
%le variabili possono essere salvate.

%load Struct_Saved_as_variable.mat;

%infoyaw = variabile.mavros_nav_info_yaw;
%load carbonZ_2018-07-18-15-53-31_1_engine_failure.mat

%variabile2 = Sequence.Topics
%topics2variabile = load("Topics2.mat")
wind = variabile2.mavros_wind_estimation
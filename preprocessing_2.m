%% ----------------------------------------------------- 
close all;
clear all;
clc;

%% CREAZIONE TABELLA FINALE CON ATTRIBUTI DI INTERESSE
dataTable = table();

fs_new = 25; % New sampling rate


% METTEREMO CICLO ESTERNO
% VARIABILE j scorrerà su tutti i test
% primo test j = 1
% popoliamo tabella finale in riga j perché ogni riga corrisponde ad un
% test


j = 1; % lo leveremo con ciclo esterno perché faremo j = 1:numel(nomi dei file (test))
% mettere if ground truth continue


%% Input .mat file
% Please change the path to a sequence .mat file from the dataset
filename = 'processed_MAT_Files/carbonZ_2018-07-18-15-53-31_1_engine_failure.mat';

%% Add the dataset tools library to the path
addpath('alfa-tools');

%% Load the sequence through the constructor
Sequence = sequence(filename);

%% Print brief information about the sequence
Sequence.PrintBriefInfo();

%% For each topic in topics
topics = fieldnames(Sequence.Topics);
% Get the start time to normalize times to start from zero
start_time = Sequence.GetStartTime();

fault_label = int8(0); % if 0 NO FAULT

for i = 1:numel(topics)
    % Get the topic name
    topic_name = topics(i);

    if isequal(topic_name{1}, 'mavros_imu_data_raw') || isequal(topic_name{1}, 'mavros_imu_mag') || isequal(topic_name{1}, 'mavros_imu_atm_pressure') || isequal(topic_name{1}, 'mavros_global_position_compass_hdg') || isequal(topic_name{1}, 'mavctrl_rpy') || isequal(topic_name{1}, 'mavlink_from') ||  isequal(topic_name{1}, 'mavros_local_position_pose') || isequal(topic_name{1}, 'mavros_imu_data') || isequal(topic_name{1}, 'mavros_wind_estimation') || isequal(topic_name{1}, 'mavros_setpoint_raw_target_global') || isequal(topic_name{1}, 'mavros_imu_temperature') || isequal(topic_name{1}, 'diagnostics') || isequal(topic_name{1}, 'mavros_global_position_raw_fix') 
        continue
    end

    if isequal(topic_name{1}, 'failure_status_engines')
        fault_label = 1;
        dataTable.FaultLabel(j) = fault_label;
        continue
    end
    % else controllo tabella altri tipi di failure
    % else controllo tabella altri tipi di failure
    % else controllo tabella altri tipi di failure
    % ELSE ricadiamo qui solo se il test non presenta un guasto -> quindi
    % fault label = 0
    % GESTIRE CASO IN CUI DUE LABEL PERCHE' RIGHT A E LEFT AILERON, E ANCHE
    % RUDDER E AILERON

    % Assign data to variable topic 
    topic = Sequence.GetTopicByName(topic_name{1});

    % Normalize the time stamps in the topic
    times = topic.Data.time_recv - start_time;
    
    % get data
    data = topic.Data;

    % Add column "times" with normalized time
    data.times = times;
    timestamps = seconds(data.times);
  

    if isequal(topic_name{1}, 'mavros_nav_info_velocity')

        data.errVel_x = data.des_x - data.meas_x;
        data.errVel_y = data.des_y - data.meas_y;
        data.errVel_z = data.des_z - data.meas_z;
        % data = removevars(data, {'coordinate_frame','des_x','des_y','des_z','header','meas_x','meas_y','meas_z','time_recv'});
       
        % Create timetable for 1 topic with feature selected
        topic_velocity_TT = timetable(timestamps, data.errVel_x, data.errVel_y, data.errVel_z);
        topic_velocity_TT = renamevars(topic_velocity_TT, 'Var1', 'errVel_x');
        topic_velocity_TT = renamevars(topic_velocity_TT, 'Var2', 'errVel_y');
        topic_velocity_TT = renamevars(topic_velocity_TT, 'Var3', 'errVel_z');
  
    end


    if isequal(topic_name{1}, 'mavros_global_position_global')   
        topic_global_position_TT = timetable(timestamps, data.altitude, data.latitude, data.longitude);
        topic_global_position_TT = renamevars(topic_global_position_TT, 'Var1', 'altitude');
        topic_global_position_TT = renamevars(topic_global_position_TT, 'Var2', 'latitude');
        topic_global_position_TT = renamevars(topic_global_position_TT, 'Var3', 'longitude');

    end
    
    % if i == 2 % velocity
    if i == 17 % altitude
        test_TT = synchronize(topic_velocity_TT,topic_global_position_TT, 'union', 'linear');
        
        f1=figure('Name', 'errVel_x before and after sampling','position',[150,0,1000,650]);
        f11=subplot(2,1,1,'Parent',f1);
        plot(topic_velocity_TT.timestamps,topic_velocity_TT.errVel_x,'-o');
        f12=subplot(2,1,2,'Parent',f1);
        plot(test_TT.timestamps, test_TT.errVel_x,'-o');

        f2=figure('Name', 'altitude before and after sampling','position',[150,0,1000,650]);
        f21=subplot(2,1,1,'Parent',f2);
        plot(topic_global_position_TT.timestamps,topic_global_position_TT.altitude,'-o');
        f22=subplot(2,1,2,'Parent',f2);
        plot(test_TT.timestamps, test_TT.altitude,'-o');
            
        % create timetables to put in the final table
        errVel_xTT = timetable(test_TT.timestamps, test_TT.errVel_x);
        errVel_yTT = timetable(test_TT.timestamps, test_TT.errVel_y);
        errVel_zTT = timetable(test_TT.timestamps, test_TT.errVel_z);
        altitudeTT = timetable(test_TT.timestamps, test_TT.altitude);
        latitudeTT = timetable(test_TT.timestamps, test_TT.latitude);
        longitudeTT = timetable(test_TT.timestamps, test_TT.longitude);

        dataTable.errVel_xTT(j) = {errVel_xTT};
        dataTable.errVel_yTT(j) = {errVel_yTT};
        dataTable.errVel_zTT(j) = {errVel_zTT};

        dataTable.altitudeTT(j) = {altitudeTT};
        dataTable.latitudeTT(j) = {latitudeTT};
        dataTable.longitudeTT(j) = {longitudeTT};

 
        break
    end
end



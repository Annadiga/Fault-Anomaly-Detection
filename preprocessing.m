%% ----------------------------------------------------- 
close all;
clear all;
clc;

%% CREAZIONE TABELLA FINALE CON ATTRIBUTI DI INTERESSE
% var1 | var2 | var 3 | ... | fault_label
%dataTable = table('Size',[1 1], 'VariableTypes', {'int8'}, 'VariableNames',{'FaultLabel'});
%dataTable = table('Size',[1 4], 'VariableTypes', {'timetable','timetable','timetable','int8'}, 'VariableNames',{'s_errVel_xTT', 's_errVel_yTT', 's_errVel_zTT' ,'FaultLabel'});
%dataTable = table('Size',[1 3], 'VariableTypes', {'timetable','timetable','timetable'}, 'VariableNames',{'s_errVel_xTT', 's_errVel_yTT', 's_errVel_zTT'});
dataTable = table();


freq_sampling = 25;
%formatIn = 'ss.SSSSSSSSSSSSSSS'; % define the input format for seconds with fractional values

%% 
% METTEREMO CICLO ESTERNO
% VARIABILE j scorrerà su tutti i test
% primo test j = 0
% popoliamo tabella finale in riga j perché ogni riga corrisponde ad un
% test

j = 1; % lo leveremo con ciclo esterno perché faremo j = 1:numel(nomi dei file (test))


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

    if isequal(topic_name{1}, 'mavros_imu_data_raw') || isequal(topic_name{1}, 'mavros_imu_mag') || isequal(topic_name{1}, 'mavros_imu_atm_pressure') || isequal(topic_name{1}, 'mavros_global_position_compass_hdg') || isequal(topic_name{1}, 'mavctrl_rpy') || isequal(topic_name{1}, 'mavlink_from') ||  isequal(topic_name{1}, 'mavros_local_position_pose') || isequal(topic_name{1}, 'mavros_imu_data') || isequal(topic_name{1}, 'mavros_wind_estimation') || isequal(topic_name{1}, 'mavros_setpoint_raw_target_global') || isequal(topic_name{1}, 'mavros_imu_temperature') 
        continue
    end

    % Assign data to variable topic 
    topic = Sequence.GetTopicByName(topic_name{1});

    % Normalize the time stamps in the topic
    times = topic.Data.time_recv - start_time;
    
    % get data
    data = topic.Data;

    % Add column "times" with normalized time
    data.times = times;

    % Resampling data for a fixed frequence

    % code to check label
    
    if isequal(topic_name{1}, 'failure_status_engines')
        fault_label = 1;
        dataTable.FaultLabel(j) = fault_label;
    end
    % else controllo tabella altri tipi di failure
    % else controllo tabella altri tipi di failure
    % else controllo tabella altri tipi di failure
    % ELSE ricadiamo qui solo se il test non presenta un guasto -> quindi
    % fault label = 0
    % GESTIRE CASO IN CUI DUE LABEL PERCHE' RIGHT A E LEFT AILERON, E ANCHE
    % RUDDER E AILERON
    

    if isequal(topic_name{1}, 'mavros_nav_info_velocity')
        data.errVel_x = data.des_x - data.meas_x;
        data.errVel_y = data.des_y - data.meas_y;
        data.errVel_z = data.des_z - data.meas_z;
        % data = removevars(data, {'coordinate_frame','des_x','des_y','des_z','header','meas_x','meas_y','meas_z','time_recv'});
        
        %timestamps = datetime(data.times, 'ConvertFrom', 'posixtime', 'Format', formatIn);
        timestamps = seconds(data.times);
        % Create timetables
        errVel_xTT = timetable(timestamps, data.errVel_x);
        errVel_yTT = timetable(timestamps, data.errVel_y);
        errVel_zTT = timetable(timestamps, data.errVel_z);

        % Sampling timestamps in the topic for 25 Hz
        s_errVel_xTT = resample(errVel_xTT, freq_sampling);
        s_errVel_xTT = renamevars(s_errVel_xTT, 'Var1', 's_errVel_x');

        s_errVel_yTT = resample(errVel_yTT, freq_sampling);
        s_errVel_yTT = renamevars(s_errVel_yTT, 'Var1', 's_errVel_y');

        s_errVel_zTT = resample(errVel_zTT, freq_sampling);
        s_errVel_zTT = renamevars(s_errVel_zTT, 'Var1', 's_errVel_z');


        subplot(2,1,1)
        plot(errVel_xTT.timestamps,errVel_xTT.Var1,'-o')
        subplot(2,1,2)
        plot(s_errVel_xTT.Time, s_errVel_xTT.s_errVel_x,'-o')



        dataTable.s_errVel_xTT(j) = {s_errVel_xTT};
        dataTable.s_errVel_yTT(j) = {s_errVel_yTT};
        dataTable.s_errVel_zTT(j) = {s_errVel_zTT};


    end


    if isequal(topic_name{1}, 'mavros_global_position_global')
        timestamps = seconds(data.times);
        % Create timetables
        altitudeTT = timetable(timestamps, data.altitude);
        latitudeTT = timetable(timestamps, data.latitude);
        longitudeTT = timetable(timestamps, data.longitude);
        

        % Sampling timestamps in the topic for 25 Hz
        s_altitudeTT = resample(altitudeTT, freq_sampling);
        s_altitudeTT = renamevars(s_altitudeTT, 'Var1', 's_altitute');

        s_latitudeTT = resample(latitudeTT, freq_sampling);
        s_latitudeTT = renamevars(s_latitudeTT, 'Var1', 's_latitude');

        s_longitudeTT = resample(errVel_zTT, freq_sampling);
        s_longitudeTT = renamevars(s_longitudeTT, 'Var1', 's_longitude');


        subplot(2,1,1)
        plot(altitudeTT.timestamps,altitudeTT.Var1,'-o')
        subplot(2,1,2)
        plot(s_altitudeTT.Time, s_altitudeTT.s_altitute,'-o')



        dataTable.s_altitudeTT(j) = {s_altitudeTT};
        dataTable.s_latitudeTT(j) = {s_latitudeTT};
        dataTable.s_longitudeTT(j) = {s_longitudeTT};




    end

    if i == 14
        break
    end
end


%% TEST 
%dataTable = cell2table(cell(1,1), 'VariableNames',{'s_errVel_xTT'});


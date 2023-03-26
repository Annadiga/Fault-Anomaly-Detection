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

    if  isequal(topic_name{1}, 'mavros_imu_data_raw') || isequal(topic_name{1}, 'mavros_imu_atm_pressure') || isequal(topic_name{1}, 'mavros_global_position_compass_hdg') || isequal(topic_name{1}, 'mavctrl_rpy') || isequal(topic_name{1}, 'mavlink_from') ||  isequal(topic_name{1}, 'mavros_local_position_pose') || isequal(topic_name{1}, 'mavros_wind_estimation') || isequal(topic_name{1}, 'mavros_setpoint_raw_target_global') || isequal(topic_name{1}, 'mavros_imu_temperature') || isequal(topic_name{1}, 'diagnostics') || isequal(topic_name{1}, 'mavros_global_position_raw_fix') 
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

    
    
    if isequal(topic_name{1}, 'mavros_imu_data')
        
        % ------------LINEAR ACCELERATION---------------
        linAcc_x = [];
        linAcc_y = [];
        linAcc_z = [];
        
        % Loop over rows of the table
        for k = 1:size(data, 1)
            
            % Extract structure from table
            myStruct = data.linear_acceleration(k);
            
            % Extract values from fields of structure
            linAcc_x_value = myStruct.x;
            linAcc_y_value = myStruct.y;
            linAcc_z_value = myStruct.z;
            
            % Append extracted values to arrays
            linAcc_x = [linAcc_x; linAcc_x_value];
            linAcc_y = [linAcc_y; linAcc_y_value];
            linAcc_z = [linAcc_z; linAcc_z_value];
        end

         % ------------ANGULAR VELOCITY---------------

        angVel_x = [];
        angVel_y = [];
        angVel_z = [];

        % Loop over rows of the table
        for k = 1:size(data, 1)
            
            % Extract structure from table
            myStruct = data.angular_velocity(k);
            
            % Extract values from fields of structure
            angVel_x_value = myStruct.x;
            angVel_y_value = myStruct.y;
            angVel_z_value = myStruct.z;
            
            % Append extracted values to arrays
            angVel_x = [angVel_x; angVel_x_value];
            angVel_y = [angVel_y; angVel_y_value];
            angVel_z = [angVel_z; angVel_z_value];
        end

        topic_imu_data_TT = timetable(timestamps, linAcc_x, linAcc_y, linAcc_z, angVel_x, angVel_y, angVel_z);
    end


    if isequal(topic_name{1}, 'mavros_imu_mag')

        mag_x = [];
        mag_y = [];
        mag_z = [];

        % Loop over rows of the table
        for k = 1:size(data, 1)
            
            % Extract structure from table
            myStruct = data.magnetic_field(k);
            
            % Extract values from fields of structure
            mag_x_value = myStruct.x;
            mag_y_value = myStruct.y;
            mag_z_value = myStruct.z;
            
            % Append extracted values to arrays
            mag_x = [mag_x; mag_x_value];
            mag_y = [mag_y; mag_y_value];
            mag_z = [mag_z; mag_z_value];
        end

        topic_imu_mag_TT = timetable(timestamps, mag_x, mag_y, mag_z);
    end
  

    if isequal(topic_name{1}, 'mavros_nav_info_velocity')

        data.errVel_x = abs(data.des_x - data.meas_x);
        data.errVel_y = abs(data.des_y - data.meas_y);
        data.errVel_z = abs(data.des_z - data.meas_z);
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
        % test_TT = synchronize(topic_velocity_TT,topic_global_position_TT, topic_imu_data_row_TT, 'union', 'linear');
        test_TT = synchronize(topic_imu_mag_TT, topic_velocity_TT,topic_global_position_TT, topic_imu_data_TT, 'regular', 'linear', 'SampleRate', fs_new);

        %{
        f1=figure('Name', 'errVel_x before and after sampling','position',[150,0,1000,650]);
        f11=subplot(2,1,1,'Parent',f1);
        plot(topic_velocity_TT.timestamps,topic_velocity_TT.errVel_x,'-o');
        f12=subplot(2,1,2,'Parent',f1);
        plot(test_TT.timestamps, test_TT.errVel_x,'-o');

        f3=figure('Name', 'errVel_y before and after sampling','position',[150,0,1000,650]);
        f31=subplot(2,1,1,'Parent',f3);
        plot(topic_velocity_TT.timestamps,topic_velocity_TT.errVel_y,'-o');
        f32=subplot(2,1,2,'Parent',f3);
        plot(test_TT.timestamps, test_TT.errVel_y,'-o');

        f4=figure('Name', 'errVel_z before and after sampling','position',[150,0,1000,650]);
        f41=subplot(2,1,1,'Parent',f4);
        plot(topic_velocity_TT.timestamps,topic_velocity_TT.errVel_z,'-o');
        f42=subplot(2,1,2,'Parent',f4);
        plot(test_TT.timestamps, test_TT.errVel_z,'-o');

        f2=figure('Name', 'altitude before and after sampling','position',[150,0,1000,650]);
        f21=subplot(2,1,1,'Parent',f2);
        plot(topic_global_position_TT.timestamps,topic_global_position_TT.altitude,'-o');
        f22=subplot(2,1,2,'Parent',f2);
        plot(test_TT.timestamps, test_TT.altitude,'-o');
        
        

        f5=figure('Name', 'linAcc_x before and after sampling','position',[150,0,1000,650]);
        f51=subplot(2,1,1,'Parent',f5);
        plot(topic_imu_data_TT.timestamps, topic_imu_data_TT.linAcc_x,'-o');
        f52=subplot(2,1,2,'Parent',f5);
        plot(test_TT.timestamps, test_TT.linAcc_x,'-o');

        f6=figure('Name', 'velAng_x before and after sampling','position',[150,0,1000,650]);
        f61=subplot(2,1,1,'Parent',f6);
        plot(topic_imu_data_TT.timestamps, topic_imu_data_TT.angVel_x,'-o');
        f62=subplot(2,1,2,'Parent',f6);
        plot(test_TT.timestamps, test_TT.angVel_x,'-o');
        %}

        f7=figure('Name', 'mag_x before and after sampling','position',[150,0,1000,650]);
        f71=subplot(2,1,1,'Parent',f7);
        plot(topic_imu_mag_TT.timestamps, topic_imu_mag_TT.mag_x,'-o');
        f72=subplot(2,1,2,'Parent',f7);
        plot(test_TT.timestamps, test_TT.mag_x,'-o');
            
        % create timetables to put in the final table
        mag_xTT = timetable(test_TT.timestamps, test_TT.mag_x);
        mag_yTT = timetable(test_TT.timestamps, test_TT.mag_y);
        mag_zTT = timetable(test_TT.timestamps, test_TT.mag_z);

        linAcc_xTT = timetable(test_TT.timestamps, test_TT.linAcc_x);
        linAcc_yTT = timetable(test_TT.timestamps, test_TT.linAcc_y);
        linAcc_zTT = timetable(test_TT.timestamps, test_TT.linAcc_z);
        angVel_xTT = timetable(test_TT.timestamps, test_TT.angVel_x);
        angVel_yTT = timetable(test_TT.timestamps, test_TT.angVel_y);
        angVel_zTT = timetable(test_TT.timestamps, test_TT.angVel_z);

        errVel_xTT = timetable(test_TT.timestamps, test_TT.errVel_x);
        errVel_yTT = timetable(test_TT.timestamps, test_TT.errVel_y);
        errVel_zTT = timetable(test_TT.timestamps, test_TT.errVel_z);

        altitudeTT = timetable(test_TT.timestamps, test_TT.altitude);
        latitudeTT = timetable(test_TT.timestamps, test_TT.latitude);
        longitudeTT = timetable(test_TT.timestamps, test_TT.longitude);

        % put timetables in final table
        % topic imu data mag
        dataTable.mag_xTT(j) = {mag_xTT};
        dataTable.mag_yTT(j) = {mag_yTT};
        dataTable.mag_zTT(j) = {mag_zTT};

        % topic imu data raw
        dataTable.linAcc_xTT(j) = {linAcc_xTT};
        dataTable.linAcc_yTT(j) = {linAcc_yTT};
        dataTable.linAcc_zTT(j) = {linAcc_zTT};
        dataTable.angVel_xTT(j) = {angVel_xTT};
        dataTable.angVel_yTT(j) = {angVel_yTT};
        dataTable.angVel_zTT(j) = {angVel_zTT};

        % topic mavros info velocity
        dataTable.errVel_xTT(j) = {errVel_xTT};
        dataTable.errVel_yTT(j) = {errVel_yTT};
        dataTable.errVel_zTT(j) = {errVel_zTT};
        
        % topic mavros global position
        dataTable.altitudeTT(j) = {altitudeTT};
        dataTable.latitudeTT(j) = {latitudeTT};
        dataTable.longitudeTT(j) = {longitudeTT};

        break
    end
end



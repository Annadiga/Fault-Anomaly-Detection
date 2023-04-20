%% ----------------------------------------------------- 
close all;
clear all;
clc;

%% --------------------------------
% Add the dataset tools library to the path
addpath('alfa-tools');

%% CREAZIONE TABELLA FINALE CON ATTRIBUTI DI INTERESSE
dataTable = table();

fs_new = 25; % New sampling rate


% METTEREMO CICLO ESTERNO
% VARIABILE j scorrerà su tutti i test
% primo test j = 1
% popoliamo tabella finale in riga j perché ogni riga corrisponde ad un
% test

folder = 'NewFilesWithSplitFault_NoFault';
fileList = dir(fullfile(folder, '*.mat')); % list all files in folder with .mat extension

%fileList = dir([folder '*.mat']);
disp(fileList)

% Iterate over each file in the directory
for j = 1:length(fileList)
    % Get the file name (including the path)
    filename = fullfile(folder, fileList(j).name);
   
    %j = 1; % rimosso perchè presente ciclo esterno -> j = 1:numel(nomi dei file (test))
  
    %% Input .mat file
    
    % filename = 'processed_MAT_Files/carbonZ_2018-07-18-15-53-31_1_engine_failure.mat';
    
    fault_label = int8(0); % if 0 NO FAULT

    if contains(filename, 'no_failure')
        fault_label = 0;
        dataTable.FaultLabel(j) = fault_label;
    
    elseif contains(filename, 'engine_failure')
        fault_label = 1;
        dataTable.FaultLabel(j) = fault_label;

    elseif contains(filename, 'rudder_zero__left_aileron_failure')
        fault_label = 5;
        dataTable.FaultLabel(j) = fault_label;  

    elseif contains(filename, 'both_ailerons')
        fault_label = 4;
        dataTable.FaultLabel(j) = fault_label; 
    
    %{
    elseif contains(filename, 'left_aileron__right_aileron__failure') 
        % fault_label = 100;    %label provvisoria prima di fare lo split del test
        % dataTable.FaultLabel(j) = fault_label; 
        % carbonZ_2018-09-11-14-52-54_left_aileron__right_aileron__failure
        continue % go to the next for loop

    %}

    elseif contains(filename, 'left_aileron')
        fault_label = 2;
        dataTable.FaultLabel(j) = fault_label; 

    elseif contains(filename, 'right_aileron')
        fault_label = 3;
        dataTable.FaultLabel(j) = fault_label; 

    elseif contains(filename, 'elevator_failure')
        fault_label = 8;
        dataTable.FaultLabel(j) = fault_label;

    elseif contains(filename, 'rudder_right')
        fault_label = 7;
        dataTable.FaultLabel(j) = fault_label;

    elseif contains(filename, 'rudder_left')
        fault_label = 6;
        dataTable.FaultLabel(j) = fault_label;
    end 
    
 
    %{
        0 NO GUASTO
        1 guasto engine
        2 aileron destra
        3 aileron sinistra
        4 aileron entrambi
        5 rudder & aileron posizione 0
        6 rudder sinistra
        7 rudder destra
        8 elevator posizione 0
    %}
    
    
    
    %% Load the sequence through the constructor
    Sequence = sequence(filename);
    
    %% Print brief information about the sequence
    % Sequence.PrintBriefInfo();
    
    %% For each topic in topics
    topics = fieldnames(Sequence.Topics);
    % Get the start time to normalize times to start from zero
    start_time = Sequence.GetStartTime();
    
   
    for i = 1:numel(topics)
 
        % disp(i)
        % disp(numel(topics))
    
        % Get the topic name
        topic_name = topics(i);
        
        %{
        if  isequal(topic_name{1}, 'mavros_imu_data_raw') || isequal(topic_name{1}, 'mavros_imu_atm_pressure') || isequal(topic_name{1}, 'mavros_global_position_compass_hdg') || isequal(topic_name{1}, 'mavctrl_rpy') || isequal(topic_name{1}, 'mavlink_from') ||  isequal(topic_name{1}, 'mavros_local_position_pose') || isequal(topic_name{1}, 'mavros_wind_estimation') || isequal(topic_name{1}, 'mavros_setpoint_raw_target_global') || isequal(topic_name{1}, 'mavros_imu_temperature') || isequal(topic_name{1}, 'diagnostics') || isequal(topic_name{1}, 'mavros_global_position_raw_fix') || isequal(topic_name{1}, 'mavros_state') || isequal(topic_name{1}, 'mavros_rc_in') || isequal(topic_name{1}, 'mavros_setpoint_raw_local') || isequal(topic_name{1}, 'mavros_battery') || isequal(topic_name{1}, 'mavros_global_position_rel_alt') || isequal(topic_name{1}, 'mavros_local_position_odom') || isequal(topic_name{1}, 'mavros_local_position_velocity') || isequal(topic_name{1}, 'mavros_global_position_raw_gps_vel') || isequal(topic_name{1}, 'mavros_rc_out') || isequal(topic_name{1}, 'mavros_time_reference')    
            continue      
        end
        %}


        % Assign data to variable topic 
        topic = Sequence.GetTopicByName(topic_name{1});
    
        % Normalize the time stamps in the topic
        times = topic.Data.time_recv - start_time;
        
        % get data
        data = topic.Data;
    
        % Add column "times" with normalized time
        data.times = times;
        
        if contains(filename, 'no_failure')
           data([data.times] <= 5, :) = [];
           data.times = data.times - 5;
        end
        
        timestamps = seconds(data.times);

        
        if isequal(topic_name{1}, 'mavros_imu_data')
            
            % ------------LINEAR ACCELERATION---------------
            linAcc_x = [];
            linAcc_y = [];
            linAcc_z = [];
            
            % Loop over rows of the table
            for k = 1:size(data, 1)
               
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
    
            % Extract structure from table
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
    
    
        if isequal(topic_name{1}, 'mavros_nav_info_roll')
    
            data.err_roll = abs(data.measured - data.commanded);
            
            % Create timetable 
            topic_err_roll_TT = timetable(timestamps, data.err_roll);
            topic_err_roll_TT = renamevars(topic_err_roll_TT, 'Var1', 'err_roll');    
        end
    
    
    
        if isequal(topic_name{1}, 'mavros_nav_info_airspeed')
    
            data.err_airspeed = abs(data.measured - data.commanded);
            
            % Create timetable 
            topic_err_airspeed_TT = timetable(timestamps, data.err_airspeed);
            topic_err_airspeed_TT = renamevars(topic_err_airspeed_TT, 'Var1', 'err_airspeed');    
    
        end
    
        if isequal(topic_name{1}, 'mavros_nav_info_errors')   
            topic_info_errors_TT = timetable(timestamps, data.aspd_error, data.alt_error);
            topic_info_errors_TT = renamevars(topic_info_errors_TT, 'Var1', 'aspd_error');
            topic_info_errors_TT = renamevars(topic_info_errors_TT, 'Var2', 'alt_error');
    
        end
    
    
        if isequal(topic_name{1}, 'mavros_nav_info_yaw')
            data.err_yaw = abs(data.measured - data.commanded);
    
            % Create timetable 
            topic_err_yaw_TT = timetable(timestamps, data.err_yaw);
            topic_err_yaw_TT = renamevars(topic_err_yaw_TT, 'Var1', 'err_yaw');
        end
    
        if isequal(topic_name{1}, 'mavros_nav_info_pitch')
       
            data.err_pitch = abs(data.measured - data.commanded);
    
            % Create timetable 
            topic_err_pitch_TT = timetable(timestamps, data.err_pitch);
            topic_err_pitch_TT = renamevars(topic_err_pitch_TT, 'Var1', 'err_pitch');
        end
    
        
        %{
        if isequal(topic_name{1}, 'mavctrl_path_dev')   
            topic_mavctrl_path_dev_TT = timetable(timestamps, data.x, data.y, data.z);
            topic_mavctrl_path_dev_TT = renamevars(topic_mavctrl_path_dev_TT, 'Var1', 'path_dev_x');
            topic_mavctrl_path_dev_TT = renamevars(topic_mavctrl_path_dev_TT, 'Var2', 'path_dev_y');
            topic_mavctrl_path_dev_TT = renamevars(topic_mavctrl_path_dev_TT, 'Var3', 'path_dev_z');
        end
        %}
        
        % if i == 2 % velocity
        % if i == 17 % altitude
        % if i == 17 %roll
        % if i == 29 % pitch
        % if i == 33 % mav_ctrl_path_dev
        % if i == numel(topics) % mavros_time_reference
    
        if isequal(i, numel(topics)) 
    
            % test_TT = synchronize(topic_velocity_TT,topic_global_position_TT, topic_imu_data_row_TT, 'union', 'linear');
            test_TT = synchronize(topic_velocity_TT,topic_global_position_TT, topic_imu_data_TT, topic_err_roll_TT, topic_err_airspeed_TT, topic_info_errors_TT, topic_err_yaw_TT, topic_err_pitch_TT, 'regular', 'linear', 'SampleRate', fs_new);
                        
            test_TT = test_TT([test_TT.timestamps] >= 0,:);

            if(test_TT.timestamps(1) ~= 0)
                newRow = test_TT(1,:);
                test_TT = [newRow; test_TT(:,:)];
                test_TT.timestamps(1) = 0;
            end
            
            num_rows_test_TT = size(test_TT, 1);
            
            remain = rem(num_rows_test_TT, 64);

            if(remain == 0)
                test_TT = test_TT(1:end-63,:);
            elseif(remain ~= 1) % vogliamo numero di righe multiplo di 64 + 1 di scarto           
                test_TT = test_TT(1:end-(remain-1),:);
            end
            
            dur1 = duration(0, 0, 17.92);  % 0 hours 0 minutes and 17.92 seconds
            if (test_TT.timestamps(size(test_TT, 1)) == dur1)
                test_TT = test_TT(1:end-(1),:);
            end

            dur2 = duration(0, 0, 35.84);  
            if (test_TT.timestamps(size(test_TT, 1)) == dur2)
                test_TT = test_TT(1:end-(1),:);
            end
            
            dur3 = duration(0, 0, 71.68);  
            if (test_TT.timestamps(size(test_TT, 1)) == dur3)
                test_TT = test_TT(1:end-(1),:);
            end


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
           
            f7=figure('Name', 'mag_x before and after sampling','position',[150,0,1000,650]);
            f71=subplot(2,1,1,'Parent',f7);
            plot(topic_imu_mag_TT.timestamps, topic_imu_mag_TT.mag_x,'-o');
            f72=subplot(2,1,2,'Parent',f7);
            plot(test_TT.timestamps, test_TT.mag_x,'-o');
            
    
            f8=figure('Name', 'err_roll before and after sampling','position',[150,0,1000,650]);
            f81=subplot(2,1,1,'Parent',f8);
            plot(topic_err_roll_TT.timestamps, topic_err_roll_TT.err_roll,'-o');
            f82=subplot(2,1,2,'Parent',f8);
            plot(test_TT.timestamps, test_TT.err_roll,'-o');
    
            f9=figure('Name', 'err_yaw before and after sampling','position',[150,0,1000,650]);
            f91=subplot(2,1,1,'Parent',f9);
            plot(topic_err_yaw_TT.timestamps, topic_err_yaw_TT.err_yaw,'-o');
            f92=subplot(2,1,2,'Parent',f9);
            plot(test_TT.timestamps, test_TT.err_yaw,'-o');
    
            f10=figure('Name', 'err_pitch before and after sampling','position',[150,0,1000,650]);
            f101=subplot(2,1,1,'Parent',f10);
            plot(topic_err_pitch_TT.timestamps, topic_err_pitch_TT.err_pitch,'-o');
            f102=subplot(2,1,2,'Parent',f10);
            plot(test_TT.timestamps, test_TT.err_pitch,'-o');
          
    
            f11=figure('Name', 'orientation_x before and after sampling','position',[150,0,1000,650]);
            f111=subplot(2,1,1,'Parent',f11);
            plot(topic_global_position_local_TT.timestamps, topic_global_position_local_TT.orientation_x,'-o');
            f112=subplot(2,1,2,'Parent',f11);
            plot(test_TT.timestamps, test_TT.orientation_x,'-o');
    
            
    
            f12=figure('Name', 'throttle before and after sampling','position',[150,0,1000,650]);
            f121=subplot(2,1,1,'Parent',f12);
            plot(topic_vfr_hud_TT.timestamps, topic_vfr_hud_TT.throttle,'-o');
            f122=subplot(2,1,2,'Parent',f12);
            plot(test_TT.timestamps, test_TT.throttle,'-o');
            
           
    
            f13=figure('Name', 'path_dev_y before and after sampling','position',[150,0,1000,650]);
            f131=subplot(2,1,1,'Parent',f13);
            plot(topic_mavctrl_path_dev_TT.timestamps, topic_mavctrl_path_dev_TT.path_dev_y,'-o');
            f132=subplot(2,1,2,'Parent',f13);
            plot(test_TT.timestamps, test_TT.path_dev_y,'-o');
            
            %}
     
            % create timetables to put in the final table
    
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
    
            err_roll_TT = timetable(test_TT.timestamps, test_TT.err_roll);
    
            err_airspeed_TT = timetable(test_TT.timestamps, test_TT.err_airspeed);
    
            aspd_error_TT = timetable(test_TT.timestamps, test_TT.aspd_error);
            alt_error_TT = timetable(test_TT.timestamps, test_TT.alt_error);
    
            err_yaw_TT = timetable(test_TT.timestamps, test_TT.err_yaw);
    
            err_pitch_TT = timetable(test_TT.timestamps, test_TT.err_pitch);
    
          
        
            %path_dev_xTT = timetable(test_TT.timestamps, test_TT.path_dev_x);
            %path_dev_yTT = timetable(test_TT.timestamps, test_TT.path_dev_y);
            %path_dev_zTT = timetable(test_TT.timestamps, test_TT.path_dev_z);
    
    
            % put timetables in final table
            
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
    
            % topic mavros info roll
            dataTable.err_roll_TT(j) = {err_roll_TT};
    
            % topic mavros info airspeed
            dataTable.err_airspeed_TT(j) = {err_airspeed_TT};
    
            %topic mavros nav info errors
            dataTable.aspd_error_TT(j) = {aspd_error_TT};
            dataTable.alt_error_TT(j) = {alt_error_TT};
    
            % topic mavros info yaw
            dataTable.err_yaw_TT(j) = {err_yaw_TT};
    
            % topic mavros info pitch
            dataTable.err_pitch_TT(j) = {err_pitch_TT};

    
            % topic mvctrl path dev
            %{
            dataTable.path_dev_x(j) = {path_dev_xTT};
            dataTable.path_dev_y(j) = {path_dev_yTT};
            dataTable.path_dev_z(j) = {path_dev_zTT};
            %}
        end
    end

    %if j == 11
    %   return
    % end
end


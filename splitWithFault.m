close all;
clear all;
clc;


addpath('alfa-tools');

folder = 'processed_MAT_Files'; % replace with the path to your folder
fileList = dir(fullfile(folder, '*.mat')); % list all files in folder with .txt extension

%fileList = dir([folder '*.mat']);
disp(fileList)

% Iterate over each file in the directory
for j = 1:length(fileList)

    
    filename = fullfile(folder, fileList(j).name);
    Sequence = sequence(filename);
    start_time = Sequence.GetStartTime();
   

    if contains(filename, 'engine_failur')
        time_first_failure = Sequence.Topics.failure_status_engines.time_recv(1);
        disp(time_first_failure);

        % start_time = Sequence.GetStartTime();
        topics = fieldnames(Sequence.Topics);
        for i = 1:numel(topics)
            topic_name = topics{i};     % Get the current field name
            Sequence.Topics.(topic_name)([Sequence.Topics.(topic_name).time_recv] >= start_time & [Sequence.Topics.(topic_name).time_recv] < time_first_failure, :) = [];
        end
        [filepath,name,ext] = fileparts(filename);
        name = fullfile(filepath, name); 
        path = strcat('NewFilesWithSplitFault_NoFault/', Sequence.Name);
        total_file =  strcat(path, "_with_failure.mat"); 
        save(total_file, 'Sequence');




     elseif contains(filename, 'elevator_failure')
        time_first_failure = Sequence.Topics.failure_status_elevator.time_recv(1);
        disp(time_first_failure);

        % start_time = Sequence.GetStartTime();
        topics = fieldnames(Sequence.Topics);
        for i = 1:numel(topics)
            topic_name = topics{i};     % Get the current field name
            Sequence.Topics.(topic_name)([Sequence.Topics.(topic_name).time_recv] >= start_time & [Sequence.Topics.(topic_name).time_recv] < time_first_failure, :) = [];
        end
        [filepath,name,ext] = fileparts(filename);
        name = fullfile(filepath, name); 
        path = strcat('NewFilesWithSplitFault_NoFault/', Sequence.Name);
        total_file =  strcat(path, "_with_failure.mat"); 
        save(total_file, 'Sequence');
     
     elseif contains(filename, 'aileron_failure')
        time_first_failure = Sequence.Topics.failure_status_aileron.time_recv(1);
        disp(time_first_failure);

        % start_time = Sequence.GetStartTime();
        topics = fieldnames(Sequence.Topics);
        for i = 1:numel(topics)
            topic_name = topics{i};     % Get the current field name
            Sequence.Topics.(topic_name)([Sequence.Topics.(topic_name).time_recv] >= start_time & [Sequence.Topics.(topic_name).time_recv] < time_first_failure, :) = [];
        end
        [filepath,name,ext] = fileparts(filename);
        name = fullfile(filepath, name); 
        path = strcat('NewFilesWithSplitFault_NoFault/', Sequence.Name);
        total_file =  strcat(path, "_with_failure.mat"); 
        save(total_file, 'Sequence');
      

      elseif contains(filename, 'aileron__failure')
        time_first_failure = Sequence.Topics.failure_status_aileron.time_recv(1);
        disp(time_first_failure);

        % start_time = Sequence.GetStartTime();
        topics = fieldnames(Sequence.Topics);
        for i = 1:numel(topics)
            topic_name = topics{i};     % Get the current field name
            Sequence.Topics.(topic_name)([Sequence.Topics.(topic_name).time_recv] >= start_time & [Sequence.Topics.(topic_name).time_recv] < time_first_failure, :) = [];
        end
        [filepath,name,ext] = fileparts(filename);
        name = fullfile(filepath, name); 
        path = strcat('NewFilesWithSplitFault_NoFault/', Sequence.Name);
        total_file =  strcat(path, "_with_failure.mat"); 
        save(total_file, 'Sequence');

     elseif contains(filename, 'ailerons_failure')
        time_first_failure = Sequence.Topics.failure_status_aileron.time_recv(1);
        disp(time_first_failure);

        % start_time = Sequence.GetStartTime();
        topics = fieldnames(Sequence.Topics);
        for i = 1:numel(topics)
            topic_name = topics{i};     % Get the current field name
            Sequence.Topics.(topic_name)([Sequence.Topics.(topic_name).time_recv] >= start_time & [Sequence.Topics.(topic_name).time_recv] < time_first_failure, :) = [];
        end
        [filepath,name,ext] = fileparts(filename);
        name = fullfile(filepath, name); 
        path = strcat('NewFilesWithSplitFault_NoFault/', Sequence.Name);
        total_file =  strcat(path, "_with_failure.mat"); 
        save(total_file, 'Sequence');


     elseif contains(filename, 'rudder_right')
        time_first_failure = Sequence.Topics.failure_status_rudder.time_recv(1);
        disp(time_first_failure);

        % start_time = Sequence.GetStartTime();
        topics = fieldnames(Sequence.Topics);
        for i = 1:numel(topics)
            topic_name = topics{i};     % Get the current field name
            Sequence.Topics.(topic_name)([Sequence.Topics.(topic_name).time_recv] >= start_time & [Sequence.Topics.(topic_name).time_recv] < time_first_failure, :) = [];
        end
        [filepath,name,ext] = fileparts(filename);
        name = fullfile(filepath, name); 
        path = strcat('NewFilesWithSplitFault_NoFault/', Sequence.Name);
        total_file =  strcat(path, "_with_failure.mat"); 
        save(total_file, 'Sequence');

     elseif contains(filename, 'rudder_left')
        time_first_failure = Sequence.Topics.failure_status_rudder.time_recv(1);
        disp(time_first_failure);

        % start_time = Sequence.GetStartTime();
        topics = fieldnames(Sequence.Topics);
        for i = 1:numel(topics)
            topic_name = topics{i};     % Get the current field name
            Sequence.Topics.(topic_name)([Sequence.Topics.(topic_name).time_recv] >= start_time & [Sequence.Topics.(topic_name).time_recv] < time_first_failure, :) = [];
        end
        [filepath,name,ext] = fileparts(filename);
        name = fullfile(filepath, name); 
        path = strcat('NewFilesWithSplitFault_NoFault/', Sequence.Name);
        total_file =  strcat(path, "_with_failure.mat"); 
        save(total_file, 'Sequence');

     else
        continue
     end 
    
 
end



       
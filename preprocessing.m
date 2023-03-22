%% ----------------------------------------------------- 
close all;
clear all;
clc;

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

fault_label = 0; %if 0 NO FAULT

for i = 1:numel(topics)
    % Get the topic name
    topic_name = topics(i);

    % Assign data to variable topic 
    topic = Sequence.GetTopicByName(topic_name{1});

    % Normalize the time stamps in the topic
    times = topic.Data.time_recv - start_time;
    
    % get data
    data = topic.Data;

    % Add column "times" with normalized time
    data.times = times;

    if isequal(topic_name{1}, 'failure_status_engines')
        %disp(topic_name)
        fault_label = 1; 
    end



    if i == 1
        break
    end
end



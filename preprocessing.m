%% ----------------------------------------------------- 
close all;
clear all;
clc;

%% CREAZIONE TABELLA FINALE CON ATTRIBUTI DI INTERESSE
% var1 | var2 | var 3 | ... | fault_label
dataTable = table('Size',[1 1], 'VariableTypes', {'int8'}, 'VariableNames',{'FaultLabel'});

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

    


    if i == 1
        break
    end
end



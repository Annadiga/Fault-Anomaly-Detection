%% ----------------------------------------------------- 
close all;
clear all;
clc;

%% data load--------------------------------------------
%data = load("carbonZ_2018-09-11-15-05-11_1_elevator_failure.mat");



%%------------------------------------------------------

mkdir topics;


%%------------------------------------------------------
% Specify the directory path
path_input = 'processed_MAT_Files';

% Get a structure array of all files in the directory
files = dir(fullfile(path_input, '*'));

for i = 1:numel(files)
    % Check if the file is a directory or a file
     if ~files(i).isdir
        % Process the file here
        file_name = files(i).name;

        slash = "/";
        % file_to_get = [path_input slash file_name];
        file_to_get = strcat(path_input, slash, file_name);


        % Generate a dynamic variable name based on the file name
        [~, var_name, ~] = fileparts(file_name);
        var_name = regexprep(var_name, '[^a-zA-Z0-9_]', '_');
        max_length = 63; %the name of variables in MATLAB can't exceed maximum length of 63 characters
        var_name = sprintf('T_%s', var_name); %T stands for 'Topics'
        
        %if length(var_name) > max_length
            %var_name = extractBetween(var_name, "T", max_length);
        %end
        

        % Load data from the file
        data = load(file_to_get);

        % Assign the data to the variable with the dynamic variable name
        eval(sprintf('%s = data.Sequence.Topics;', var_name));

        % Save the variable to a file with the dynamic variable name
        path_output = 'topics/';
        % file_to_save = [path_output file_name];
        
        %save(file_to_save, 'var.(var_name)');

        filename = sprintf('%s.mat', strrep(var_name, '/', '_'));
        %file_to_save = strcat(path_output, filename);
        %save(file_to_save, var_name);

        file_to_save = fullfile(path_output, filename);
        save(file_to_save, var_name);

        % Clear the variable from the workspace to free up memory
        clear(var_name)
    end
end
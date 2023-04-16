%% clear 
close all;
clear all;
clc;

%% Load dataset
T = load('output-feature-ranking.mat');
T = T.FeatureTable1;

%% count labels of imbalance dataset

counts = tabulate(T.FaultLabel);

labels = counts(:,1);
label_counts = counts(:,2);

bar(labels, label_counts)
xlabel('Labels')
ylabel('Counts')
title('Histogram of Label Counts')

%% split labels and features da T
features = T(:, 4:35);
labels = T.FaultLabel;

%% Split dataset in training (for X-fold-cross validation) and test set (10%)
c = cvpartition(labels,'Holdout',0.1,'Stratify',true);

test_set = T(c.test, 3:35);
save('test_set.mat', 'test_set');


%{
%% Separate features and labels
train_features = features(c.training,:);
train_labels = labels(c.training,:);
test_features = features(c.test,:);
test_labels = labels(c.test,:);

%}

%% SMOTE FOR EACH FAULT

% Add the SMOTE function to your MATLAB path
addpath('SMOTE');

training_set = T(c.training, :);
counts = tabulate(training_set.FaultLabel);

new_training_set = training_set(training_set.FaultLabel == 0, 3:35); % only no faulty, then we will append original + synthethic data for faulty test


for j=1:8 % class 0 is the majority class
    X = training_set(training_set.FaultLabel == j, 4:35); % get only rows of training set with engine failure (1)
    X = table2array(X);

    if(j==1)
        N = 10;
        k = 10;
        Y = smote(X, N,k);
        
        % Create a column vector of all 1's
        newColumn = ones(size(Y, 1), 1);
        % newColumn = repmat(2, size(Y, 1), 1); % fill new column with 2
      
        % Add the new column to the table without specifying a name
        Y = [newColumn, Y];
        Y = array2table(Y);
        Y.Properties.VariableNames = new_training_set.Properties.VariableNames;
        new_training_set = vertcat(new_training_set, Y);

    elseif(j==2)
        N = 27;
        k = 27;
        Y = smote(X, N,k);
        
        newColumn = repmat(2, size(Y, 1), 1); % fill new column with 2
      
        % Add the new column to the table without specifying a name
        Y = [newColumn, Y];
        Y = array2table(Y);
        Y.Properties.VariableNames = new_training_set.Properties.VariableNames;
        new_training_set = vertcat(new_training_set, Y);

   elseif(j==3)
        N = 22;
        k = 22;
        Y = smote(X, N,k);
        
        newColumn = repmat(3, size(Y, 1), 1); 
      
        % Add the new column to the table without specifying a name
        Y = [newColumn, Y];
        Y = array2table(Y);
        Y.Properties.VariableNames = new_training_set.Properties.VariableNames;
        new_training_set = vertcat(new_training_set, Y);

   elseif(j==4)
        N = 12;
        k = 12;
        Y = smote(X, N,k);
        N = 6;
        k = 6;
        Y = smote(Y,N,k);
        
        newColumn = repmat(4, size(Y, 1), 1); % add label
      
        % Add the new column to the table without specifying a name
        Y = [newColumn, Y];
        Y = array2table(Y);
        Y.Properties.VariableNames = new_training_set.Properties.VariableNames;
        new_training_set = vertcat(new_training_set, Y);

   elseif(j==5)
        N = 8;
        k = 8;
        Y = smote(X, N,k);
        N = 15;
        k = 15;
        Y = smote(Y,N,k);
        
        newColumn = repmat(5, size(Y, 1), 1); % add label
      
        % Add the new column to the table without specifying a name
        Y = [newColumn, Y];
        Y = array2table(Y);
        Y.Properties.VariableNames = new_training_set.Properties.VariableNames;
        new_training_set = vertcat(new_training_set, Y);   

   elseif(j==6)
        N = 1;
        k = 1;
        Y = smote(X, N,k);
        N = 3;
        k = 3;
        Y = smote(Y,N,k);
        N = 15;
        k = 15;
        Y = smote(Y,N,k);
        N = 4;
        k = 4;
        Y = smote(Y,N,k);

        newColumn = repmat(6, size(Y, 1), 1); % add label
      
        % Add the new column to the table without specifying a name
        Y = [newColumn, Y];
        Y = array2table(Y);
        Y.Properties.VariableNames = new_training_set.Properties.VariableNames;
        new_training_set = vertcat(new_training_set, Y);

   elseif(j==7)
        N = 9;
        k = 9;
        Y = smote(X, N,k);
        N = 12;
        k = 12;
        Y = smote(Y,N,k);
        
        newColumn = repmat(7, size(Y, 1), 1); % add label
      
        % Add the new column to the table without specifying a name
        Y = [newColumn, Y];
        Y = array2table(Y);
        Y.Properties.VariableNames = new_training_set.Properties.VariableNames;
        new_training_set = vertcat(new_training_set, Y);

   elseif(j==8)
        N = 6;
        k = 6;
        Y = smote(X, N,k);
        N = 25;
        k = 25;
        Y = smote(Y,N,k);
        
        newColumn = repmat(8, size(Y, 1), 1); % add label
      
        % Add the new column to the table without specifying a name
        Y = [newColumn, Y];
        Y = array2table(Y);
        Y.Properties.VariableNames = new_training_set.Properties.VariableNames;
        new_training_set = vertcat(new_training_set, Y);
    end

end

% count labels of balance dataset

counts = tabulate(new_training_set.FaultLabel);

labels = counts(:,1);
label_counts = counts(:,2);

bar(labels, label_counts)
xlabel('Labels')
ylabel('Counts')
title('Histogram of Label Counts')

save('training_set.mat', 'new_training_set');

%{
X = T(c.training, 4:35); % get training data (32 features)
X = table2array(X);

C = T(c.training, 'FaultLabel');
C = table2array(C);

[Y,C] = smote(X, [5,5,5,5,5,5,2,5,5], [5,5,5,5,5,5,2,5,5], 'Class',C);

%}


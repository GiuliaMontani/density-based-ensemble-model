
clc; clear all; close all;
% Assuming the current working directory contains the cloned/extracted folders
script_directory = pwd;
cd(fullfile(script_directory, 'gpml-matlab-master'))
addpath(fullfile(script_directory, 'gpml-matlab-master'));
startup;
cd(script_directory);
addpath(genpath(fullfile(script_directory, 'LKAAR')));
addpath(fullfile(script_directory,'netlab'));

base_path = fullfile(script_directory, '..', 'data', '50_real_data_split');
X_train_base = 'X_train.csv';
Y_train_base = 'Y_train.csv';
X_test_base = 'X_test.csv';
Y_test_base = 'gt_test.csv';
X_train_base = 'X_train.csv';
Y_train_base = 'Y_train.csv';
X_test_base = 'X_test.csv';
Y_test_base = 'gt_test.csv';
R = 7;
K = 3;
pred_all = cell(50,1);
betas = cell(50,1);
yests = cell(50,1);
%%
for i = 1:50
    fprintf('Iteration %d\n', i);
    % Construct file names
    X_train_name = fullfile(base_path, [num2str(i), X_train_base]);
    Y_train_name = fullfile(base_path, [num2str(i), Y_train_base]);
    X_test_name = fullfile(base_path, [num2str(i), X_test_base]);
    Y_test_name = fullfile(base_path, [num2str(i), Y_test_base]);

    X = csvread(X_train_name);
    Y = csvread(Y_train_name);
    y = csvread(Y_test_name);
    Xte = csvread(X_test_name);

    % configurate de GP model for classification
    Ncg = 300; cov = {@covSEard}; sf = 1; ell = 0.7*ones(1, size(X,2));  
    hyp0.cov  = log([ell,sf]); mean1 = {@meanZero}; hyp0.mean = [];
    lik = 'likLogistic';  sn = 0.2; hyp0.lik = [];
    inf = 'infLaplace';
    for r = 1:R
        auxY = Y(:,r);
        auxY1 = auxY;
        auxY2 = auxY;
        auxY3 = auxY;
    
        auxY1(auxY1 == 1) = 1;
        auxY1(auxY1 == 2) = -1;
        auxY1(auxY1 == 3) = -1;
        auxY2(auxY2 == 1) = -1;
        auxY2(auxY2 == 2) = 1;
        auxY2(auxY2 == 3) = -1;
        auxY3(auxY3 == 1) = -1;
        auxY3(auxY3 == 2) = -1;
        auxY3(auxY3 == 3) = 1;
    
        hyp1 = minimize(hyp0,'gp', -Ncg, inf, mean1, cov, lik, X, auxY1);
        [~, ~, ~, ~, aux1] = gp(hyp1, inf, mean1, cov, lik, X,...
                            auxY1, Xte, ones(size(Xte,1), 1));
        hyp2 = minimize(hyp0,'gp', -Ncg, inf, mean1, cov, lik, X, auxY2);
        [~, ~, ~, ~, aux2] = gp(hyp2, inf, mean1, cov, lik, X,...
                            auxY2, Xte, ones(size(Xte,1), 1));
        hyp3 = minimize(hyp0,'gp', -Ncg, inf, mean1, cov, lik, X, auxY3);
        [~, ~, ~, ~, aux3] = gp(hyp3, inf, mean1, cov, lik, X,...
                            auxY3, Xte, ones(size(Xte,1), 1));
        yest(:,:,r) = [exp(aux1), exp(aux2), exp(aux3)];
    
    end
    % Solution using LKAAR
    Xaux = X;
    beta = LKAAR(Xaux, Y);
    beta = (beta).^2; 
    beta = beta./repmat(sum(beta,2),1,R);
    disK = exp(-dist2(Xaux, Xte));
    Nte = size(Xte,1);
    muvec = zeros(Nte, K, R);
    muvec1 = zeros(Nte, K, R);
    for r = 1:R
       aux = (sum(disK.*repmat(beta(:,r),1,Nte))./sum(disK))'; 
       data = [Xte(:,1), Xte(:,2), aux]; 
       muvec(:,:,r) = repmat(aux, 1, K);
    end
    
    aux1 = yest.*muvec;
    aux1 = sum(aux1,3);
    [~, pred] = max(aux1, [], 2);

    pred_all{i} = mean(pred==y);
end

% Define the folder paths
results_folder = fullfile(script_directory, 'results');

% Create the results folder if it doesn't exist
if ~exist(results_folder, 'dir')
    mkdir(results_folder);
end


% Save the prediction results
save(fullfile(results_folder, 'pred_real_data_LKAAR.mat'), 'pred_all');
accuracy_matrix = cell2mat(pred_all);

% Save the accuracy matrix in a CSV file
mean_accuracy = mean(accuracy_matrix);
std_accuracy = std(accuracy_matrix);
results_table = table(mean_accuracy, std_accuracy, 'VariableNames', {'accuracy', 'StandardDeviation'});


% Save as CSV file with headers
writetable(results_table, 'table6_LKAAR.csv');



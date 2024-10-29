using DataFrames
include("logreg_crowds.jl")
include("logistic_regression.jl")

using LogisticRegression
using LogisticRegressionCrowds

data_dir = "data/50_real_data_split"
output_dir = "results"

# Ensure the output directory exists
mkpath(output_dir)

# List all files in the directory
files = readdir(data_dir)

# Filter and sort the files
X_train_files = sort(filter(f -> endswith(f, "X_train.csv"), files))
X_test_files = sort(filter(f -> endswith(f, "X_test.csv"), files))
Y_train_files = sort(filter(f -> endswith(f, "Y_train.csv"), files))
ground_truth_train_files = sort(filter(f -> endswith(f, "gt_train.csv"), files))
ground_truth_test_files = sort(filter(f -> endswith(f, "gt_test.csv"), files))

println("Number of files (X_train): ", length(X_train_files))

# Initialize a DataFrame to store the results
n_rows = 50

# Initialize columns with 50 placeholder values
file_column = fill("", n_rows)                # 50 empty strings
acc_raykar_column = fill(0.0, n_rows)         # 50 zeros
acc_rodrigues_column = fill(0.0, n_rows)      # 50 zeros
acc_dawidskene_column = fill(0.0, n_rows)     # 50 zeros

# Create the DataFrame with these columns
results = DataFrame(File = file_column, 
                    Accuracy_raykar = acc_raykar_column, 
                    Accuracy_rodrigues = acc_rodrigues_column, 
                    Accuracy_dawidskene = acc_dawidskene_column)


println("Start")

# Simulation
for i = 1:50
	# Read the csv files
    X_train_i = joinpath(data_dir, X_train_files[i])
    X_test_i = joinpath(data_dir, X_test_files[i])
    Y_train_i = joinpath(data_dir, Y_train_files[i])
    gt_train_i = joinpath(data_dir, ground_truth_train_files[i])
    gt_test_i = joinpath(data_dir, ground_truth_test_files[i])

    X = readdlm(X_train_i, ',')
    X_test = readdlm(X_test_i, ',')
    Y = readdlm(Y_train_i, ',')
    y = readdlm(gt_test_i, ',')
    y_train = readdlm(gt_train_i, ',')

	# Train the model
	w_raykar, est_annotators_acc, est_groundtruth, est_groundtruth_probs = LogisticRegressionCrowds.learn(X, Y, method="raykar", w_prior=1.0, pi_prior=0.01, groundtruth =y_train, max_em_iters=100)
	w_rodrigues, est_annotators_acc, est_groundtruth, est_groundtruth_probs = LogisticRegressionCrowds.learn(X, Y, method="rodrigues", w_prior=1.0, pi_prior=0.01, groundtruth =y_train, max_em_iters=100)
	w_dawidskene, est_annotators_acc, est_groundtruth, est_groundtruth_probs = LogisticRegressionCrowds.learn(X, Y, method="dawidskene", w_prior=1.0, pi_prior=0.01, max_em_iters=100)
	#w, est_annotators_acc, est_groundtruth, est_groundtruth_probs = LogisticRegressionCrowds.learn(X, Y, method="majvote", w_prior=1.0, pi_prior=0.01, groundtruth=y)
	#w, est_annotators_acc, est_groundtruth, est_groundtruth_probs = LogisticRegressionCrowds.learn(X, Y, method="naive", w_prior=1.0, pi_prior=0.01, groundtruth=y)


    # Make prediction on test set
	predictions_raykar, predictive_probabilities = predict(X_test, w_raykar)
	acc_raykar = accuracy(predictions_raykar, y)

	predictions_rodrigues, predictive_probabilities = predict(X_test, w_rodrigues)
	acc_rodrigues = accuracy(predictions_rodrigues, y)

	predictions_dawidskene, predictive_probabilities = predict(X_test, w_dawidskene)
	acc_dawidskene = accuracy(predictions_dawidskene, y)

	# Append the result to the DataFrame
	results[i, :File] = X_train_files[i]
	results[i, :Accuracy_raykar] = acc_raykar
	results[i, :Accuracy_rodrigues] = acc_rodrigues
	results[i, :Accuracy_dawidskene] = acc_dawidskene

end

println("Save the results")
# Save the results

function save_to_csv(df::DataFrame, filename::String)
    open(filename, "w") do file
        # Write the header
        println(file, join(names(df), ","))
        # Write each row
        for row in eachrow(df)
            println(file, join(row, ","))
        end
    end
end

output_file = joinpath(output_dir, "pred_real_data_julia.csv")

save_to_csv(results, output_file)

println("End")

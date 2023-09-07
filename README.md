# density-based-ensemble-model

Supervised learning entails training a model with labeled data to predict outcomes for new, unlabeled data. It is assumed that the label in the training set corresponds to the ground truth. However, precise ground truth labels are challenging to obtain due to resource limitations, complex data, and ambiguity. This suggests that errors, commonly referred to as noise, are present in the labels used during the training phase of the model.

Here is proposed a density based ensemble approach to deal with multiple set of noisy labels. The ensemble model is constructed by combining various base learners, which are models trained using a single set of noisy labels. In particular, Gaussian Mixture Models (GMMs) are employed as base learners. For the purpose of combining the GMMs, different weighted averaging methodologies pursued directly on the estimated parameters of the GMMs are proposed.




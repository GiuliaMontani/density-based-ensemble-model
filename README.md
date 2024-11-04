Supplementary information / reproducible research files for the manuscript Title:

"Stacking model-based classifiers for dealing with multiple sets of noisy labels"\
\
Authors: Giulia Montani, Andrea Cappozzo

In case of questions or comments please contact: giuliamontani.gm\@gmail.com or andrea.cappozzo@unimi.it

## System Information

-   **Platform**: x86_64-w64-mingw32/x64 (64-bit)
-   **Running under**: Windows 10 x64 (build 22631)

### Requirements to run R scripts

-   **R version**: 4.2.2 (2022-10-31 ucrt)

Navigate to the main directory of the project and run:

``` bash
Rscript ./utils/install_packages.R
```

The code for the implemented density based ensemble model are all written in R.

### Requirements to run Pyhton scripts

-   **Python version**: 3.11

Navigate to the main directory of the project and run:

``` bash
pip install numpy matplotlib
```

The pyhton scripts is used only to visualize the example of a Dirichlet distribution on a two dimensional simplex.

### Requirements to run Matlab script

-   **Matlab version**: R2022a

Navigate to the main directory of the project and clone:

LKAAR repository, contains competing model LKAAR (TODO: citare il paper?)

``` bash
git clone https://github.com/juliangilg/LKAAR.git
```

The entire code is written in Matlab, which uses the library netlab

``` bash
git clone https://github.com/sods/netlab.git
```

The classification stage is based on Gaussian processes by using the GPML software, download available at: <http://www.gaussianprocess.org/gpml/code/matlab/doc/>. Save the folder as default 'gpml-matlab-master'.

It is important to clone and download at the same level where there is the matlab script LKAAR_experiments.m

### Requirements to run Julia scripts

-   **Julia version**: 0.3.12 

Original implementation available in the repository [https://github.com/fmpr/LogReg-Crowds](https://github.com/fmpr/LogReg-Crowds)

## Results
All the script can be executed following the instruction below. 
The results are saved inside the folder "results". 
All the figure in the manuscript are .png files, they start with "{figure_number}figure".
All the numerical results reported in the manuscript tables are .csv files, they start with "{table_number}table".

## Simulation

Open your terminal, navigate to the main directory of your project, and execute the following command:

-   Simulation of scenario 1

``` bash
$argument=1

Rscript "Simulation.R" "$argument"
```

-   Simulation of scenario 2

``` bash
$argument=2

Rscript "Simulation.R" "$argument"
```

-   Competing models

## Real data application

Input data are available inside the folder data.

Open your terminal, navigate to the main directory of your project, and execute the following command:

-   Real data experiments

``` bash
Rscript real_data.R
```

-   Competing models

LKAAR method 

``` bash
matlab -nodisplay -nosplash -r "run('competitors_real_data/LKAAR_experiment.m'); exit;"
```

Dawid and Skene, Raykar and Rodrigues methods (all implemented in Julia within the [LogReg-Crowds](https://github.com/fmpr/LogReg-Crowds) Julia package)

``` bash
/path/to/julia-0.3.12/bin/julia Julia_accuracy_application.jl
```

Replace `/path/to/julia-0.3.12/` with the full path to your Julia binary.

To collect results and reproduce the last row of Table 6

``` bash
Rscript competitors_analysis.R
```

## Other material

Figure 3 is a visual example of a Dirichlet distribution on a two dimensional simplex.

Open your terminal, navigate to the main directory of your project, and execute the following command:

``` bash
py utils/figure3.py
```


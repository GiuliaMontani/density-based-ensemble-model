Supplementary information / reproducible research files for the manuscript Title:

"Stacking model-based classifiers for dealing with multiple sets of noisy labels"\
\
Authors: Giulia Montani, Andrea Cappozzo

In case of questions or comments please contact: giuliamontani.gm\@gmail.com or xxx

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

### Requiremnets to run Matlab script

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

The classification stage is based on Gaussian processes by using the GPML software, download available at: <http://www.gaussianprocess.org/gpml/code/matlab/doc/>.

It is important to clone and download at the same level where there is the matlab script LKAAR_experiments.m

### Requiremnets to run Julia scripts

## Simulation

Open your terminal, navigate to the main directory of your project, and execute the following command:

-   Simulation of scenario 1

``` bash
Rscript Simulation.R .\config\config_simulation1.yaml
```

-   Simulation of scenario 2

``` bash
Rscript Simulation.R .\config\config_simulation2.yaml
```

Inside the folder results are saved figure2, figure 4 to 6.

Inside the folder results/1simulation and results/2simulation are saved csv files with numerical results presented in the manuscript in table 4.

-   Competing models

## Real data application

Input data are available inside the folder data.

Open your terminal, navigate to the main directory of your project, and execute the following command:

-   Real data experiments

``` bash
Rscript real_data.R
```

Inside the folder results are saved figure 7, figure 8 and figure 2b (appendix figure).

Inside the folder results/real_data are saved csv files with numerical results presented in the manuscript in table 6 and table 7.

-   Competing models

## Other material

Figure 3 is a visual example of a Dirichlet distribution on a two dimensional simplex.

Open your terminal, navigate to the main directory of your project, and execute the following command:

``` bash
py utils/figure3.py
```

Inside the folder results figure 3 is saved.

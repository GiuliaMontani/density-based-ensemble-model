Supplementary information / reproducible research files for the manuscript:

"Stacking model-based classifiers for dealing with multiple sets of noisy labels"\
\
Authors: Giulia Montani, Andrea Cappozzo

In case of questions or comments please contact: giuliamontani.gm\@gmail.com or andrea.cappozzo@unimi.it

## System Information

-   **Platform**: x86_64-w64-mingw32/x64 (64-bit)
-   **Running under**: Windows 10 x64 (build 22631)

### Requirements to run R scripts

-   **R version**: 4.3.3 (2024-02-29)

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

The pyhton scripts are used only to visualize the example of a Dirichlet distribution on a two dimensional simplex.

### Requirements to run Matlab script

-   **Matlab version**: R2024a

Original implementation available in the repository [https://github.com/juliangilg/LKAAR](https://github.com/juliangilg/LKAAR)

**Important note:** MATLAB requires a paid license to run. Additionally, the library software has been used “as-is,” without any modifications or customizations.

### Requirements to run Julia scripts

-   **Julia version**: 0.3.12 

Navigate to the main directory of the project and run:

``` bash
/path/to/julia-0.3.12/bin/julia utils/install_julia_packages.jl 
```
Replace `/path/to/julia-0.3.12/` with the full path to your Julia binary.

Original implementation available in the repository [https://github.com/fmpr/LogReg-Crowds](https://github.com/fmpr/LogReg-Crowds).

**Important Note:** Julia code depends on an outdated and no longer maintained version of Julia, which may cause installation challenges or failures. Additionally, it relies on external library software that has been used “as-is,” without any modifications or customizations.

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

Dawid and Skene, Raykar and Rodrigues methods (all implemented in Julia within the [LogReg-Crowds](https://github.com/fmpr/LogReg-Crowds) Julia package)

``` bash
/path/to/julia-0.3.12/bin/julia Julia_accuracy_sim_1.jl
/path/to/julia-0.3.12/bin/julia Julia_accuracy_sim_2.jl
```

Replace `/path/to/julia-0.3.12/` with the full path to your Julia binary.

To collect results and reproduce Table 5

``` bash
Rscript competitors_analysis.R
```

## Real data application

Input data are available inside the folder data.

Open your terminal, navigate to the main directory of your project, and execute the following command:

-   Real data experiments

``` bash
Rscript real_data.R
```

-   Competing models

LKAAR method (implemented in Matlab within the [https://github.com/juliangilg/LKAAR](https://github.com/juliangilg/LKAAR) repository)

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
python utils/figure3.py
```

**R Session Info**

``` r
sessioninfo::session_info()
#> ─ Session info ───────────────────────────────────────────────────────────────
#>  setting  value
#>  version  R version 4.3.3 (2024-02-29)
#>  os       macOS 15.1.1
#>  system   aarch64, darwin20
#>  ui       X11
#>  language (EN)
#>  collate  en_US.UTF-8
#>  ctype    en_US.UTF-8
#>  tz       Europe/Rome
#>  date     2024-12-30
#>  pandoc   3.2 @ /Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64/ (via rmarkdown)
#> 
#> ─ Packages ───────────────────────────────────────────────────────────────────
#>  package       * version    date (UTC) lib source
#>  caret         * 6.0-94     2023-03-21 [1] CRAN (R 4.3.0)
#>  cellranger      1.1.0      2016-07-27 [1] CRAN (R 4.3.0)
#>  class           7.3-22     2023-05-03 [1] CRAN (R 4.3.3)
#>  cli             3.6.3      2024-06-21 [1] CRAN (R 4.3.3)
#>  codetools       0.2-20     2024-03-31 [1] CRAN (R 4.3.1)
#>  colorspace      2.1-1      2024-07-26 [1] CRAN (R 4.3.3)
#>  data.table      1.16.0     2024-08-27 [1] CRAN (R 4.3.3)
#>  digest          0.6.37     2024-08-19 [1] CRAN (R 4.3.3)
#>  DirichletReg  * 0.7-1      2021-05-18 [1] CRAN (R 4.3.0)
#>  dplyr         * 1.1.4      2023-11-17 [1] CRAN (R 4.3.1)
#>  evaluate        0.24.0     2024-06-10 [1] CRAN (R 4.3.3)
#>  fansi           1.0.6      2023-12-08 [1] CRAN (R 4.3.1)
#>  fastmap         1.2.0      2024-05-15 [1] CRAN (R 4.3.3)
#>  foreach         1.5.2      2022-02-02 [1] CRAN (R 4.3.0)
#>  Formula       * 1.2-5      2023-02-24 [1] CRAN (R 4.3.0)
#>  fs              1.6.4      2024-04-25 [1] CRAN (R 4.3.3)
#>  furrr           0.3.1      2022-08-15 [1] CRAN (R 4.3.0)
#>  future          1.34.0     2024-07-29 [1] CRAN (R 4.3.3)
#>  future.apply    1.11.2     2024-03-28 [1] CRAN (R 4.3.1)
#>  generics        0.1.3      2022-07-05 [1] CRAN (R 4.3.0)
#>  GGally        * 2.2.1      2024-02-14 [1] CRAN (R 4.3.1)
#>  ggplot2       * 3.5.1      2024-04-23 [1] CRAN (R 4.3.1)
#>  ggstats         0.6.0      2024-04-05 [1] CRAN (R 4.3.1)
#>  globals         0.16.3     2024-03-08 [1] CRAN (R 4.3.1)
#>  glue            1.8.0      2024-09-30 [1] CRAN (R 4.3.3)
#>  gower           1.0.1      2022-12-22 [1] CRAN (R 4.3.0)
#>  gridExtra     * 2.3        2017-09-09 [1] CRAN (R 4.3.0)
#>  gtable          0.3.5      2024-04-22 [1] CRAN (R 4.3.1)
#>  gtools        * 3.9.5      2023-11-20 [1] CRAN (R 4.3.1)
#>  hardhat         1.3.1      2024-02-02 [1] CRAN (R 4.3.1)
#>  htmltools       0.5.8.1    2024-04-04 [1] CRAN (R 4.3.3)
#>  ipred           0.9-15     2024-07-18 [1] CRAN (R 4.3.3)
#>  iterators       1.0.14     2022-02-05 [1] CRAN (R 4.3.0)
#>  knitr           1.48       2024-07-07 [1] CRAN (R 4.3.3)
#>  LaplacesDemon * 16.1.6     2021-07-09 [1] CRAN (R 4.3.0)
#>  lattice       * 0.22-6     2024-03-20 [1] CRAN (R 4.3.1)
#>  lava            1.8.0      2024-03-05 [1] CRAN (R 4.3.1)
#>  lifecycle       1.0.4      2023-11-07 [1] CRAN (R 4.3.1)
#>  listenv         0.9.1      2024-01-29 [1] CRAN (R 4.3.1)
#>  lubridate       1.9.3      2023-09-27 [1] CRAN (R 4.3.1)
#>  magrittr        2.0.3      2022-03-30 [1] CRAN (R 4.3.0)
#>  MASS            7.3-60.0.1 2024-01-13 [1] CRAN (R 4.3.3)
#>  Matrix          1.6-5      2024-01-11 [1] CRAN (R 4.3.3)
#>  maxLik          1.5-2.1    2024-03-24 [1] CRAN (R 4.3.1)
#>  mclust        * 6.1.1      2024-04-29 [1] CRAN (R 4.3.1)
#>  miscTools       0.6-28     2023-05-03 [1] CRAN (R 4.3.0)
#>  ModelMetrics    1.2.2.2    2020-03-17 [1] CRAN (R 4.3.0)
#>  munsell         0.5.1      2024-04-01 [1] CRAN (R 4.3.1)
#>  mvtnorm       * 1.2-6      2024-08-17 [1] CRAN (R 4.3.3)
#>  nlme            3.1-166    2024-08-14 [1] CRAN (R 4.3.3)
#>  nnet            7.3-19     2023-05-03 [1] CRAN (R 4.3.0)
#>  parallelly      1.38.0     2024-07-27 [1] CRAN (R 4.3.3)
#>  patchwork     * 1.2.0      2024-01-08 [1] CRAN (R 4.3.1)
#>  pillar          1.9.0      2023-03-22 [1] CRAN (R 4.3.0)
#>  pkgconfig       2.0.3      2019-09-22 [1] CRAN (R 4.3.0)
#>  plyr            1.8.9      2023-10-02 [1] CRAN (R 4.3.1)
#>  pROC            1.18.5     2023-11-01 [1] CRAN (R 4.3.1)
#>  prodlim         2024.06.25 2024-06-24 [1] CRAN (R 4.3.3)
#>  purrr           1.0.2      2023-08-10 [1] CRAN (R 4.3.0)
#>  R6              2.5.1      2021-08-19 [1] CRAN (R 4.3.0)
#>  RColorBrewer    1.1-3      2022-04-03 [1] CRAN (R 4.3.0)
#>  Rcpp            1.0.13     2024-07-17 [1] CRAN (R 4.3.3)
#>  readxl        * 1.4.3      2023-07-06 [1] CRAN (R 4.3.0)
#>  recipes         1.0.10     2024-02-18 [1] CRAN (R 4.3.1)
#>  reprex          2.1.1      2024-07-06 [1] CRAN (R 4.3.3)
#>  reshape2      * 1.4.4      2020-04-09 [1] CRAN (R 4.3.0)
#>  rlang           1.1.4      2024-06-04 [1] CRAN (R 4.3.3)
#>  rmarkdown       2.28       2024-08-17 [1] CRAN (R 4.3.3)
#>  rpart           4.1.23     2023-12-05 [1] CRAN (R 4.3.3)
#>  rsample       * 1.2.1      2024-03-25 [1] CRAN (R 4.3.1)
#>  rstudioapi      0.16.0     2024-03-24 [1] CRAN (R 4.3.1)
#>  sandwich        3.1-0      2023-12-11 [1] CRAN (R 4.3.1)
#>  scales          1.3.0      2023-11-28 [1] CRAN (R 4.3.1)
#>  sessioninfo   * 1.2.2      2021-12-06 [1] CRAN (R 4.3.0)
#>  stringi         1.8.4      2024-05-06 [1] CRAN (R 4.3.1)
#>  stringr         1.5.1      2023-11-14 [1] CRAN (R 4.3.1)
#>  survival        3.7-0      2024-06-05 [1] CRAN (R 4.3.3)
#>  tibble          3.2.1      2023-03-20 [1] CRAN (R 4.3.0)
#>  tidyr           1.3.1      2024-01-24 [1] CRAN (R 4.3.1)
#>  tidyselect      1.2.1      2024-03-11 [1] CRAN (R 4.3.1)
#>  timechange      0.3.0      2024-01-18 [1] CRAN (R 4.3.1)
#>  timeDate        4032.109   2023-12-14 [1] CRAN (R 4.3.1)
#>  utf8            1.2.4      2023-10-22 [1] CRAN (R 4.3.1)
#>  vctrs           0.6.5      2023-12-01 [1] CRAN (R 4.3.1)
#>  withr           3.0.1      2024-07-31 [1] CRAN (R 4.3.3)
#>  xfun            0.47       2024-08-17 [1] CRAN (R 4.3.3)
#>  yaml            2.3.10     2024-07-26 [1] CRAN (R 4.3.3)
#>  zoo             1.8-12     2023-04-13 [1] CRAN (R 4.3.0)
#> 
#>  [1] /Library/Frameworks/R.framework/Versions/4.3-arm64/Resources/library
#> 
#> ──────────────────────────────────────────────────────────────────────────────
```

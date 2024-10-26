# Read the requirements file
packages <- readLines("requirements_R.txt")

# Install the packages if they are not already installed
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

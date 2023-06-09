# Start from a Python 3.8 image
FROM python:3.8-slim

# Upgrade pip to the latest version
RUN pip install -U pip

# Update the package lists for upgrades for packages and security updates
# Install R, Graphviz and its development libraries
RUN apt-get update && apt-get install -y r-base graphviz graphviz-dev
RUN rm -rf /var/lib/apt/lists/*

# Create a directory for the worker
RUN mkdir -p /neurogenpy/neurogenpy_http

# Copy the requirements file for the worker into the Docker image
COPY ./neurogenpy_http/requirements-worker.txt /neurogenpy/neurogenpy_http/requirements-worker.txt

# Install the Python dependencies for the worker
RUN pip install -r /neurogenpy/neurogenpy_http/requirements-worker.txt

# Install the R packages 'bnlearn' and 'sparsebn' required for neurogenpy
RUN Rscript -e "install.packages('bnlearn');"
RUN Rscript -e "install.packages('sparsebn', repos='https://mran.microsoft.com/snapshot/2020-09-13')"

# Set the working directory to /neurogenpy
WORKDIR /neurogenpy

# Install the neurogenpy package from the master branch of the GitHub repository
RUN pip install git+https://github.com/AlaiaB/neurogenpy.git@master

# Change to a non-root user for security
USER nobody

# Set the command that will be run when the Docker container is started
ENTRYPOINT celery -A neurogenpy_http.scheduling.worker.app worker -l INFO

# Start from a Node.js 16 image
FROM node:16-alpine as builder

# Copy the viewer plugin code into the Docker image
COPY ./neurogenpy_viewerplugin /neurogenpy_viewerplugin

# Set the working directory to the viewer plugin directory
WORKDIR /neurogenpy_viewerplugin

# Create the directory for the build output
RUN mkdir -p public/build

# Install the Node.js dependencies
RUN npm i

# Build the viewer plugin
RUN npm run build

# Start a new build stage from a Python 3.8 image
FROM python:3.8-alpine

# Upgrade pip to the latest version
RUN pip install -U pip

# Create a directory for your application
RUN mkdir -p /neurogenpy

# Copy the requirements file for the server into the Docker image
COPY ./neurogenpy_http/requirements-server.txt /neurogenpy/requirements-server.txt

# Install the Python dependencies for the server
RUN pip install -r /neurogenpy/requirements-server.txt

# Copy the server code into the Docker image
COPY ./neurogenpy_http /neurogenpy/neurogenpy_http

# Set the working directory to /neurogenpy
WORKDIR /neurogenpy/

# Copy the built viewer plugin from the builder stage into the Docker image
COPY --from=builder /neurogenpy_viewerplugin/public /neurogenpy/neurogenpy_http/public

# Set an environment variable for the static directory
ENV NEUROGENPY_STATIC_DIR=/neurogenpy/neurogenpy_http/public

# Change to a non-root user for security
USER nobody

# Expose port 6001 for the application
EXPOSE 6001

# Set the command that will be run when the Docker container is started
ENTRYPOINT uvicorn neurogenpy_http.main:app --port 6001 --host 0.0.0.0
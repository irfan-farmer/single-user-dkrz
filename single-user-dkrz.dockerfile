# Use a base image from quay.io for Jupyter with Python
FROM quay.io/jupyter/base-notebook:latest

LABEL org.opencontainers.image.authors="khan@dkrz.de"

# Install mamba into the base environment
USER root
RUN pip install mamba

# Switch back to the jovyan user (the default user in the base image)
USER ${NB_UID}

# Create a new conda environment with mamba
RUN mamba create -n myenv python=3.10 --yes

# Activate the environment and install the necessary packages
RUN /bin/bash -c "source activate myenv && \
    mamba install -c conda-forge numpy pandas xarray intake intake_esm ipywidgets geopy folium hvplot fsspec zarr rooki --yes"

# Install the JupyterLab extension for widgets
RUN /bin/bash -c "source activate myenv && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager"

# Copy example notebooks into the container
COPY ./notebooks /home/jovyan/work/

# Set the environment to use the newly created environment
ENV PATH /opt/conda/envs/myenv/bin:$PATH

# Expose the default JupyterLab port
EXPOSE 8888

# Set the command to start JupyterLab when the container starts
CMD ["start-notebook.sh"]

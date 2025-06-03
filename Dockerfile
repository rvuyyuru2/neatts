# Use an official NVIDIA base image with CUDA support
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

# Set label for the docker image description
LABEL description="Docker image for Instavoice"


# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libsndfile1 \
    ffmpeg \
    python3 \
    make\
    g++ \
    python3-pip \
    python3-dev \
    git \
    pkg-config \
    protobuf-compiler \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m appuser
USER appuser

# Set up working directory
WORKDIR /app
ENV CUDA_LAUNCH_BLOCKING=1

# Copy requirements first to leverage Docker cache
COPY --chown=appuser:appuser requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY --chown=appuser:appuser . .

# Create required directories for the application
RUN mkdir -p model_cache reference_audio outputs voices logs && \
    chown -R appuser:appuser model_cache reference_audio outputs voices logs

# Expose the port the application will run on (default from config, e.g., 8004)
EXPOSE 8004

# Command to run the application
CMD ["python3", "server.py"]
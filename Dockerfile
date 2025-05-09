# # builder
# FROM python:3.10-slim-bullseye AS builder
# WORKDIR /app
# COPY requirements-trainer.txt .
# RUN apt-get update \
#     && apt-get install -y git \
#     && pip install --no-cache-dir -r requirements-trainer.txt

# # final
# FROM python:3.10-slim-bullseye
# WORKDIR /app
# COPY --from=builder /usr/local/lib/python3.10/site-packages/ /usr/local/lib/python3.10/site-packages/
# COPY train_dpo.py .

# ENV PORT=8080
# ENTRYPOINT ["python", "train_dpo.py"]


# Stage 1: install deps
FROM python:3.10-slim-bullseye AS builder
WORKDIR /app

# system dependencies
RUN apt-get update && apt-get install -y git build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python deps
COPY requirements-trainer.txt .
RUN pip install --no-cache-dir --extra-index-url https://download.pytorch.org/whl/cu124 \
    -r requirements-trainer.txt

# Stage 2: assemble final image
FROM python:3.10-slim-bullseye
WORKDIR /app

# Copy installed packages
COPY --from=builder /usr/local/lib/python3.10/site-packages/ /usr/local/lib/python3.10/site-packages/

# Copy your training script
COPY train_dpo.py .

# Entrypoint: run your training script
ENTRYPOINT ["python", "train_dpo.py"]
ENV PORT=8080

# Use Python 3.10.15-slim as the base image
FROM python:3.10.15-slim

# Set environment variables to prevent Python from buffering outputs
ENV PYTHONUNBUFFERED=1 \
    POETRY_HOME=/opt/poetry \
    PATH="/opt/poetry/bin:$PATH" \
    POETRY_VIRTUALENVS_CREATE=false \
    PYTHONPATH=/app

# Install system dependencies required for Poetry and FastAPI
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    build-essential \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 - && \
    chmod +x $POETRY_HOME/bin/poetry

# Set the working directory
WORKDIR /app

# Copy Poetry files
COPY poetry.lock pyproject.toml /app/

# Install project dependencies
RUN poetry install --no-root --no-interaction --no-ansi

# Copy the rest of the application code
COPY . /app/

# Expose the FastAPI application port
EXPOSE 8080

# Start the FastAPI app using uvicorn
CMD ["poetry", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]

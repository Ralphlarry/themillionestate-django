# Use official Python slim image
FROM python:3.10-slim

# Set environment variables properly
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Create working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    libpq-dev \
    libjpeg-dev \
    zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements first to leverage Docker cache
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Copy project files with proper ownership
COPY --chown=1001:0 . .

# Create necessary directories
RUN mkdir -p /app/staticfiles /app/mediafiles

# Collect static files (uncomment when ready)
# RUN python manage.py collectstatic --noinput

# Use non-root user
USER 1001

EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "themillionestate.wsgi:application"]

# Use Python version that matches your runtime.txt (adjust if needed)
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Create and set working directory
RUN mkdir /millionestate
WORKDIR /millionestate

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    libpq-dev \
    libjpeg-dev \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy entire project (adjust according to your actual structure)
# Copy project files with proper ownership
COPY --chown=1001:0 . .

# Special handling for different components (adjust as needed)
RUN mkdir -p /millionestate/staticfiles \
    /millionestate/mediafiles

# Collect static files (enable if needed)
# RUN python manage.py collectstatic --noinput

# Expose port
EXPOSE 8000

# Start server (verify WSGI module location)
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "themillionestate.wsgi:application"]

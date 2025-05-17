# syntax=docker/dockerfile:1.4
FROM python:3.10-slim as builder

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

FROM python:3.10-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY --chown=1001:0 . .

ENV PATH=/root/.local/bin:$PATH \
    PYTHONUNBUFFERED=1

USER 1001
EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "themillionestate.wsgi:application"]

FROM python:3.9-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --target=/opt/python-packages -r requirements.txt

COPY . .

# -----------------------
FROM python:3.9-slim
WORKDIR /app

ENV FLASK_ENV=production
ENV PATH="/opt/python-packages/bin:${PATH}"
ENV PYTHONPATH=/opt/python-packages

COPY --from=builder /opt/python-packages /opt/python-packages
COPY . .

RUN useradd -m appuser && \
    mkdir -p static/uploads && \
    chown -R appuser:appuser .

USER appuser

EXPOSE 5000

# Gunicorn: everything to stdout
CMD ["gunicorn", "app:app", "-w", "4", "-b", "0.0.0.0:5000", "--access-logfile", "-", "--error-logfile", "-", "--log-level", "info"]

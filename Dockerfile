# ----------------------------------------------------------
# Dockerfile
# Cloud-Native Order Tracking Platform
# ----------------------------------------------------------

FROM python:3.11-slim

WORKDIR /app

COPY app/backend/requirements.txt .

RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

COPY app/backend .

ENV FLASK_HOST=0.0.0.0
ENV PORT=5000

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
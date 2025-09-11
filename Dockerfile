FROM python:3.11-slim
WORKDIR /app
COPY app/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt
COPY app /app
EXPOSE 8080
ENV COLOR=#0ea5e9 REGION=blue VERSION=v1.1.0
CMD ["gunicorn", "-w", "2", "-k", "gthread", "--threads", "4", "-b", "0.0.0.0:8080", "app:app"]

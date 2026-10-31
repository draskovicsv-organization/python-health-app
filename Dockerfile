# ---- Stage 1: build dependencies ----
FROM python:3.12-slim-bookworm AS builder
WORKDIR /build
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ---- Stage 2: runtime image ----
FROM python:3.12-slim-bookworm
RUN useradd --create-home --uid 10001 appuser
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1
WORKDIR /app
COPY app.py .
USER appuser
EXPOSE 8080
CMD ["gunicorn", "--bind", "127.0.0.1:8080", "app:app"]
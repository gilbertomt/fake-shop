FROM python:3.12.11-alpine3.22
RUN adduser -D appuser
WORKDIR /app
RUN apk add --no-cache gcc musl-dev postgresql-dev libffi-dev bash curl
COPY --chown=appuser:appuser src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY --chown=appuser:appuser src/ .
RUN chmod +x /app/entrypoint.sh
RUN mkdir -p /tmp/metrics && chown appuser:appuser /tmp/metrics
EXPOSE 5000
USER appuser
CMD ["/app/entrypoint.sh"]
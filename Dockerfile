FROM python:3.12-slim AS builder

WORKDIR /app

COPY app/requirements.txt .
RUN pip install --upgrade pip \
    && pip install --prefix=/opt/app -r requirements.txt


FROM python:3.12-slim

WORKDIR /app

COPY --from=builder /opt/app /opt/app
COPY app/ /app/

ENV PATH="/opt/app/bin:$PATH"

EXPOSE 8080

CMD ["/opt/app/bin/gunicorn", "--bind", "0.0.0.0:8080", "src.main:app", "-k", "uvicorn.workers.UvicornWorker"]

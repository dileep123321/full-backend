from fastapi import FastAPI
import os

app = FastAPI()

CONFIG_PATH = os.getenv("APP_CONFIG_FILE", "/vault/secrets/config")


def load_config():
    cfg = {}
    try:
        with open(CONFIG_PATH, "r") as f:
            for line in f:
                line = line.strip()
                if not line or "=" not in line:
                    continue
                k, v = line.split("=", 1)
                cfg[k] = v
    except Exception:
        pass
    return cfg


@app.get("/healthz")
def healthz():
    return {"status": "ok"}


@app.get("/ready")
def ready():
    cfg = load_config()
    # Basic readiness: require DB_USER present
    return {"status": "ready" if "DB_USER" in cfg else "not-ready"}


@app.get("/config")
def config():
    return load_config()

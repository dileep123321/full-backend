from fastapi import FastAPI
import os

app = FastAPI()

# Vault-injected secret file created by vault-agent
CONFIG_PATH = os.getenv("APP_CONFIG_FILE", "/vault/secrets/config")


def load_config():
    """Load secrets from Vault secret file."""
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


@app.get("/")
def root():
    return {"message": "Backend is running successfully"}


@app.get("/healthz")
def healthz():
    """Liveness probe — app is running"""
    return {"status": "ok"}


@app.get("/ready")
def ready():
    """Readiness probe — only ready if Vault secrets are loaded"""
    cfg = load_config()
    return {
        "status": "ready" if "DB_USER" in cfg else "not-ready",
        "config_loaded": "DB_USER" in cfg
    }


@app.get("/config")
def config():
    """Debug endpoint: return loaded Vault secrets"""
    return load_config()


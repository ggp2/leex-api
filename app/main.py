import os

from flask import Flask, jsonify


def create_app() -> Flask:
    """Créer et configurer l'application Flask."""
    app = Flask(__name__)

    @app.get("/health")
    def health():
        return jsonify({"status": "ok"}), 200

    @app.get("/items")
    def items():
        return jsonify(
            {
                "items": [
                    {"id": 1, "name": "GitLab CI"},
                    {"id": 2, "name": "GitHub Actions"},
                ]
            }
        ), 200

    return app


app = create_app()


if __name__ == "__main__":
    host = os.getenv("APP_HOST", "127.0.0.1")
    port = int(os.getenv("APP_PORT", "8000"))
    app.run(host=host, port=port)

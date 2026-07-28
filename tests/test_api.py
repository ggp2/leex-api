from app.main import create_app


def test_health_endpoint():
    app = create_app()
    client = app.test_client()

    response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_items_endpoint():
    app = create_app()
    client = app.test_client()

    response = client.get("/items")
    data = response.get_json()

    assert response.status_code == 200
    assert len(data["items"]) == 2

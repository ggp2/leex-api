cat > README.md <<'EOF'
# LEEX API — CI/CD DevSecOps avec GitLab CI et GitHub Actions

Projet DevOps visant à concevoir, sécuriser et comparer deux chaînes CI/CD pour une API Python conteneurisée.

## Objectifs

Le projet couvre :

- qualité de code ;
- tests unitaires ;
- audit de sécurité ;
- détection de secrets ;
- génération d'artefacts ;
- build et test Docker ;
- déploiement sur VM ;
- rollback ;
- comparaison GitLab CI / GitHub Actions.

---

## Stack technique

- Python
- Flask
- Gunicorn
- Docker
- Git
- GitLab CI
- GitHub Actions
- Pytest
- Ruff
- Bandit
- pip-audit
- Gitleaks
- Bash

---

## Architecture

```text
.
├── .github/
│   └── workflows/
│       └── ci.yml
├── app/
│   ├── __init__.py
│   └── main.py
├── scripts/
│   ├── deploy-local.sh
│   └── rollback-local.sh
├── tests/
│   └── test_api.py
├── .gitlab-ci.yml
├── Dockerfile
├── requirements.txt
├── requirements-dev.txt
├── pytest.ini
├── COMPARAISON-CI.md
└── README.md
```

---

## Application

LEEX API est une API Flask exposant principalement deux routes.

### `/health`

Permet de vérifier que l'application fonctionne.

```bash
curl http://127.0.0.1:8002/health
```

Réponse attendue :

```json
{"status":"ok"}
```

### `/items`

Permet de récupérer les données de l'API.

```bash
curl http://127.0.0.1:8002/items
```

---

## Pipeline GitLab CI

GitLab CI automatise :

- lint avec Ruff ;
- tests avec Pytest ;
- analyse de sécurité avec Bandit ;
- audit des dépendances avec pip-audit ;
- détection de secrets avec Gitleaks ;
- génération de rapports ;
- création d'un artefact applicatif.

### Limitation Docker

Le build Docker a été bloqué par les restrictions du runner GitLab ETNA.

Deux approches ont été testées :

- Docker-in-Docker ;
- BuildKit rootless.

Erreurs rencontrées :

```text
Cannot connect to the Docker daemon
```

et :

```text
operation not permitted
```

Cette limitation provient de la configuration et des permissions du runner, et non du code de l'application ou du Dockerfile.

---

## Pipeline GitHub Actions

Le workflow GitHub Actions contient quatre jobs principaux :

1. Qualité, tests et sécurité
2. Recherche de secrets
3. Création de l'artefact
4. Build et test Docker

Le pipeline valide :

- Ruff ;
- Pytest ;
- Bandit ;
- pip-audit ;
- Gitleaks ;
- création d'artefacts ;
- checksum SHA-256 ;
- build Docker ;
- démarrage du conteneur ;
- test de `/health` ;
- test de `/items` ;
- healthcheck Docker ;
- utilisateur non-root ;
- nettoyage du conteneur.

Le pipeline GitHub Actions a été validé avec succès.

---

## Sécurité

Les contrôles de sécurité comprennent :

- Bandit pour le code Python ;
- pip-audit pour les dépendances ;
- Gitleaks pour les secrets ;
- utilisateur Docker non-root ;
- permissions minimales dans GitHub Actions ;
- checksum SHA-256 pour l'intégrité des artefacts ;
- exposition du service sur `127.0.0.1`.

---

## Docker

Construire l'image :

```bash
docker build -t leex-api:1.0.0 .
```

Lancer le conteneur :

```bash
docker run -d \
  --name leex-api \
  --publish 127.0.0.1:8002:8000 \
  leex-api:1.0.0
```

Vérifier son état :

```bash
docker inspect \
  --format='{{.State.Status}} / {{.State.Health.Status}}' \
  leex-api
```

Résultat attendu :

```text
running / healthy
```

---

## Déploiement

Le script `scripts/deploy-local.sh` construit une nouvelle image, remplace l'ancien conteneur et vérifie automatiquement la disponibilité de l'API.

```bash
./scripts/deploy-local.sh 1.0.1
```

Le script réalise :

- construction de l'image ;
- suppression de l'ancien conteneur ;
- démarrage de la nouvelle version ;
- contrôle de `/health` ;
- affichage des logs en cas d'échec.

---

## Rollback

Le script `scripts/rollback-local.sh` permet de revenir à une version Docker précédente.

```bash
./scripts/rollback-local.sh 1.0.0
```

Le rollback :

- vérifie que l'ancienne image existe ;
- remplace le conteneur actuel ;
- démarre l'ancienne version ;
- teste `/health` ;
- confirme le retour à une version fonctionnelle.

---

## Comparaison GitLab CI / GitHub Actions

| Fonctionnalité | GitLab CI | GitHub Actions |
|---|---|---|
| Ruff | Réussi | Réussi |
| Pytest | Réussi | Réussi |
| Bandit | Réussi | Réussi |
| pip-audit | Réussi | Réussi |
| Gitleaks | Réussi | Réussi |
| Artefacts | Réussi | Réussi |
| Build Docker | Bloqué par le runner | Réussi |
| Test du conteneur | Non exécuté | Réussi |
| Healthcheck | Non exécuté | Réussi |
| Utilisateur non-root | Non exécuté | Réussi |
| Déploiement VM | Réussi | Réussi |
| Rollback | Réussi | Réussi |

---

## Compétences démontrées

Ce projet démontre des compétences pratiques en :

- CI/CD ;
- DevSecOps ;
- Docker ;
- Git ;
- Linux ;
- Bash ;
- qualité logicielle ;
- sécurité applicative ;
- gestion d'artefacts ;
- déploiement ;
- rollback ;
- diagnostic de runners CI.

---

## Résultat

GitLab CI a permis de valider :

- qualité ;
- tests ;
- sécurité ;
- artefacts.

GitHub Actions a permis de valider la chaîne complète jusqu'au build et au test du conteneur Docker.

Le projet démontre également un déploiement reproductible sur VM et un rollback fonctionnel.

---

## Conclusion

GitLab CI et GitHub Actions permettent tous les deux de construire des chaînes CI/CD robustes.

Dans l'environnement utilisé, GitHub Actions a permis d'exécuter la chaîne Docker complète, alors que GitLab CI a été limité par les permissions du runner ETNA.

Ce projet illustre une approche DevOps orientée automatisation, sécurité, exploitation et mise en production.
EOF

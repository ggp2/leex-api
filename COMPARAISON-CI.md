# Comparaison GitLab CI et GitHub Actions

## 1. Objectif du projet

L'objectif est de mettre en place deux pipelines CI/CD pour l'API LEEX :

- un pipeline avec GitLab CI ;
- un pipeline avec GitHub Actions ;
- des contrôles de qualité, de test et de sécurité ;
- la création d'un artefact applicatif ;
- la construction et le test d'une image Docker ;
- un déploiement sur la VM ETNA ;
- un mécanisme de rollback.

## 2. Étapes communes

Les deux plateformes réalisent les contrôles suivants :

- lint avec Ruff ;
- tests unitaires avec Pytest ;
- analyse de sécurité avec Bandit ;
- audit des dépendances avec pip-audit ;
- recherche de secrets avec Gitleaks ;
- création d'un artefact applicatif.

## 3. GitLab CI

### Résultats

Les étapes suivantes ont fonctionné :

- qualité du code ;
- tests ;
- sécurité ;
- génération des rapports ;
- création de l'artefact applicatif.

### Limitation rencontrée

Le build Docker n'a pas pu être exécuté sur le runner GitLab ETNA.

Les méthodes testées étaient :

- Docker-in-Docker ;
- BuildKit rootless.

Les erreurs étaient liées aux restrictions du runner :

- impossibilité de joindre le démon Docker ;
- permissions insuffisantes ;
- blocage de certaines opérations système.

Cette limitation provient de l'infrastructure du runner et non du code de l'application.

## 4. GitHub Actions

### Résultats

Le pipeline GitHub Actions a entièrement réussi :

- qualité, tests et sécurité ;
- recherche de secrets ;
- création de l'artefact ;
- build Docker ;
- démarrage du conteneur ;
- test de la route `/health` ;
- test de la route `/items` ;
- vérification du healthcheck Docker ;
- vérification de l'utilisateur non-root ;
- nettoyage du conteneur.

### Particularité

Le runner GitHub hébergé autorise l'utilisation de Docker pendant le workflow.

Le pipeline a donc pu valider toute la chaîne CI.

## 5. Déploiement sur la VM ETNA

Deux scripts ont été ajoutés :

- `scripts/deploy-local.sh` ;
- `scripts/rollback-local.sh`.

Le script de déploiement :

- construit une image Docker versionnée ;
- supprime l'ancien conteneur ;
- démarre la nouvelle version ;
- teste la route `/health` ;
- affiche les logs en cas d'échec.

Le script de rollback :

- vérifie que l'ancienne image existe ;
- supprime le conteneur courant ;
- redémarre l'ancienne version ;
- vérifie la santé de l'application.

Le rollback vers `leex-api:1.0.0` a été validé avec succès.

## 6. Tableau comparatif

| Critère | GitLab CI | GitHub Actions |
|---|---|---|
| Lint | Réussi | Réussi |
| Tests Pytest | Réussi | Réussi |
| Bandit | Réussi | Réussi |
| pip-audit | Réussi | Réussi |
| Gitleaks | Réussi | Réussi |
| Artefact | Réussi | Réussi |
| Build Docker | Bloqué par le runner | Réussi |
| Test du conteneur | Non exécuté | Réussi |
| Healthcheck Docker | Non exécuté | Réussi |
| Utilisateur non-root | Non exécuté | Réussi |
| Déploiement local ETNA | Réussi | Réussi via scripts |
| Rollback | Réussi | Réussi via scripts |

## 7. Conclusion

GitLab CI et GitHub Actions permettent tous les deux de mettre en place une chaîne CI complète pour la qualité, les tests, la sécurité et les artefacts.

Dans cet environnement, GitHub Actions est plus adapté au build Docker, car le runner GitHub autorise les opérations nécessaires.

GitLab CI reste fonctionnel pour les contrôles applicatifs, mais le runner privé ETNA limite l'utilisation de Docker-in-Docker et de BuildKit rootless.

La meilleure solution dépend donc principalement des permissions et de la configuration du runner.

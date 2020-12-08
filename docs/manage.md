# Administration des conteneurs

Les instructions listées ici ne sont valables que si vous avez suivi avec succès
une des procédures de déploiement `docs/deploy-xxx.md`.

## Arrêt

Envoyer un signal `SIGINT` au processus `up-dev.sh` ou `up-prod.sh`, par exemple
avec `Ctrl+C`.

Ou sinon :

```
./manage/docker/stop.sh
```

## Suppression

* `./manage/docker/reset.sh` pour supprimer les conteneurs et les volumes, mais conserver les images
* `./manage/docker/clean.sh` pour supprimer conteneurs, volumes et images

## Base de données locale

Quand la base de données utilisée est celle définie dans `docker-compose.dev.yml`,
il est possible de s'y connecter depuis pgAdmin : [http://localhost:5050/browser/](http://localhost:5050/browser/)

Le mot de passe central est la valeur de `PASS_POSTGRES` dans le fichier `.env`.

Pour consulter la base, il faut l'ajouter :

* Clic droit sur "Servers" à gauche puis "Create" > "Server"
* Dans l'onglet "General" :
    * `Name` : `publik`
* Dans l'onglet "Connection" :
    * `Host` : `db`
    * `Port` : `DB_PORT` dans le `.env`
    * `Username` : `DB_ADMIN_USER` dans le `.env`
    * `Password` : `PASS_POSTGRES` dans le `.env`
* "Save"

## Sauvegarde

```
./manage/backup.sh
```

Crée un dossier à la date courante dans `data/backups` avec deux fichiers :

* `*.tar` : les volumes montés dans `/var/lib/` par le conteneur `components`. Attention, `wcs.tar` contient tout le dossier `/var/lib/wcs` alors que les autres archives ne comportent que le sous-dossier `/var/lib/*/tenants/`.
* `db_dump.gz` : une sauvegarde de la base avec `pg_dumpall` compressée avec gzip (cf. [doc](https://www.postgresql.org/docs/10/backup-dump.html#BACKUP-DUMP-LARGE))

### Restauration

**Attention :** efface les données existantes. Il est conseillé de faire une
sauvegarde avant d'en restaurer une plus ancienne.

```
./manage/restore-backup.sh <chemin_du_dossier>
# Ex : ./manage/restore-backup.sh data/backups/03-12-2020_14h44m48s/
```

## Logging

Il est possible de personnaliser le niveau de logging via la variable `LOG_LEVEL`
dans le fichier `config.env`. Les logs sont configurÃ©s dans les fichiers de
configuration nginx `components/nginx/*` et dans `components/tools.pyenv.template`.

Les logs des composants Django sont Ã©crits dans la console et capturÃ©s par `service`
qui les sauvegarde dans des fichiers (cf. plus bas).

Pour consulter les messages de logging, se connecter au conteneur (une fois démarré) :

```bash
./manage/docker/connect.sh  # Par défaut, se connecte à "components"
# Ou : ./manage/docker/connect.sh <nom_ou_id_du_conteneur>
```

Il y a alors deux types de logs :

* `/var/log/nginx/` : les logs de nginx (uniquement dans les conteneurs `proxy` et `components`)
* `/var/log/uwsgi.COMPOSANT.log` : les logs du composant Django (uniquement dans le conteneur `components`)

TODO: authentic

## Debug

Pour débuguer le code Python d'un composant, nous procédons de la façon suivante :

1. Identifier le dossier contenant les sources (à priori `/usr/lib/python2.7/dist-packages/<component>`)
2. Le copier dans `data` : `docker cp components:<src-folder> data/<component>`
3. Ajouter une règle dans `components.volumes` de `docker-compose.yml` : `- ./data/<component>:/usr/lib/python2.7/dist-packages/<component>`

Il est alors possible d'insérer des messages de debug dans le code directement en
l'éditant dans le dossier monté dans `data`. A priori, il n'y a pas besoin de
redémarrer les conteneurs pour que les modifications dans le code soient prises
en compte.

## Importer des données

### Créer une collectivité

Créer une collectivité se fait en deux étapes :

1. Créer la configuration : exécuter `./manage/publik/add-org.sh` puis consulter la documentation affichée.
2. Déployer les nouveaux services : `./manage/publik/deploy.sh <org-slug>`

La première étape crée un dossier `data/sites/<org>/` comportant le contenu de
`org_template/` adapté selon les arguments fournis à `./manage/publik/add-org.sh`.

La seconde étape consiste en trois type d'opérations :

1. Générer la configuration nginx (certificats HTTPS et fichiers de routing). **Note :** les certificats HTTPS ne pourront être générés si la machine n'est pas accessible depuis Internet (dans le cadre d'une installation locale), aussi il faudra les générer au préalable, avec la même procédure que suivie dans `docs/deploy-local.md`.
2. Déployer les services Publik
3. Importer le contenu du site

### Supprimer une collectivité

```
./manage/publik/delete-org.sh <slug>
```

Puis se rendre dans l'admin Authentic (en ajoutant `admin` à la fin de l'url) et
supprimer l'entité de votre commune dans "Authentic2 RBAC" > "Entités".

### Importer des pages

TODO

### Importer des démarches

TODO

### Importer des rôles et utilisateurs

Pour le moment, ce n'est pas possible.

### Changer de thème

Les thèmes utilisables sont définis dans le dépôt `THEMES_REPO_URL` du fichier
`.env`.

Pour créer/supprimer des thèmes, se référer à son README.

Pour associer un thème à une collectivité :

```
./manage/publik/set-theme.sh <theme> [<org>]
```

## Mise à jour

```
./manage/docker/update.sh
```

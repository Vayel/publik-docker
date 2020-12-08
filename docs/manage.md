# Administration des conteneurs

Les instructions list�es ici ne sont valables que si vous avez suivi avec succ�s
une des proc�dures de d�ploiement `docs/deploy-xxx.md`.

## Arr�t

Envoyer un signal `SIGINT` au processus `up-dev.sh` ou `up-prod.sh`, par exemple
avec `Ctrl+C`.

Ou sinon :

```
./manage/docker/stop.sh
```

## Suppression

* `./manage/docker/reset.sh` pour supprimer les conteneurs et les volumes, mais conserver les images
* `./manage/docker/clean.sh` pour supprimer conteneurs, volumes et images

## Base de donn�es locale

Quand la base de donn�es utilis�e est celle d�finie dans `docker-compose.dev.yml`,
il est possible de s'y connecter depuis pgAdmin : [http://localhost:5050/browser/](http://localhost:5050/browser/)

Le mot de passe central est la valeur de `PASS_POSTGRES` dans le fichier `.env`.

Pour consulter la base, il faut l'ajouter :

* Clic droit sur "Servers" � gauche puis "Create" > "Server"
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

Cr�e un dossier � la date courante dans `data/backups` avec deux fichiers :

* `*.tar` : les volumes mont�s dans `/var/lib/` par le conteneur `components`. Attention, `wcs.tar` contient tout le dossier `/var/lib/wcs` alors que les autres archives ne comportent que le sous-dossier `/var/lib/*/tenants/`.
* `db_dump.gz` : une sauvegarde de la base avec `pg_dumpall` compress�e avec gzip (cf. [doc](https://www.postgresql.org/docs/10/backup-dump.html#BACKUP-DUMP-LARGE))

### Restauration

**Attention :** efface les donn�es existantes. Il est conseill� de faire une
sauvegarde avant d'en restaurer une plus ancienne.

```
./manage/restore-backup.sh <chemin_du_dossier>
# Ex : ./manage/restore-backup.sh data/backups/03-12-2020_14h44m48s/
```

## Logging

Il est possible de personnaliser le niveau de logging via la variable `LOG_LEVEL`
dans le fichier `config.env`. Les logs sont configurés dans les fichiers de
configuration nginx `components/nginx/*` et dans `components/tools.pyenv.template`.

Les logs des composants Django sont écrits dans la console et capturés par `service`
qui les sauvegarde dans des fichiers (cf. plus bas).

Pour consulter les messages de logging, se connecter au conteneur (une fois d�marr�) :

```bash
./manage/docker/connect.sh  # Par d�faut, se connecte � "components"
# Ou : ./manage/docker/connect.sh <nom_ou_id_du_conteneur>
```

Il y a alors deux types de logs :

* `/var/log/nginx/` : les logs de nginx (uniquement dans les conteneurs `proxy` et `components`)
* `/var/log/uwsgi.COMPOSANT.log` : les logs du composant Django (uniquement dans le conteneur `components`)

TODO: authentic

## Debug

Pour d�buguer le code Python d'un composant, nous proc�dons de la fa�on suivante :

1. Identifier le dossier contenant les sources (� priori `/usr/lib/python2.7/dist-packages/<component>`)
2. Le copier dans `data` : `docker cp components:<src-folder> data/<component>`
3. Ajouter une r�gle dans `components.volumes` de `docker-compose.yml` : `- ./data/<component>:/usr/lib/python2.7/dist-packages/<component>`

Il est alors possible d'ins�rer des messages de debug dans le code directement en
l'�ditant dans le dossier mont� dans `data`. A priori, il n'y a pas besoin de
red�marrer les conteneurs pour que les modifications dans le code soient prises
en compte.

## Importer des donn�es

### Cr�er une collectivit�

Cr�er une collectivit� se fait en deux �tapes :

1. Cr�er la configuration : ex�cuter `./manage/publik/add-org.sh` puis consulter la documentation affich�e.
2. D�ployer les nouveaux services : `./manage/publik/deploy.sh <org-slug>`

La premi�re �tape cr�e un dossier `data/sites/<org>/` comportant le contenu de
`org_template/` adapt� selon les arguments fournis � `./manage/publik/add-org.sh`.

La seconde �tape consiste en trois type d'op�rations :

1. G�n�rer la configuration nginx (certificats HTTPS et fichiers de routing). **Note :** les certificats HTTPS ne pourront �tre g�n�r�s si la machine n'est pas accessible depuis Internet (dans le cadre d'une installation locale), aussi il faudra les g�n�rer au pr�alable, avec la m�me proc�dure que suivie dans `docs/deploy-local.md`.
2. D�ployer les services Publik
3. Importer le contenu du site

### Supprimer une collectivit�

```
./manage/publik/delete-org.sh <slug>
```

Puis se rendre dans l'admin Authentic (en ajoutant `admin` � la fin de l'url) et
supprimer l'entit� de votre commune dans "Authentic2 RBAC" > "Entit�s".

### Importer des pages

TODO

### Importer des d�marches

TODO

### Importer des r�les et utilisateurs

Pour le moment, ce n'est pas possible.

### Changer de th�me

Les th�mes utilisables sont d�finis dans le d�p�t `THEMES_REPO_URL` du fichier
`.env`.

Pour cr�er/supprimer des th�mes, se r�f�rer � son README.

Pour associer un th�me � une collectivit� :

```
./manage/publik/set-theme.sh <theme> [<org>]
```

## Mise � jour

```
./manage/docker/update.sh
```

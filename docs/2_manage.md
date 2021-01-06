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
* `*.sql` : une sauvegarde de chaque base avec `pg_dump`

### Restauration

**Attention :** efface les donn�es existantes. Il est conseill� de faire une
sauvegarde avant d'en restaurer une plus ancienne.

```
./manage/restore-backup.sh <chemin_du_dossier>
# Ex : ./manage/restore-backup.sh data/backups/03-12-2020_14h44m48s/
```

## Logging

Il est possible de personnaliser le niveau de logging via la variable `LOG_LEVEL`
dans le fichier `.env`. Les logs sont configur�s dans les fichiers de
configuration nginx `images/components/nginx/*` et dans `images/components/common.py.template`.

Les logs des composants Django sont �crits dans la console et captur�s par `service`
qui les sauvegarde dans des fichiers (voir `debian/<component>.init` dans le code
source).

Pour consulter les messages de logging, se connecter au conteneur (une fois d�marr�) :

```bash
./manage/docker/connect.sh  # Par d�faut, se connecte � "components"
# Ou : ./manage/docker/connect.sh <nom_ou_id_du_conteneur>
```

Il y a alors deux types de logs :

* `/var/log/nginx/` : les logs de nginx (uniquement dans les conteneurs `proxy` et `components`)
* `/var/log/uwsgi.COMPOSANT.log` : les logs du composant Django (uniquement dans le conteneur `components`)

## Debug

Pour d�buguer le code Python d'un composant, nous proc�dons de la fa�on suivante :

1. Identifier le dossier contenant les sources (� priori `/usr/lib/python3/dist-packages/<component>`)
2. Se connecter au conteneur : `./manage/docker/connect.sh`
3. Ajouter des instructions de debug dans les sources
4. Red�marrer les services : `stop-services.sh && start-services.sh`

## Importer des donn�es

### Cr�er une collectivit�

Se r�f�rer � [docs/multi-sites.md](multi-sites.md).

### Importer des pages

TODO

### Importer des d�marches

TODO

### Importer des r�les et utilisateurs

Pour le moment, ce n'est pas possible.

### Changer de th�me

Se r�f�rer � [docs/themes.md](themes.md).

## Mise � jour

Comme expliqu� dans la [documentation officielle](https://doc-publik.entrouvert.com/guide-de-l-administrateur-systeme/exploitation/mises-a-jour-des-composants/) :

> Entr'ouvert livre une nouvelle version de Publik les soirs des 2�me et 4�me jeudi de chaque mois. L'installation peut �tre faite aussit�t, mais nous conseillons � des h�bergeurs tiers non infog�r�s par Entr'ouvert de faire la mise � jour le mardi suivant.

Attendre le mardi suivant permet de profiter des *hotfixes*.

La mise � jour fait au pr�alable une sauvegarde donc il faut que les conteneurs
soient d�marr�s.

```
./manage/docker/update.sh
```

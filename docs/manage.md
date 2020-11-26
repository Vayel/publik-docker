# Administration des conteneurs

Les instructions listées ici ne sont valables que si vous avez suivi avec succès
une des procédures de déploiement `docs/deploy-xxx.md`.

## Arrêt

Envoyer un signal `SIGINT` au processus `up.sh` ou `up-prod.sh`, par exemple
avec `Ctrl+C`.

Ou sinon :

```
./stop.sh
```

## Suppression

* `./reset.sh` pour supprimer les conteneurs et les volumes, mais conserver les images
* `./clean.sh` pour supprimer conteneurs, volumes et images

## Logging

Il est possible de personnaliser le niveau de logging via la variable `LOG_LEVEL`
dans le fichier `config.env`. Les logs sont configurÃ©s dans les fichiers de
configuration nginx `components/nginx/*` et dans `components/tools.pyenv.template`.

Les logs des composants Django sont Ã©crits dans la console et capturÃ©s par `service`
qui les sauvegarde dans des fichiers (cf. plus bas).

Pour consulter les messages de logging, se connecter au conteneur (une fois démarré) :

```bash
./connect.sh  # Par défaut, se connecte à "components"
# Ou : ./connect.sh nom_ou_id_du_conteneur
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

1. Créer la configuration : exécuter `./add-org.sh` puis consulter la documentation affichée.
2. Déployer les nouveaux services : `./deploy.sh <org-slug>`

La première étape crée un dossier `data/sites/<org>/` comportant le contenu de
`org_template/` adapté selon les arguments fournis à `./add-org.sh`.

La seconde étape consiste en trois type d'opérations :

1. Générer la configuration nginx (certificats HTTPS et fichiers de routing). **Note :** les certificats HTTPS ne pourront être générés si la machine n'est pas accessible depuis Internet (dans le cadre d'une installation locale), aussi il faudra les générer au préalable, avec la même procédure que suivie dans `docs/deploy-local.md`.
2. Déployer les services Publik
3. Importer le contenu du site

### Supprimer une collectivité

```
./delete-org.sh <slug>
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

En créant une collectivité avec un thème spécifique, un dossier est créé dans
`themes` et ce thème est associé à la collectivité au moment du déploiement des
services.

Mais il est possible de changer de thème par la suite. En exécutant `./set-theme.sh`,
des instructions apparaissent pour ce faire.

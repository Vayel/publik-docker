# Administration des conteneurs

## Arr�t

Envoyer un signal `SIGINT` au processus `up.sh` ou `up-prod.sh`, par exemple
avec `Ctrl+C`.

Ou sinon :

```
./stop.sh
```

## Suppression

* `./reset.sh` pour supprimer les conteneurs et les volumes, mais conserver les images
* `./clean.sh` pour supprimer conteneurs, volumes et images

## Debug

Il est possible de personnaliser le niveau de logging via la variable `LOG_LEVEL`
dans le fichier `config.env`. Les logs sont configurés dans les fichiers de
configuration nginx `components/nginx/*` et dans `components/tools.pyenv.template`.

Les logs des composants Django sont écrits dans la console et capturés par `service`
qui les sauvegarde dans des fichiers (cf. plus bas).

Pour consulter les messages de logging, se connecter au conteneur (une fois démarré) :

```bash
./connect.sh  # Par défaut, se connecte à "components"
# Ou : ./connect.sh nom_ou_id_du_conteneur
```

Il y a alors deux types de logs :

* `/var/log/nginx/` : les logs de nginx (uniquement dans les conteneurs `proxy` et `components`)
* `/var/log/uwsgi.COMPOSANT.log` : les logs du composant Django (uniquement dans le conteneur `components`)

## Importer des donn�es

TODO

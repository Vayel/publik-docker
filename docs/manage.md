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

TODO
* Collectivités
* Thèmes

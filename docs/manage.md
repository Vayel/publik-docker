# Administration des conteneurs

## Arrêt

Envoyer un signal `SIGINT` au processus `up.sh` ou `up-prod.sh`, par exemple
avec `Ctrl+C`.

## Suppression

* `./reset.sh` pour supprimer les conteneurs et les volumes, mais conserver les images
* `./clean.sh` pour supprimer conteneurs, volumes et images

## Debug

Il est possible de personnaliser le niveau de logging via la variable `LOG_LEVEL`
dans le fichier `config.env`.

Pour consulter les messages de logging, se connecter au conteneur (une fois démarré) :

```bash
./connect.sh  # Par défaut, se connecte à "components"
# Ou : ./connect.sh nom_ou_id_du_conteneur
```

Il y a alors deux types de logs :

* `/var/log/nginx/` : les logs de nginx (uniquement dans les conteneurs `proxy` et `components`)
* `/var/log/<composant>/` : les logs du composant Django (uniquement dans le conteneur `components`)

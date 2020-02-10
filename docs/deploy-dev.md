# Déploiement de développement

Suivre cette procédure pour déployer la version de **développement** des conteneurs
sur une machine **accessible depuis Internet**.

Merci de lire au préalable le fichier `README.md` à la racine du projet. À ce
stade, vous avez configuré les urls et installé les dépendances définies
dans `install-on-debian.sh`.

## Déclaration DNS

Une fois les urls définies, il faut faire pointer les domaines `*ENV.DOMAIN` vers
la machine de déploiement.

Des certificats HTTPS Let's encrypt seront automatiquement générés durant le processus
d'installation. C'est pourquoi il est important que le serveur soit accessible
depuis Internet et que les enregistrement DNS ait été préalablement configurées
avant de commencer.

Vous pouvez vérifier votre configuration DNS en réalisant un ping sur une adresse
(penser à autoriser le ping de la machine). Exemple :

```
# ping <COMBO_SUBDOMAIN><ENV>.<DOMAIN>
ping citoyens.monserveur.fr
```

L'IP affichée doit correspondre à celle de la machine de déploiement.

## Déploiement

Personnaliser si besoin les variables d'environnement dans les fichiers suivants :

* `.env`
* `data/config.env`
* `data/secret.env`

Notons que pour un déploiement de dev, la base de données utilisée est celle du
conteneur Docker `db`, il n'y a donc rien à changer à ce niveau.

TODO: mailcatcher

```bash
./build.sh
./up.sh
```

Vous devez alors obtenir quelque chose comme :

```
[ components     | memcached is running.
[ components     | combo is running.
[ components     | passerelle is running.
[ components     | fargo is running.
[ components     | hobo is running.
[ components     | supervisord is running
[ components     | authentic2-multitenant is running.
[ components     | wcs is running.
[ components     | nginx is running.
```

Dans un autre shell (en conservant le premier ouvert) :

```
# Prend un peu de temps. Doit se terminer sur :
#
# OK: combo is ready
# OK: combo_agent is ready
# OK: passerelle is ready
# OK: wcs is ready
# OK: authentic is ready
# OK: fargo is ready
# OK: hobo is ready
# Configuration OK (Hobo cook)

./deploy.sh

# Doit se terminer sur :
#
# Deployment looks OK

./check-deployment.sh
```

Rendez-vous sur `https://<COMBO_SUBDOMAIN><ENV>.<DOMAIN>`. Par exemple :
`https://citoyens.monserveur.fr`.

## Administration des conteneurs

Pour démarrer les conteneurs, lancer :

```
./up.sh
```

Puis se référer à `docs/manage.md`.

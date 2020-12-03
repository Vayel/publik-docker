# Déploiement de production

Suivre cette procédure pour déployer la version de **production** des conteneurs
sur une machine **accessible depuis Internet**.

### Déclaration DNS

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

### Déploiement

Personnaliser si besoin les variables d'environnement dans le fichier `.env`.

Il est **nécessaire** de personnaliser les variables suivantes :
`DB_HOST`, `DB_PORT`, `DB_ADMIN_USER`, `SMTP_HOST`, `SMTP_USER`, `SMTP_PORT`,
`PASS_POSTGRES`, `PASS_SMTP`.


```bash
./manage/docker/build.sh
./manage/docker/up-prod.sh  # /!\ Commande différente par rapport à la version de dev
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
./manage/docker/deploy.sh
# /!\ Peut generer l'erreur "tput: unknown terminal 'unknown'"
# Si c'est le cas, mettre HOBO_DEPLOY_VERBOSITY=0 dans le .env
#
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

./manage/publik/check-deployment.sh
# Doit se terminer sur :
#
# Deployment looks OK
```

Rendez-vous sur `https://<COMBO_SUBDOMAIN><ENV>.<DOMAIN>`. Par exemple :
`https://citoyens.monserveur.fr`.

## Administration des conteneurs

```
./manage/docker/up-prod.sh
```

Puis se référer à `docs/manage.md`.

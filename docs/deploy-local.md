# Déploiement local

Suivre cette procédure pour déployer les conteneurs sur une machine **non accessible
depuis Internet**.

Merci de lire au préalable le fichier `README.md` à la racine du projet. À ce
stade, vous avez configuré les urls et installé les dépendances définies
dans `install-on-debian.sh`.

## Génération des certificats HTTPS

Il nous faut des certificats HTTPS pour chacun des composants. Pour cela, nous
avons temporairement besoin d'une machine accessible depuis Internet avec le
port 80 ouvert en entrée/sortie, vers laquelle nous faisons pointer les
domaines `*ENV.DOMAIN`.

Cette machine temporaire peut facilement être créée sur une plateforme de cloud
(OVH, AWS...). Une machine de type Debian facilitera grandement le processus. La
génération des certificats ne consommant que peu de ressources, entre 5 et 10Go
d'espace disque et 1Go de RAM devraient suffire (TODO : vérifier ça).

Vous pouvez vérifier votre configuration DNS en réalisant un ping sur une adresse
(penser à autoriser le ping de la machine). Exemple :

```
# ping <COMBO_SUBDOMAIN><ENV>.<DOMAIN>
ping citoyens.monserveur.fr
```

L'IP affichée doit correspondre à celle de la machine temporaire.

Se connecter en SSH et reproduire la procédure d'installation sur serveur Debian
jusqu'à ce niveau. Puis :

```bash
./manage/docker/build.certificates.sh
./create-certificates.sh
```

Les certificats seront créés dans `data/letsencrypt`. Le dossier contient des
liens symboliques, aussi nous zippons le dossier avant de le rappatrier sur
notre machine locale :

```bash
# Il faut être admin pour inclure les certificats, donc cette commande ne
# fonctionnera pas avec l'utilisateur publik
cd /home/publik/publik-docker/data
sudo zip -r letsencrypt.zip letsencrypt
```

Récupérez `letsencrypt.zip` sur votre machine locale (avec `scp` par exemple)
puis dézippez-le dans le dossier `data` :

```
scp -i <ssh_key> <user>@<ip>:/home/publik/publik-docker/data/letsencrypt.zip ./data/
cd data
unzip letsencrypt.zip
```

Vous pouvez désormais éteindre la machine Debian temporaire.

## Configuration DNS

Il faut faire pointer les urls des composants vers la machine locale. Attention :
`localhost` désigne le conteneur Docker et non pas l'hôte.

* Copier le fichier `/etc/hosts` (ou `C:\windows\System32\drivers\etc\hosts` sous Windows) dans `data/hosts` 
* L'ouvrir et identifier l'ip associée à `host.docker.internal`
* Dans ce fichier ET dans le fichier d'origine (`/etc/hosts` sous Linux), ajouter une redirection vers cette ip pour chaque url de composant et pour RabbitMQ. Par exemple :

```
# <LOCAL_IP>        <SUB_DOMAIN><ENV>.<DOMAIN>
192.168.4.133       citoyens.monserveur.fr
192.168.4.133       agents.monserveur.fr
192.168.4.133       auth.monserveur.fr
192.168.4.133       hobo.monserveur.fr
192.168.4.133       passerelle.monserveur.fr
192.168.4.133       demarches.monserveur.fr
192.168.4.133       documents.monserveur.fr
192.168.4.133       rabbitmq.monserveur.fr
192.168.4.133       pgadmin.monserveur.fr
192.168.4.133       webmail.monserveur.fr
```

`ping citoyens.monserveur.fr` doit pointer sur l'ip locale.

## Déploiement

Personnaliser si besoin les variables d'environnement dans le fichier `.env`.

Notons que pour un déploiement de dev, la base de données utilisée est celle du
conteneur Docker `db`, il n'y a donc rien à changer à ce niveau. Il est néanmoins
possible d'utiliser une autre base en éditant `DB_HOST`, `DB_PORT`, `DB_ADMIN_USER`
et `PASS_POSTGRES`.

De même, le conteneur `mailcatcher` fait office de serveur SMTP : il intercepte
les mails et les rend accessibles depuis `http://webmail<ENV>.<DOMAIN>` (en HTTP et
non en HTTPS). Il est néanmoins possible d'utiliser un autre serveur SMTP en éditant :
`SMTP_HOST`, `SMTP_USER`, `SMTP_PORT` et `PASS_SMTP`.

```bash
./manage/docker/build.sh
./manage/docker/up.sh
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

Il faut alors déployer les services Publik avec la commande `./manage/publik/deploy.sh`. En
plus de configurer nginx et de déployer les services, cette commande importe le
contenu du site. Pour cela, elle va consulter le dossier `data/sites` et chercher
les fichiers suivants (aucun n'est obligatoire) :

* `user-portal.json` : les pages du portail citoyens
* `agent-portal.json` : les pages du portail agents
* `wcs.zip` : les démarches et les catégories (importer des workflows ne fonctionne pas pour le moment)

Ces données sont exportées d'une autre instance Publik :

* Soit depuis l'interface web
    * `user-portal.json` s'obtient via `https://citoyens.DOMAIN/manage/site-export`
    * `agent-portal.json` s'obtient via `https://agentsENV.DOMAIN/manage/site-export`
    * `wcs.zip` s'obtient via `https://demarchesENV.DOMAIN/backoffice/settings/export`, **en cochant uniquement** les démarches et les catégories
* Soit, si cette instance a été déployée à partir de ce dépôt, via la commande `./manage/publik/export-sites.sh`, qui sauvegarde les données dans `data/sites`.

Il suffit alors de lancer dans un autre shell (en conservant le premier ouvert) :

```
./manage/publik/deploy.sh
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
#
# Doit se terminer sur :
#
# Deployment looks OK
```

> **Attention :** parfois, un bug apparaît avec un template authentic, ce qui fait
> que wcs renvoie un code HTTP 500 au lieu d'un 200. Il suffit alors normalement
> d'attendre 5 minutes le temps que le cache se mette à jour. Puis de lancer :
>
> `./manage/publik/import-site.sh`

Rendez-vous sur `https://<COMBO_SUBDOMAIN><ENV>.<DOMAIN>`. Par exemple :
`https://citoyens.monserveur.fr`.

## Administration des conteneurs

Pour démarrer les conteneurs, lancer :

```
./manage/docker/up.sh
```

Puis se référer à `docs/manage.md`.

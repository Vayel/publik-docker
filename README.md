# publik-docker

Ce projet facilite le déploiement de [Publik](https://publik.entrouvert.com/)
à l'aide de conteneurs Docker. Ce dépôt n'engage pas la société Entr'ouvert.

## Architecture de Publik

Nous résumons ici l'architecture de Publik mais conseillons évidemment de lire
la [documentation officielle](https://doc-publik.entrouvert.com/guide-de-l-administrateur-systeme/).

Publik est composé de briques de plusieurs types :

* Django. Les composants fournissant les fonctionnalités à proprement parler sont chacun des projets Django classiques. Ces applications sont lancées via des services système.
* PostgreSQL. Chaque composant Django a sa propre base de données. Toutes sont stockées sur une même instance PostgreSQL.
* RabbitMQ. Les composants Django communiquent via un serveur RabbitMQ.
* Nginx. Un serveur web fait office de proxy, c'est-à-dire de point d'entrée HTTP redirigeant les requêtes vers chaque composant Django.

Publik ne fonctionne que sous Debian 9 (stretch). PostgreSQL, RabbitMQ et Nginx sont installés
via les paquets officiels tandis que des paquets Debian sont créés pour chaque composant
Django.

Les composants Django sont démarrés via des services système.

## Mise en conteneurs

Les composants de Publik dépendent les uns des autres, aussi le choix a été fait
de tous les installer dans le même conteneur. En revanche, nous avons utilisé
des conteneurs à part avec des images officielles pour déployer la base de données,
le serveur RabbitMQ et le proxy nginx. Nous avons donc les conteneurs suivants :

* `components` : pilote les applications Django via des services système. Un serveur nginx est utilisé pour transmettre les requêtes HTTP.
* `db` : initialise et exécute la base de données PostgreSQL.
* `proxy` : gère les requêtes HTTPS et les transmet en HTTP à `components`. Génère les certificats HTTPS avec LetsEncrypt si besoin.
* `rabbitmq` : un simple serveur RabbitMQ.

Nous utilisons des variables d'environnement pour simplifier la configuration des
briques. Seulement, les composants Django étant démarrés via des services système,
ils ne peuvent pas lire les variables d'environnement. En outre, certains fichiers
de configuration (de nginx par exemple) ne peuvent tout simplement pas lire les
variables d'environnement.

Pour pallier cela, nous écrivons leur noms dans les fichiers en question
(ex : `server_name compte${ENV}.${DOMAIN};`) puis les substituons au démarrage
par leur valeur via la commande `envsubst`. Les fichiers comportant des noms de
variables à substituer ont pour extension `.template`. Comme la valeur des variables
d'environnement peut changer d'une exécution à l'autre, il est important de conserver
le modèle d'origine et de ne pas faire une substitution en place.

Les variables sont définies dans trois fichiers `xxx.env.template`. Il ne faut
PAS les éditer, une copie `xxx.env` non traquée par git en sera faite au moment
du déploiement :

* `.env` : hostnames et ports, utilisés dans les fichiers `docker-compose<.xxx>.yml`
* `secret.env` : les mots de passe
* `config.env` : d'autres variables

Comme indiqué en commentaires de ces fichiers, certaines variables peuvent être vides,
d'autres non.

Notons également que ces fichiers sont au format `ini` et ne sont PAS des scripts shell.

## Déploiement

### Pré-requis

Un script d'installation des dépendances est fourni mais suppose que la machine
est de type Debian ou dérivée. Dans le cas contraire, vous pouvez consulter le
script `sync-os.sh` et reproduire les commandes en les adaptant pour votre système.

Caractéristiques minimales de la machine :

* 4Go de RAM
* 10 Go de disque (20 Go recommandé)

### Installation

```bash
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/Vayel/publik-docker.git
cd publik
sudo ./install-on-debian.sh
cd ..
sudo mv publik /home/publik/
sudo chown publik:publik /home/publik/publik -R
```

> Note aux utilisateurs derrière un PROXY : Penser à installer les certificats dans le magasin de l'OS 
(/usr/local/share/ca-certificates) et déclarer le proxy dans la configuration docker
(https://docs.docker.com/v1.13/engine/admin/systemd/#http-proxy).
Il est également possible d'utiliser "--insecure" pour sync-os afin de faire des appels curls sans 
vérification des certificats soit la commande complète "sudo ./sync-os.sh --insecure"

Pour la suite, se référer à :

* `docs/deploy-local.md` pour une installation sur une machine **non accessible** depuis Internet
* `docs/deploy-dev.md` pour une installation de développement sur une machine **accessible** depuis Internet
* `docs/deploy-prod.md` pour une installation de production sur une machine **accessible** depuis Internet
* `docs/manage.md` pour administrer des conteneurs déjà déployés

## Contribution

Ce projet se base sur [https://github.com/departement-loire-atlantique/publik](https://github.com/departement-loire-atlantique/publik).

Il a été initialement développé chez [https://www.laetis.fr/](https://www.laetis.fr/).

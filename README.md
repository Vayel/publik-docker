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

Les variables sont définies dans `.env.template`. Il ne faut
PAS l'éditer, une copie `.env` non traquée par git en sera faite au moment
du déploiement.

Comme indiqué en commentaires de ces fichiers, certaines variables peuvent être vides,
d'autres non.

Notons également que ces fichiers ne sont PAS des scripts shell, seulement une liste
de `VAR=value`. En particulier, les guillemets autour de la valeur sont interprétés
tels quels.

## Installation

### Pré-requis

Caractéristiques minimales de la machine :

* 4Go de RAM
* 10 Go de disque (20 Go recommandé)

Un script d'installation des dépendances est fourni mais suppose que la machine
est de type Debian ou dérivée. Dans le cas contraire, vous pouvez consulter le
script `install-on-debian.sh` et reproduire les commandes en les adaptant pour votre système.

#### Installation locale

Pour une installation locale, il suffit d'avoir Docker et docker-compose installés. Puis :

```bash
git clone https://github.com/Vayel/publik-docker --recurse-submodules
cd publik-docker
```

#### Installation sur un serveur Debian

Pour une installation sur un serveur de type Debian, se connecter en ssh puis :

```bash
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/Vayel/publik-docker.git
cd publik-docker
sudo ./install-on-debian.sh
cd ..
sudo mv publik-docker /home/publik/
sudo chown publik:publik /home/publik/publik-docker -R
```

> Note aux utilisateurs derrière un PROXY : penser à installer les certificats dans le magasin de l'OS 
> (/usr/local/share/ca-certificates) et déclarer le proxy dans la configuration docker
> (https://docs.docker.com/v1.13/engine/admin/systemd/#http-proxy).
> Il est également possible d'utiliser "--insecure" pour install-on-debian afin de faire des appels curls sans 
> vérification des certificats soit la commande complète "sudo ./install-on-debian.sh --insecure"

Le code source a été installé dans `/home/publik/publik-docker`et sa propriéré a
été donnée à l'utilisateur `publik`. Il faut se déconnecter et se reconnecter du
shell pour que les changements soient pris en compte.

Au moment de se reconnecter, l'accès au code se fait via :

```bash
su - publik
cd publik-docker
```

### Configuration des urls

Les composants Django se connaissent entre eux via des noms de domaine, chacun
ayant la structure suivante : `<composant><ENV>.<DOMAIN>`

`ENV` est simplement un suffixe pour distinguer d'éventuelles multiples instances
de Publik (`test`, `dev`...).

Par exemple, le composant Combo pourrait avoir pour adresse sur la machine
`monserveur.fr` : `combo.monserveur.fr`, `combo-test.monserveur.fr`
avec `ENV=-test`, `citoyens.monserveur.fr`...

Les variables `ENV` et `DOMAIN`, ainsi que le préfixe utilisé par composant,
sont configurables et, pour certaines, **doivent être configurées**. Pour cela :

```bash
./init-env.sh
```

**Obligatoire :** éditer `DOMAIN` et `ADMIN_MAIL_ADDR` dans `.env`.

**Facultatif :** éditer `ENV` et `*_SUBDOMAIN` dans `.env`.

### Poursuivre l'installation

Pour la suite, se référer à :

* [docs/deploy-local.md](docs/deploy-local.md) pour une installation des conteneurs sur une machine **non accessible** depuis Internet
* [docs/deploy-dev.md](docs/deploy-dev.md) pour une installation de développement des conteneurs sur une machine **accessible** depuis Internet
* [docs/deploy-prod.md](docs/deploy-prod.md) pour une installation de production des conteneurs sur une machine **accessible** depuis Internet
* [docs/manage.md](docs/manage.md) pour administrer les conteneurs déjà déployés

## Contribution

Ce projet se base sur [https://github.com/departement-loire-atlantique/publik](https://github.com/departement-loire-atlantique/publik).

Il a été initialement développé chez [https://www.laetis.fr/](https://www.laetis.fr/).

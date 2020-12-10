# Installation

## Pré-requis

Caractéristiques minimales de la machine :

* 4Go de RAM
* 10 Go de disque (20 Go recommandé)

Un script d'installation des dépendances est fourni mais suppose que la machine
est de type Debian ou dérivée. Dans le cas contraire, vous pouvez consulter le
script `install-on-debian.sh` et reproduire les commandes en les adaptant pour votre système.

## Installation locale

Pour une installation locale, il suffit d'avoir Docker et docker-compose installés. Puis :

```bash
git clone https://github.com/Vayel/publik-docker
cd publik-docker
```

## Installation sur un serveur Debian

Pour une installation sur un serveur de type Debian, se connecter en ssh puis :

```bash
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/Vayel/publik-docker.git
cd publik-docker
# Demande un mot de passe pour le user "publik"
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

## Configuration des urls

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
./manage/init-env.sh
```

**Obligatoire :** éditer `DOMAIN` et `ADMIN_MAIL_ADDR` dans `.env`.

**Facultatif :** éditer `ENV` et `*_SUBDOMAIN` dans `.env`.

## Poursuivre l'installation

Pour la suite, se référer à :

* [docs/deploy-local.md](docs/1_deploy-local.md) pour une installation des conteneurs sur une machine **non accessible** depuis Internet
* [docs/deploy-dev.md](docs/1_deploy-dev.md) pour une installation de développement des conteneurs sur une machine **accessible** depuis Internet
* [docs/deploy-prod.md](docs/1_deploy-prod.md) pour une installation de production des conteneurs sur une machine **accessible** depuis Internet



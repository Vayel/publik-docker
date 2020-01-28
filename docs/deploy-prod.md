# Déploiement de production

Suivre cette procédure pour déployer la version de **production** des conteneurs
sur une machine **accessible depuis Internet**.

### Déclaration DNS

Les composants Django se connaissent entre eux via des noms de domaine, chacun
ayant la structure suivante : `<composant><ENV>.<DOMAIN>`

`ENV` est simplement un suffixe pour distinguer d'éventuelles multiples instances
de Publik (`test`, `dev`...).

Par exemple, le composant Combo aura pour adresse sur la machine
`monserveur.fr` : `combo.monserveur.fr` ou, par exemple, `combo-test.monserveur.fr`
avec `ENV=-test`.

Il faut donc faire pointer les domaines `*ENV.DOMAIN` vers la machine.

Des certificats HTTPS Let's encrypt seront automatiquement générés durant le processus
d'installation. C'est pourquoi il est important que le serveur soit accessible
depuis Internet et que les enregistrement DNS ait été préalablement configurées
avant de commencer.

Vous pouvez vérifier votre configuration DNS en réalisant un ping sur une adresse. Exemple :

```
ping combo.monserveur.fr
```

L'IP affichée doit correspondre à celle de la machine de déploiement.

### Déploiement

```bash
./init-env.sh

# Personnaliser si besoin les variables d'environnement dans les fichiers suivants :
# .env
# config.env
# secret.env

./build.sh
./up-prod.sh  # /!\ Commande différente par rapport à la version de dev
```

Vous devez alors obtenir quelque chose comme :

```
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

./init-components.sh

# Doit se terminer sur :
#
# Deployment looks OK

./check-deployment.sh
```

Rendez-vous sur `https://<COMBO_SUBDOMAIN><ENV>.<DOMAIN>`. Par exemple :
`https://citoyens.monserveur.fr`.

## Administration des conteneurs

Se référer à `docs/manage.md`.

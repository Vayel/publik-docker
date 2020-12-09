# Multi-sites

Publik permet de gérer plusieurs collectivités sur la même instance, ce qui a
l'avantage de réutiliser des informations : les comptes administrateurs, les
thèmes, etc.

Créer une collectivité se fait en deux étapes :

1. Créer la configuration : 
2. Déployer les nouveaux services : `./manage/publik/deploy.sh <org-slug>`

## Configurer le déploiement

La première étape pour déployer une nouvelle collectivité consiste à créer un
dossier `data/sites/<org>/` comportant les fichiers de déploiement tels que le
`hobo-recipe.json`.

Pour ce faire, il faut exécuter `./manage/publik/add-org.sh`. En plus de paramètres
propres à la collectivité déployée (exécuter le script sans paramètre pour en
afficher la liste), le script prend un paramètre `template` qui permet de partir
d'un potentiel modèle pour initialiser la configuration du déploiement.

TODO

## Déployer la collectivité

La seconde étape consiste en trois types d'opérations :

1. Générer la configuration nginx (certificats HTTPS et fichiers de routing). **Note :** les certificats HTTPS ne pourront être générés si la machine n'est pas accessible depuis Internet (dans le cadre d'une installation locale), aussi il faudra les générer au préalable, avec la même procédure que suivie dans [docs/deploy-local.md](deploy-local.md).
2. Déployer les services Publik
3. Importer le contenu du site

Tout cela se fait avec :

```
./manage/publik/deploy.sh <site>
```

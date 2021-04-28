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

Parfois, il est indiqué que le système d'authentification n'est pas configué (c'est
le cas notamment lorsque dans le hobo de la collectivité, on n'a pas le menu
a gauche). Il faut alors créer des objets depuis l'administration d'authentic.

Tout d'abord, créez la collectivité si elle ne l'a pas été :
`https://auth.<monsite.fr>/admin/a2_rbac/organizationalunit/`

Puis créez manuellement les fournisseurs d'identité SAML :
`https://auth.<monsite.fr>/admin/saml/libertyprovider/`

Une collectivité demande plusieurs fournisseurs à créer via le bouton "Ajouter
depuis une URL" en haut à droite (s'inspirer de ce qui existe déjà). Pour connaître
les valeurs des champs pour chaque fournisseur d'identité, exécutez le script suivant :

```
./manage/publik/generate-saml-conf.sh <org-slug> <org-name>
# Ex :
# ./manage/publik/generate-saml-conf.sh mon-village "Mon village"
```

## Supprimer une collectivité

```
./manage/publik/delete-org.sh <slug>
```

Puis se rendre dans l'admin Authentic (en ajoutant `admin` à la fin de l'url) et
supprimer l'entité de votre commune dans "Authentic2 RBAC" > "Entités".

Enfin, se connecter à la base avec pgAdmin et dans les tables `environment_*` du
schéma `hobo_<mon_site>` de la base de données `hobo`, supprimer les lignes
dont le slug est celui de la collectivité supprimée. Pour la table `environment_variable`,
il s'agit de la colonne `value`. Exemples :

```
# La meme chose pour "environment_fargo", "environment_wcs"...
DELETE FROM hobo_monpublik_fr.environment_combo WHERE slug LIKE '%ma-commune%';

# Pour "environment_variable", c'est la colonne "value" et non "slug"
DELETE FROM hobo_monpublik_fr.environment_variable WHERE value LIKE '%ma-commune%';
```

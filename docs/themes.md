# Thèmes

## Créer des thèmes

Des thèmes personnalisés peuvent être définis dans le dossier `data/themes`. Ce
dossier est monté par docker-compose puis, au démarrage du conteneur, les thèmes
sont compilés (SASS -> CSS) et placés dans le dossier lu par Publik (cf.
`images/components/bin/deploy-themes.sh`).

Le dossier `data/themes` doit avoir la structure suivante :

```
themes/
  mon_theme/
    static/
      images/
    templates/
  mon_autre_theme/
    static/
    templates/
themes.json
```

Chaque thème est une extension du [thème Publik de base](https://repos.entrouvert.org/publik-base-theme.git/tree/).

### `static`

Le dossier `static` d'un thème doit contenir un fichier`style.scss`, qui sera compilé
avec les [fichiers statiques du thème de base](https://repos.entrouvert.org/publik-base-theme.git/tree/static/publik).
La compilation est faite par `images/components/bin/compile-themes.sh`.

Le dossier `static` contient à minima un fichier `style.scss` qui lui-même importe
le style du thème de base, lequel sera placé au moment du *build* dans `publik-base-theme/`
au même niveau que `themes.json` :

```sass
@import '../../../publik-base-theme/static/includes/publik';
```

Pour être affichées, les images ont besoin d'être converties en base64, ce qui
est fait par `images/components/bin/make_theme_data_uris.py`. Ce script va
chercher les images dans le dossier `static/images`, veuillez donc y placer vos
images. Le dossier peut ne pas exister.

Des exemples sont disponibles [ici](https://github.com/Vayel/publik-docker-themes).

### `templates`

Le dossier `templates` d'un thème suit la même architecture que les [templates
du thème de base](https://repos.entrouvert.org/publik-base-theme.git/tree/templates).
Il ne contient que les fichiers HTML spécifiques au thème.

Côté Django, les templates sont chargés par `hobo.multitenant.template_loader.FilesystemLoader`
(cf. [https://repos.entrouvert.org/hobo.git/tree/debian/debian_config_common.py#n222](https://repos.entrouvert.org/hobo.git/tree/debian/debian_config_common.py#n222)),
qui lui-même cherche en priorité dans :

```
/var/lib/combo/tenants/<tenant>/templates/variants/<theme>/
/var/lib/combo/tenants/<tenant>/theme/templates/variants/<theme>/
/var/lib/combo/tenants/<tenant>/templates/
/var/lib/combo/tenants/<tenant>/theme/templates/
```

Le dossier `/var/lib/combo/tenants/<tenant>/theme/` est un lien symbolique vers
`/usr/share/publik/themes/publik-base`.

Si un template est surchargé dans le thème personnalisé, il sera chargé via
lors de la lecture de `/var/lib/combo/tenants/<tenant>/theme/templates/variants/<theme>/`.
Les autres templates seront récupérés dans `/var/lib/combo/tenants/<tenant>/theme/templates/`,
c'est-à-dire dans le thème de base.

Des exemples sont disponibles [ici](https://github.com/Vayel/publik-docker-themes).

Il est important, dans les thèmes personnalisés, de ne redéfinir que ce qui a
besoin de l'être. Copier/coller des templates du thème de base sans les modifier
fait que vous ne profiterez pas des mises à jour.

Il convient de ce fait de ne redéfinir que les blocs souhaités d'un template,
pas tout le template. Par exemple, pour personnaliser le pied de page :

```html
{% extends "theme.html" %}

{% block footer-top %}
Blablabla
{% endblock %}
```

Ici, le `extends` ira chercher `/var/lib/combo/tenants/<tenant>/theme/templates/theme.html`,
c'est-à-dire le fichier `theme.html` du [thème de base](https://repos.entrouvert.org/publik-base-theme.git/tree/templates/theme.html).

### `themes.json`

Le fichier `themes.json` liste les thèmes utilisables par Publik, qui se base sur
la clé `id` :

```json
[
  {
    "id": "publik",
    "label": "Publik",
    "variables": {
      "css_variant": "publik",
      "theme_color": "#E80E89"
    }
  },
  {
    "id": "mon_theme",
    "label": "Mon thème",
    "variables": {
      "css_variant": "mon_theme",
      "theme_color": "#AEC900",
      "une_autre_variable_utilisee_dans_les_templates": "une valeur"
    }
  },
  {
    "id": "mon_autre_theme",
    "label": "Mon autre thème",
    "variables": {
      "css_variant": "mon_autre_theme",
      "theme_color": "#000000",
      "une_variable": "une valeur"
    }
  }
]
```

**Attention :** seuls les thèmes listés dans `themes.json` seront disponibles dans
Publik. Un thème dans le dossier `themes` mais pas dans `themes.json` n'apparaîtra
pas.

Un objet suit le schéma suivant :

* `id` : le nom du dossier du thème dans `themes`
* `css_variant` : désigne le sous-dossier dans `static` où Django récupérera les fichiers statiques. Ici, **identique à `id`**.
* `theme_color` : variable utilisée dans les templates du thème de base
* `une_autre_variable_utilisee_dans_les_templates`, `une_variable`... : des variables utilisables dans les templates du thème personnalisé

Il est conseillé de stocker ses thèmes dans un dépôt git dédié et de les placer
dans `data/themes` avec un `git clone`.

## Associer un thème à une collectivité

```
./manage/publik/set-theme.sh <theme_id> [<org>]
```

Peut aussi être fait depuis l'interface web : 

```
# Theme de la collectivite par defaut
https://hobo.<monserveurpublik.fr>/theme/

# Theme de la collectivite "ma-commune"
https://ma-commune.hobo.<monserveurpublik.fr>/theme/
```

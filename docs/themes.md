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
    templates/
  mon_autre_theme/
    static/
    templates/
themes.json
```

Chaque thème est une extension du [thème Publik de base](https://repos.entrouvert.org/publik-base-theme.git/tree/).

Le dossier `static` d'un thème doit contenir un fichier`style.scss`, qui sera compilé
avec les [fichiers statiques du thème de base](https://repos.entrouvert.org/publik-base-theme.git/tree/static/publik).
Des exemples sont disponibles [ici](https://github.com/Vayel/publik-docker-themes).

Le dossier `templates` d'un thème suit la même architecture que les [templates
du thème de base](https://repos.entrouvert.org/publik-base-theme.git/tree/templates).
Il ne contient que les fichiers HTML spécifiques au thème ; ceux non surchargés
seront récupérés dans le thème de base.
Des exemples sont disponibles [ici](https://github.com/Vayel/publik-docker-themes).

Il est important, dans les thèmes personnalisés, de ne redéfinir que ce qui a
besoin de l'être. Copier/coller des templates du thème de base sans les modifier
fait que vous ne profiterez pas des mises à jour.

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

---
layout: default
thumbnail: ggplot2.png
category: Exploration des données
title: "Visualisation rapide des données avec ggplot2"
author: "Charles Martin"
date: "September 2018"
output:
  html_document:
    highlight: haddock
    keep_md: yes
    theme: readable
    toc: yes
en_url : "/en/workshops/RapidDataViz"
---

# Visualisation rapide des données avec ggplot2
{:.no_toc}
#### Charles Martin
{:.no_toc}
#### Septembre 2018
{:.no_toc}
* TOC
{:toc}

Clarification
============

Tout ce que nous ferons aujourd'hui pourrait aussi s'accomplir avec les
graphiques de base de R.

L'avantage de ggplot2 est qu'on passe moins de temps à programmer
(création de boucles, gestion de tableaux, conditions etc.) et plus de temps
à visualiser les données.

Conditions pour apprécier votre temps avec ggplot2
==========
* Besoin de données rectangulaires et propres (*tidy data*)
* Ne combattez pas le paradigme, ggplot2 n'est pas la même chose que les
graphiques de base avec d'autres noms
* Prenez le temps de bien comprendre la structure type d'un graphique ggplot2
* Imprimez l'aide-mémoire (cheat-sheet)
* N'ayez pas peur d'insérer des sauts de lignes et des tabulations pour
clarifier votre code

Notre jeu de données
============

```r
library(ggplot2)
```

```
Warning: package 'ggplot2' was built under R version 3.5.2
```

```r
data(msleep)
summary(msleep)
```

```
     name              genus               vore          
 Length:83          Length:83          Length:83         
 Class :character   Class :character   Class :character  
 Mode  :character   Mode  :character   Mode  :character  




    order           conservation        sleep_total      sleep_rem    
 Length:83          Length:83          Min.   : 1.90   Min.   :0.100  
 Class :character   Class :character   1st Qu.: 7.85   1st Qu.:0.900  
 Mode  :character   Mode  :character   Median :10.10   Median :1.500  
                                       Mean   :10.43   Mean   :1.875  
                                       3rd Qu.:13.75   3rd Qu.:2.400  
                                       Max.   :19.90   Max.   :6.600  
                                                       NA's   :22     
  sleep_cycle         awake          brainwt            bodywt        
 Min.   :0.1167   Min.   : 4.10   Min.   :0.00014   Min.   :   0.005  
 1st Qu.:0.1833   1st Qu.:10.25   1st Qu.:0.00290   1st Qu.:   0.174  
 Median :0.3333   Median :13.90   Median :0.01240   Median :   1.670  
 Mean   :0.4396   Mean   :13.57   Mean   :0.28158   Mean   : 166.136  
 3rd Qu.:0.5792   3rd Qu.:16.15   3rd Qu.:0.12550   3rd Qu.:  41.750  
 Max.   :1.5000   Max.   :22.10   Max.   :5.71200   Max.   :6654.000  
 NA's   :51                       NA's   :27                          
```

83 observations tirées de la littérature sur le temps de sommeil des mammifères.

* Entre autres des mesures sur le sommeil (en heures) :
    + `sleep_total`
    + `sleep_rem` (temps de sommeil paradoxal)
    + `sleep_cycle`
    + `awake`
* Et sur d'autres caractéristiques (en kg) :
    * `brainwt`
    * `bodywt`


Un premier graphique
============

```r
ggplot(data = msleep) +
  geom_point(mapping = aes(x = sleep_rem, y = awake))
```

```
Warning: Removed 22 rows containing missing values (geom_point).
```

![](/assets/RapidDataViz_files/figure-html/unnamed-chunk-3-1.png)<!-- -->

NB on peut insérer des sauts de lignes et des tabulations
n'importe où dans le code R, du moment que c'est clair pour R qu'il faut
qu'il attende la suite de l'instruction.

`ggplot` : créé l'objet graphique et y associe le tableau de données.
On ajoute ensuite des couches à cet objet.

`mapping` : crée l'association entre les variables du tableau de données
et les propriétés visuelles (aes) du graphique

Quelles autres propriétés graphiques sont disponibles?
=================
Entre autres...

* `color`
* `size`
* `alpha` (transparence, 0-1)
* `shape` (max 6)

L'association entre les propriétés (`color` et `shape`) et les valeurs dans le
tableau de données se nomme le "mapping"

Elles permettent d'ajouter des dimensions d'information supplémentaires, au
delà de la position.

Exemple
========
Nous pouvons refaire le graphique précédent, mais en ajouter une couleur
par type d'alimentation (`vore`) et que la taille des points soit
proportionnelle à la
taille du corps de l'animal (`bodywt`)


```r
ggplot(data = msleep) +
  geom_point(mapping = aes(
    x = sleep_rem,
    y = awake,
    color = vore,
    size = bodywt
  )
)
```

```
Warning: Removed 22 rows containing missing values (geom_point).
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-4-1.png" style="display: block; margin: auto;" />

Pour modifier l'ensemble des points
===============
Il faut spécifier la propriété visuelle à l'extérieur du bloc `aes`, p. ex.

```r
ggplot(data = msleep) +
  geom_point(
    mapping = aes(
      x = sleep_rem,
      y = awake,
      size = bodywt
    ),
    color = "blue",
    shape = 17
)
```

```
Warning: Removed 22 rows containing missing values (geom_point).
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-5-1.png" style="display: block; margin: auto;" />

Exercice #1
===============
Faites un graphique du poids du cerveau (`brainwt`) en fonction du poids total
de l'animal (`bodywt`)

Remplacez les points par des carrés

La couleur du point doit représenter le statut de conservation (`conservation`)

Là où ggplot est particulièrement efficace
=================
Traçons d'abord un grahpique du temps d'éveil (`awake`) en fonction du
temps de sommeil paradoxal (`sleep_rem`).

```r
ggplot(data = msleep) +
  geom_point(mapping = aes(
    x = sleep_rem,
    y = awake
  )
)
```

```
Warning: Removed 22 rows containing missing values (geom_point).
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-6-1.png" style="display: block; margin: auto;" />

Ajouter une couleur par type d'alimentation (`vore`)

```r
ggplot(data = msleep) +
  geom_point(mapping = aes(
    x = sleep_rem,
    y = awake,
    color = vore
  )
)
```

```
Warning: Removed 22 rows containing missing values (geom_point).
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-7-1.png" style="display: block; margin: auto;" />

Maintenant un collègue passe derrière-vous et se demande si le graphique
serait plus clair avec un panneau par type d'alimentation

```r
ggplot(data = msleep) +
  geom_point(mapping = aes(
    x = sleep_rem,
    y = awake
  )) +
  facet_wrap(~vore)
```

```
Warning: Removed 22 rows containing missing values (geom_point).
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-8-1.png" style="display: block; margin: auto;" />

>Ok, non, finalement c'était mieux dans un seul graphique, mais peux-tu
ajouter une courbe de lissage par groupe pour voir si la tendance est la même?


```r
ggplot(data = msleep) +
  geom_point(mapping = aes(
    x = sleep_rem,
    y = awake,
    color = vore
  )) +
  geom_smooth(mapping = aes(
    x = sleep_rem,
    y = awake,
    color = vore
  )
  )
```

```
`geom_smooth()` using method = 'loess' and formula 'y ~ x'
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-9-1.png" style="display: block; margin: auto;" />

>Ouin, c'est trop un fouilli, peux-tu me mettre juste des régressions
linéaires finalement?


```r
ggplot(data = msleep) +
  geom_point(mapping = aes(
    x = sleep_rem,
    y = awake,
    color = vore
  )) +
  geom_smooth(
    mapping = aes(
      x = sleep_rem,
      y = awake,
      color = vore
    ),
    method = "lm",
    se = FALSE
  )
```

```
Warning: Removed 22 rows containing non-finite values (stat_smooth).
```

```
Warning: Removed 22 rows containing missing values (geom_point).
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-10-1.png" style="display: block; margin: auto;" />

Pour éviter la duplication, les *mappings* globaux
---------
Si vous voulez réutiliser des associations entre les propriétés graphiques et
vos données dans plusieurs couches, vous pouvez les mentionner lors de la
création de l'objet `ggplot` :


```r
ggplot(data = msleep, mapping = aes(
    x = sleep_rem,
    y = awake,
    color = vore
  )) +
  geom_point() +
  geom_smooth(
    method = "lm",
    se = FALSE
  )
```

```
Warning: Removed 22 rows containing non-finite values (stat_smooth).
```

```
Warning: Removed 22 rows containing missing values (geom_point).
```

Et pour condenser votre code encore plus
----------
Vous pouvez profiter du fait que dans R, le nom des arguments est optionel, du
moment que vous respectez l'ordre spécifié dans la documentation (`?ggplot`):

>Usage
>
>`ggplot(data = NULL, mapping = aes(), ..., environment = parent.frame())`

Ce qui permet de faire :

```r
ggplot(msleep, aes(
    x = sleep_rem,
    y = awake,
    color = vore
  )) +
  geom_point() +
  geom_smooth(
    method = "lm",
    se = FALSE
  )
```

```
Warning: Removed 22 rows containing non-finite values (stat_smooth).
```

```
Warning: Removed 22 rows containing missing values (geom_point).
```


Quelles couches graphiques sont disponibles?
=========

Une variable continue
------


```r
ggplot(msleep) +
  geom_histogram(aes(x = awake))
```

```
`stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-13-1.png" style="display: block; margin: auto;" />
Prenez note de l'avertissement pour le nombre de bandes de l'histogramme

Une variable catégorique / discrète
----------

```r
ggplot(msleep) +
  geom_bar(aes(x = vore))
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-14-1.png" style="display: block; margin: auto;" />

Attention, si vos valeurs sont déjà compilées, il faut plutôt passer par un
autre *geom*, p. ex.

```r
x <- data.frame(
  totaux = c(4,1,2),
  etiquettes = c("Contrôle", "pH+", "pH-")
)
ggplot(x) +
  geom_col(aes(x = etiquettes, y = totaux))
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-15-1.png" style="display: block; margin: auto;" />

Deux variables continues
----------

```r
ggplot( msleep) +
  geom_point(aes(x = sleep_rem, y = awake))
```

```
Warning: Removed 22 rows containing missing values (geom_point).
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-16-1.png" style="display: block; margin: auto;" />

On peut aussi remplacer les points par du texte

```r
ggplot(msleep) +
  geom_text(aes(x = sleep_rem, y = awake, label = genus))
```

```
Warning: Removed 22 rows containing missing values (geom_text).
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-17-1.png" style="display: block; margin: auto;" />

Une variable continue et une discrète
------------------


```r
ggplot(msleep) +
  geom_boxplot(aes(x = vore, y = awake))
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-18-1.png" style="display: block; margin: auto;" />

Ou de plus en plus utilisé, le violin plot

```r
ggplot(msleep) +
  geom_violin(
    aes(x = vore, y = awake)
  )
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-19-1.png" style="display: block; margin: auto;" />


```r
ggplot(msleep) +
  geom_dotplot(
    aes(x = vore, y = awake),
    binaxis = "y",
    stackdir = "center"
  )
```

```
`stat_bindot()` using `bins = 30`. Pick better value with `binwidth`.
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-20-1.png" style="display: block; margin: auto;" />

Deux variables discrètes
------

```r
ggplot(msleep) +
  geom_bar(aes(x = vore, fill = conservation))
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-21-1.png" style="display: block; margin: auto;" />

### Modificateurs de position
On peut utiliser le modificateur de position pour organiser le diagramme à
bandes d'autres façons

```r
ggplot(msleep) +
  geom_bar(
    aes(x = vore, fill = conservation),
    position = "dodge"
  )
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-22-1.png" style="display: block; margin: auto;" />

```r
ggplot(msleep) +
  geom_bar(
    aes(x = vore, fill = conservation),
    position = "fill"
  )
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-22-2.png" style="display: block; margin: auto;" />

Si vous avez des millions de points
=============


```r
n <- 1000000
x <- runif(n)
y <- 3 + 2*x + rnorm(n)
df <- data.frame(
  x = x,
  y = y
)

ggplot(df,aes(x = x, y = y)) + geom_bin2d()
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-23-1.png" style="display: block; margin: auto;" />

Visualisation de l'incertitude
===============

```r
df <- data.frame(
  x = c(1,2,3,4),
  y = c(1.1,1.9,3.4,4),
  se = c(0.4, 0.5, 0.7, 0.5)
)

ggplot(df, aes(x = x, y = y)) +
  geom_point() +
  geom_errorbar(
    aes(ymin = y - se, ymax = y + se),
    width = 0.3
  )
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-24-1.png" style="display: block; margin: auto;" />

```r
ggplot(df, aes(x = x, y = y)) +
  geom_point() +
  geom_linerange(
    aes(ymin = y - se, ymax = y + se)
  )
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-24-2.png" style="display: block; margin: auto;" />

```r
ggplot(df, aes(x = x, y = y)) +
  geom_ribbon(
    aes(ymin = y - se, ymax = y + se),
    fill = "tomato"
  ) +
  geom_line()
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-24-3.png" style="display: block; margin: auto;" />

Exercice #2
============
À l'aide des outils vus dans les dernières sections, reproduisez cette façon
classique (mais peu recommandable!) de visualiser la différence entre les
groupes, à l'aide des données suivantes :

```r
df <- data.frame(
  x = c(1,2,3,4),
  y = c(1.1,1.9,3.4,4),
  se = c(0.4, 0.5, 0.7, 0.5)
)
```
<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-26-1.png" style="display: block; margin: auto;" />

L'outil d'exploration ultime
==============

```r
library(GGally)
ggpairs(msleep[,-c(1,2,4)])
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-27-1.png" style="display: block; margin: auto;" />

```r
ggpairs(msleep[,-c(1,2,4)], aes(col = vore))
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-27-2.png" style="display: block; margin: auto;" />

Transformations rapides (sans toucher aux données)
==========
On peut ajouter une transformation des axes comme un élément supplémentaire
du graphique...

```r
ggplot(msleep) +
  geom_point(aes(x = bodywt, y = brainwt))
```

```
Warning: Removed 27 rows containing missing values (geom_point).
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-28-1.png" style="display: block; margin: auto;" />

```r
ggplot(msleep) +
  geom_point(aes(x = bodywt, y = brainwt)) +
  scale_x_log10() +
  scale_y_log10()
```

```
Warning: Removed 27 rows containing missing values (geom_point).
```

<img src="/assets/RapidDataViz_files/figure-html/unnamed-chunk-29-1.png" style="display: block; margin: auto;" />

Il existe aussi `scale_x_reverse` et `scale_x_sqrt`

Avant de fignoler, apprendre à bien sauvegarder...
==============

La fonction `ggsave` permet d'envoyer dans un fichier le dernier graphique
produit

```r
ggplot(msleep) +
  geom_point(aes(x = sleep_rem, y = sleep_cycle))
```

```r
ggsave(filename = "/assets/RapidDataViz_files/Resultats/Fig1.jpg")
```

```
Saving 7 x 5 in image
```

NB le nom du dossier dans lequel vous tentez d'écrire doit déjà exister...

Le type de fichier est choisi automatiquement à l'aide de l'extension choisie
(pdf, jpg, png, eps, etc.)

## Comment déterminer les dimensions?
Pas d'autres solutions que d'y aller par essai/erreur. ggplot change la taille
relative des points, du texte etc. selon les dimensions désirées, vous devrez
expérimenter.


```r
ggsave(filename = "/assets/RapidDataViz_files/Resultats/2x2.jpg", width = 2, height = 2)
ggsave(filename = "/assets/RapidDataViz_files/Resultats/8x8.jpg", width = 8, height = 8)
```

<img src="/assets/RapidDataViz_files/Resultats/2x2.jpg" style="float:left;width:50%" >
<img src="/assets/RapidDataViz_files/Resultats/8x8.jpg" style="float:left;width:50%">
<br clear = "both"/>

Par défaut les unités sont en pouces, mais vous pouvez les changer pour de cm
avec l'argument `units="cm"`

## Comment modifier la résolution

Pour les fichiers qui ne sont pas vectoriels (p. ex. jpg, png), vous pouvez
aussi spécifier la qualité d'image, en nombre de points par pouces
(dot per inches; dpi)

```r
ggsave(filename = "/assets/RapidDataViz_files/Resultats/72.jpg", width = 2, height = 2, dpi = 72)
ggsave(filename = "/assets/RapidDataViz_files/Resultats/1200.jpg", width = 2, height = 2, dpi = 1200)
```
<img src="/assets/RapidDataViz_files/Resultats/72.jpg" style="float:left;width:50%" >
<img src="/assets/RapidDataViz_files/Resultats/1200.jpg" style="float:left;width:50%">
<br clear = "both"/>

On recommande souvent 300 dpi pour des graphiques qui seront reproduits en
version papier...

Et finalement, le fameux fond gris...
=========


```r
ggplot(msleep) +
  geom_point(aes(x = sleep_rem, y = sleep_cycle)) +
  theme_classic()
```

![](/assets/RapidDataViz_files/figure-html/unnamed-chunk-33-1.png)<!-- -->

```r
ggplot(msleep) +
  geom_point(aes(x = sleep_rem, y = sleep_cycle)) +
  theme_dark()
```

![](/assets/RapidDataViz_files/figure-html/unnamed-chunk-33-2.png)<!-- -->

```r
ggplot(msleep) +
  geom_point(aes(x = sleep_rem, y = sleep_cycle)) +
  theme_minimal()
```

![](/assets/RapidDataViz_files/figure-html/unnamed-chunk-33-3.png)<!-- -->

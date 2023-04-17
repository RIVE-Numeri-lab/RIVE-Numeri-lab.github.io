---
layout: default
category: Stats
thumbnail: Rlogo.png
title: "Méta-analyses"
author: "Charles Martin"
date: "December 2019"
output:
  html_document:
    highlight: haddock
    keep_md: yes
    theme: readable
    toc: yes
en_url: "/en/workshops/MetaAnalysis"
---
# Méta-analyses
{:.no_toc}
#### Charles Martin
{:.no_toc}
#### Décembre 2019
{:.no_toc}

* TOC
{:toc}

```r
library(dplyr) # data manipulation
library(ggplot2) # visualisations
library(metafor) # meta analyses déjà prêtes
library(gt) # beaux tableaux
```
# Principe
## Question de départ
Question de départ : Est-ce que jouer du Mozart aux nouveaux-nés augmente leur QI?

Vous trouvez 3 études :

```r
etudes <- data.frame(
  article = c("A","B","C"),
  y = c(0.5, 0.01, -0.1), # 0 pas d'effet, <0 effet négatif, >0 effet positif
  n = c(10,150,12),
  v = c(0.04,0.01, 0.03) # variance
)
etudes %>% gt
```

<!--html_preserve--><style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#crthyfcstu .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #000000;
  font-size: 16px;
  background-color: #FFFFFF;
  /* table.background.color */
  width: auto;
  /* table.width */
  border-top-style: solid;
  /* table.border.top.style */
  border-top-width: 2px;
  /* table.border.top.width */
  border-top-color: #A8A8A8;
  /* table.border.top.color */
}

#crthyfcstu .gt_heading {
  background-color: #FFFFFF;
  /* heading.background.color */
  border-bottom-color: #FFFFFF;
}

#crthyfcstu .gt_title {
  color: #000000;
  font-size: 125%;
  /* heading.title.font.size */
  padding-top: 4px;
  /* heading.top.padding */
  padding-bottom: 1px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#crthyfcstu .gt_subtitle {
  color: #000000;
  font-size: 85%;
  /* heading.subtitle.font.size */
  padding-top: 1px;
  padding-bottom: 4px;
  /* heading.bottom.padding */
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#crthyfcstu .gt_bottom_border {
  border-bottom-style: solid;
  /* heading.border.bottom.style */
  border-bottom-width: 2px;
  /* heading.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* heading.border.bottom.color */
}

#crthyfcstu .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  padding-top: 4px;
  padding-bottom: 4px;
}

#crthyfcstu .gt_col_heading {
  color: #000000;
  background-color: #FFFFFF;
  /* column_labels.background.color */
  font-size: 16px;
  /* column_labels.font.size */
  font-weight: initial;
  /* column_labels.font.weight */
  vertical-align: middle;
  padding: 10px;
  margin: 10px;
}

#crthyfcstu .gt_sep_right {
  border-right: 5px solid #FFFFFF;
}

#crthyfcstu .gt_group_heading {
  padding: 8px;
  color: #000000;
  background-color: #FFFFFF;
  /* row_group.background.color */
  font-size: 16px;
  /* row_group.font.size */
  font-weight: initial;
  /* row_group.font.weight */
  border-top-style: solid;
  /* row_group.border.top.style */
  border-top-width: 2px;
  /* row_group.border.top.width */
  border-top-color: #A8A8A8;
  /* row_group.border.top.color */
  border-bottom-style: solid;
  /* row_group.border.bottom.style */
  border-bottom-width: 2px;
  /* row_group.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* row_group.border.bottom.color */
  vertical-align: middle;
}

#crthyfcstu .gt_empty_group_heading {
  padding: 0.5px;
  color: #000000;
  background-color: #FFFFFF;
  /* row_group.background.color */
  font-size: 16px;
  /* row_group.font.size */
  font-weight: initial;
  /* row_group.font.weight */
  border-top-style: solid;
  /* row_group.border.top.style */
  border-top-width: 2px;
  /* row_group.border.top.width */
  border-top-color: #A8A8A8;
  /* row_group.border.top.color */
  border-bottom-style: solid;
  /* row_group.border.bottom.style */
  border-bottom-width: 2px;
  /* row_group.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* row_group.border.bottom.color */
  vertical-align: middle;
}

#crthyfcstu .gt_striped {
  background-color: #f2f2f2;
}

#crthyfcstu .gt_from_md > :first-child {
  margin-top: 0;
}

#crthyfcstu .gt_from_md > :last-child {
  margin-bottom: 0;
}

#crthyfcstu .gt_row {
  padding: 10px;
  /* row.padding */
  margin: 10px;
  vertical-align: middle;
}

#crthyfcstu .gt_stub {
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #A8A8A8;
  padding-left: 12px;
}

#crthyfcstu .gt_stub.gt_row {
  background-color: #FFFFFF;
}

#crthyfcstu .gt_summary_row {
  background-color: #FFFFFF;
  /* summary_row.background.color */
  padding: 6px;
  /* summary_row.padding */
  text-transform: inherit;
  /* summary_row.text_transform */
}

#crthyfcstu .gt_first_summary_row {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
}

#crthyfcstu .gt_table_body {
  border-top-style: solid;
  /* table_body.border.top.style */
  border-top-width: 2px;
  /* table_body.border.top.width */
  border-top-color: #A8A8A8;
  /* table_body.border.top.color */
  border-bottom-style: solid;
  /* table_body.border.bottom.style */
  border-bottom-width: 2px;
  /* table_body.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* table_body.border.bottom.color */
}

#crthyfcstu .gt_footnote {
  font-size: 90%;
  /* footnote.font.size */
  padding: 4px;
  /* footnote.padding */
}

#crthyfcstu .gt_sourcenote {
  font-size: 90%;
  /* sourcenote.font.size */
  padding: 4px;
  /* sourcenote.padding */
}

#crthyfcstu .gt_center {
  text-align: center;
}

#crthyfcstu .gt_left {
  text-align: left;
}

#crthyfcstu .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#crthyfcstu .gt_font_normal {
  font-weight: normal;
}

#crthyfcstu .gt_font_bold {
  font-weight: bold;
}

#crthyfcstu .gt_font_italic {
  font-style: italic;
}

#crthyfcstu .gt_super {
  font-size: 65%;
}

#crthyfcstu .gt_footnote_glyph {
  font-style: italic;
  font-size: 65%;
}
</style>
<div id="crthyfcstu" style="overflow-x:auto;"><!--gt table start-->
<table class='gt_table'>
<tr>
<th class='gt_col_heading gt_center' rowspan='1' colspan='1'>article</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>y</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>n</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>v</th>
</tr>
<tbody class='gt_table_body'>
<tr>
<td class='gt_row gt_center'>A</td>
<td class='gt_row gt_right'>0.50</td>
<td class='gt_row gt_right'>10</td>
<td class='gt_row gt_right'>0.04</td>
</tr>
<tr>
<td class='gt_row gt_center gt_striped'>B</td>
<td class='gt_row gt_right gt_striped'>0.01</td>
<td class='gt_row gt_right gt_striped'>150</td>
<td class='gt_row gt_right gt_striped'>0.01</td>
</tr>
<tr>
<td class='gt_row gt_center'>C</td>
<td class='gt_row gt_right'>-0.10</td>
<td class='gt_row gt_right'>12</td>
<td class='gt_row gt_right'>0.03</td>
</tr>
</tbody>
</table>
<!--gt table end-->
</div><!--/html_preserve-->

## Façon bête

```r
etudes %>%
  summarise(
    effet_resume = mean(y)
  )
```

```
  effet_resume
1    0.1366667
```

## Moyenne pondérée
Moyenne arithmétique standard

```r
(1 + 2 + 3 + 4) / 4
```

```
[1] 2.5
```

Implicitement, on donne un poids égal à chaque élément :

```r
(1*1 + 1*2 + 1*3 + 1*4) / (1 + 1 + 1 + 1)
```

```
[1] 2.5
```

Mais on aurait pu donner un poids plus grand à certains éléments, p. ex. donner plus de poids aux plus récents

```r
(0.125*1 + 0.25*2 + 0.5*3 + 1*4) / (0.125 + 0.25 + 0.5 + 1)
```

```
[1] 3.266667
```

Il existe une fonction de R qui nous permet de faire ce travail :

```r
weighted.mean(
  c(1,2,3,4),
  c(0.125,0.25,0.5,1)
)
```

```
[1] 3.266667
```

## La méta-analyse est une moyenne pondérée
Plus une étude est précise, plus son poids sera élevé dans le calcul de l'effet moyen

Une des façons classiques est d'utiliser comme poids l'inverse de la variance.

### ATTENTION : il existe deux définitions de *variance*

La variance classique d'un échantillon est habituellement définie par :
`v = sum( (x-mean(x))^2 / (length(x)-1) )`

Celle-ci nous permet de calculer l'écart-type d'un échantillon : `sd = sqrt(v)`.

Ces deux mesures sont des statistiques descriptives.

On se rapelle que, pour passer de l'écart-type d'un échantillon à l'erreur type d'un paramètre (l'erreur autour de son estimé), on utilise la formule :

`se = sd / sqrt(n)`

Par contre, dans le livre de Borenstein, lorsque l'on parle de variance, on parle plutôt de la variance autour d'un estimé (la variance de l'erreur, *sampling variance*), qui correspond à l'erreur type au carré :
`v = se^2`

## Exemples de calculs
Et donc, on peut calculer notre première méta-analyse comme ceci :

```r
etudes %>%
  summarise(
    effet_pondere = weighted.mean(y,1/v)
  )
```

```
  effet_pondere
1    0.06421053
```
Avec le package `metafor`, on a le même calcul :

```r
m <- rma(
  yi = y,
  vi = v,
  data = etudes,
  method = "FE"
)
m
```

```

Fixed-Effects Model (k = 3)

Test for Heterogeneity:
Q(df = 2) = 5.9405, p-val = 0.0513

Model Results:

estimate      se    zval    pval    ci.lb   ci.ub   
  0.0642  0.0795  0.8080  0.4191  -0.0916  0.2200   

---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```
Mais en plus on obtient un intervalle de confiance autour de notre valeur moyenne (et d'autres choses que l'on verra plus tard).

Dans notre cas, l'intervalle de confiance à 95% de notre effet n'exlut pas zéro, donc pas d'effet significatif de jouer du Mozart aux nouveaux-nés

# Sélection des études
Toujours mieux d'utiliser une méthode reproductible, p. ex. de définir une recherche dans Scopus (https://www2.scopus.com/search/form.uri?display=basic):
`TITLE-ABS-KEY ( music  AND  ( baby  OR  toddler  OR  newborn )  AND  ( iq  OR  intelligence ) ) `

Puis exportez cette liste d'articles pour *figer* votre recherche.

Il est souvent recommandé d'inspecter la bibliographie de chacun des articles pour être certains que vous n'avez rien manqué.

Aussi, gardez une trace détaillée de toutes les étapes de construction et d'élimination. Vous aurez besoin de les citer dans le texte (ou sous forme la d'un diagramme PRISMA). P. ex.

* nb. articles trouvés dans la recherche Scopus
* nb. articles ajoutés à partir des bibliographies
* nb. doublons éliminés
* nb. d'articles éliminés à la lecture du résumé
* nb. d'articles éliminés pour d'autres critères (mauvais groupe taxonomique, manque de données, méthodes douteuses etc.)
* nb. d'articles inclus dans la méta-analyse
* nb. nombre de lignes/études inclus

# Taille de l'effet

## Problématique
Il est peu probable que l'ensemble de vos études aient mesuré l'effet recherché exactement de la même manière.

Dans notre exemple, on pourrait retrouver :

* une corrélation entre le nombre d'heures de musique par semaine et le QI
* un test de T entre les groupes avec et sans musique
* une pente entre le nombre de pièces musicales par jour et le QI
* une pente entre le nombre de disques de musique classique possédé par les parents et le QI

Une mesure comme la corrélation ne possède pas d'échelle, mais les autres sont dépendantes de la façon dont elles ont été mesurées et devront être standardisées pour être comparées

## Standardisation de la taille des effets
Il existe des dizaines de façons de standardiser les mesures, selon que l'on parle de différences de moyennes, de pentes, de comparaisons de proportions, etc.

Dans tous les cas, l'idée est de trouver une mesure qui fait abstraction de l'échelle.

P. ex., pour les différences de moyennes, on utilise souvent le *d* de Cohen. Son calcul ressemble beaucoup au calcul de la statistique de *t* :

`d = (x1 - x2) / S_within`

Pour chacune de ces mesures de taille d'effet, il existe aussi une mesure de variance (*sensu* Borenstein et al. 2011).

`V_d = (n1 + n2 / n1*n2) + (d^2 / 2*(n1+n2))`

Parfois, certaines mesures doivent aussi être converties parce que leur distribution ne convient pas à des calculs de méta-analyse. P. ex., le *r* de la corrélation doit être convertit en *z* de Fisher, parce que la variance de *r* n'est pas homogène à travers le spectre des valeurs.

`z = 0.5 * log((1+r)/(1-r))`

`V_z = 1/(n-3)`

## Automatisation
Il existe une fonction dans metafor qui permet de faciliter le calcul des effets standardisés. Par contre, il faut que toutes nos mesures soient d'un même type (p. ex. toutes des corrélations)

```r
etudes2 <- data.frame(
  etude = c("A","B"),
  r = c(0.6, -0.2),
  n = c(32,16)
)
escalc(
  measure = "ZCOR",
  ri = r,
  ni = n,
  data = etudes2
) %>%
  gt
```

<!--html_preserve--><style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#nytxbtsfzy .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #000000;
  font-size: 16px;
  background-color: #FFFFFF;
  /* table.background.color */
  width: auto;
  /* table.width */
  border-top-style: solid;
  /* table.border.top.style */
  border-top-width: 2px;
  /* table.border.top.width */
  border-top-color: #A8A8A8;
  /* table.border.top.color */
}

#nytxbtsfzy .gt_heading {
  background-color: #FFFFFF;
  /* heading.background.color */
  border-bottom-color: #FFFFFF;
}

#nytxbtsfzy .gt_title {
  color: #000000;
  font-size: 125%;
  /* heading.title.font.size */
  padding-top: 4px;
  /* heading.top.padding */
  padding-bottom: 1px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#nytxbtsfzy .gt_subtitle {
  color: #000000;
  font-size: 85%;
  /* heading.subtitle.font.size */
  padding-top: 1px;
  padding-bottom: 4px;
  /* heading.bottom.padding */
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#nytxbtsfzy .gt_bottom_border {
  border-bottom-style: solid;
  /* heading.border.bottom.style */
  border-bottom-width: 2px;
  /* heading.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* heading.border.bottom.color */
}

#nytxbtsfzy .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  padding-top: 4px;
  padding-bottom: 4px;
}

#nytxbtsfzy .gt_col_heading {
  color: #000000;
  background-color: #FFFFFF;
  /* column_labels.background.color */
  font-size: 16px;
  /* column_labels.font.size */
  font-weight: initial;
  /* column_labels.font.weight */
  vertical-align: middle;
  padding: 10px;
  margin: 10px;
}

#nytxbtsfzy .gt_sep_right {
  border-right: 5px solid #FFFFFF;
}

#nytxbtsfzy .gt_group_heading {
  padding: 8px;
  color: #000000;
  background-color: #FFFFFF;
  /* row_group.background.color */
  font-size: 16px;
  /* row_group.font.size */
  font-weight: initial;
  /* row_group.font.weight */
  border-top-style: solid;
  /* row_group.border.top.style */
  border-top-width: 2px;
  /* row_group.border.top.width */
  border-top-color: #A8A8A8;
  /* row_group.border.top.color */
  border-bottom-style: solid;
  /* row_group.border.bottom.style */
  border-bottom-width: 2px;
  /* row_group.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* row_group.border.bottom.color */
  vertical-align: middle;
}

#nytxbtsfzy .gt_empty_group_heading {
  padding: 0.5px;
  color: #000000;
  background-color: #FFFFFF;
  /* row_group.background.color */
  font-size: 16px;
  /* row_group.font.size */
  font-weight: initial;
  /* row_group.font.weight */
  border-top-style: solid;
  /* row_group.border.top.style */
  border-top-width: 2px;
  /* row_group.border.top.width */
  border-top-color: #A8A8A8;
  /* row_group.border.top.color */
  border-bottom-style: solid;
  /* row_group.border.bottom.style */
  border-bottom-width: 2px;
  /* row_group.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* row_group.border.bottom.color */
  vertical-align: middle;
}

#nytxbtsfzy .gt_striped {
  background-color: #f2f2f2;
}

#nytxbtsfzy .gt_from_md > :first-child {
  margin-top: 0;
}

#nytxbtsfzy .gt_from_md > :last-child {
  margin-bottom: 0;
}

#nytxbtsfzy .gt_row {
  padding: 10px;
  /* row.padding */
  margin: 10px;
  vertical-align: middle;
}

#nytxbtsfzy .gt_stub {
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #A8A8A8;
  padding-left: 12px;
}

#nytxbtsfzy .gt_stub.gt_row {
  background-color: #FFFFFF;
}

#nytxbtsfzy .gt_summary_row {
  background-color: #FFFFFF;
  /* summary_row.background.color */
  padding: 6px;
  /* summary_row.padding */
  text-transform: inherit;
  /* summary_row.text_transform */
}

#nytxbtsfzy .gt_first_summary_row {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
}

#nytxbtsfzy .gt_table_body {
  border-top-style: solid;
  /* table_body.border.top.style */
  border-top-width: 2px;
  /* table_body.border.top.width */
  border-top-color: #A8A8A8;
  /* table_body.border.top.color */
  border-bottom-style: solid;
  /* table_body.border.bottom.style */
  border-bottom-width: 2px;
  /* table_body.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* table_body.border.bottom.color */
}

#nytxbtsfzy .gt_footnote {
  font-size: 90%;
  /* footnote.font.size */
  padding: 4px;
  /* footnote.padding */
}

#nytxbtsfzy .gt_sourcenote {
  font-size: 90%;
  /* sourcenote.font.size */
  padding: 4px;
  /* sourcenote.padding */
}

#nytxbtsfzy .gt_center {
  text-align: center;
}

#nytxbtsfzy .gt_left {
  text-align: left;
}

#nytxbtsfzy .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#nytxbtsfzy .gt_font_normal {
  font-weight: normal;
}

#nytxbtsfzy .gt_font_bold {
  font-weight: bold;
}

#nytxbtsfzy .gt_font_italic {
  font-style: italic;
}

#nytxbtsfzy .gt_super {
  font-size: 65%;
}

#nytxbtsfzy .gt_footnote_glyph {
  font-style: italic;
  font-size: 65%;
}
</style>
<div id="nytxbtsfzy" style="overflow-x:auto;"><!--gt table start-->
<table class='gt_table'>
<tr>
<th class='gt_col_heading gt_center' rowspan='1' colspan='1'>etude</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>r</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>n</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>yi</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>vi</th>
</tr>
<tbody class='gt_table_body'>
<tr>
<td class='gt_row gt_center'>A</td>
<td class='gt_row gt_right'>0.6</td>
<td class='gt_row gt_right'>32</td>
<td class='gt_row gt_right'>0.6931472</td>
<td class='gt_row gt_right'>0.03448276</td>
</tr>
<tr>
<td class='gt_row gt_center gt_striped'>B</td>
<td class='gt_row gt_right gt_striped'>-0.2</td>
<td class='gt_row gt_right gt_striped'>16</td>
<td class='gt_row gt_right gt_striped'>-0.2027326</td>
<td class='gt_row gt_right gt_striped'>0.07692308</td>
</tr>
</tbody>
</table>
<!--gt table end-->
</div><!--/html_preserve-->

## Uniformisation
Un des problèmes auquel on fait souvent face, est que nous avons plusieurs types de mesures (corrélations, différences de moyennes, etc.) et que la taille d'effet standardisée pour chacun peut être différente. On arrive souvent à un point où on a des *d* de Cohen, des *z* des Fisher, des *g* de Hedges etc.

Il existe tout un chapitre du livre de Borenstein consacré uniquement aux conversions entre les tailles d'effet, tous les calculs sont là!

## Problématiques typiques à l'écologie
Si vous étudiez des pentes, vous devrez les convertir manuellement en corrélations avant leur inclusion. Ce n'est pas nécéssairement simple.

Si vous avez accès aux données brutes, sachant que la formule de la pente est :
`slope = r*(Sy / Sx)`
on peut convertir une pente en corrélation en la divisant par le ratio `Sy/Sx`

Par contre, si vous n'avez pas accès aux écarts-types, il est possible d'y arriver par un chemin plus tortueux incluant la valeur de *t* et les degrés de liberté. Les équations sont dans un article difficile à trouver de 1982. Vous passerez me voir rendu là...

## Pour notre exemple

Les données utilisées pour notre étude de cas étaient déjà prêtes dans un effet
standardisé, le log-response ratio.

Autrement dit, le log du ratio entre les réponses avec et sans musique.

Sans le log, nos chiffres auraient ressemblé à

```r
etudes %>%
  mutate(R = exp(y)) %>%
  gt
```

<!--html_preserve--><style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#wctoayqwwr .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #000000;
  font-size: 16px;
  background-color: #FFFFFF;
  /* table.background.color */
  width: auto;
  /* table.width */
  border-top-style: solid;
  /* table.border.top.style */
  border-top-width: 2px;
  /* table.border.top.width */
  border-top-color: #A8A8A8;
  /* table.border.top.color */
}

#wctoayqwwr .gt_heading {
  background-color: #FFFFFF;
  /* heading.background.color */
  border-bottom-color: #FFFFFF;
}

#wctoayqwwr .gt_title {
  color: #000000;
  font-size: 125%;
  /* heading.title.font.size */
  padding-top: 4px;
  /* heading.top.padding */
  padding-bottom: 1px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#wctoayqwwr .gt_subtitle {
  color: #000000;
  font-size: 85%;
  /* heading.subtitle.font.size */
  padding-top: 1px;
  padding-bottom: 4px;
  /* heading.bottom.padding */
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#wctoayqwwr .gt_bottom_border {
  border-bottom-style: solid;
  /* heading.border.bottom.style */
  border-bottom-width: 2px;
  /* heading.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* heading.border.bottom.color */
}

#wctoayqwwr .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  padding-top: 4px;
  padding-bottom: 4px;
}

#wctoayqwwr .gt_col_heading {
  color: #000000;
  background-color: #FFFFFF;
  /* column_labels.background.color */
  font-size: 16px;
  /* column_labels.font.size */
  font-weight: initial;
  /* column_labels.font.weight */
  vertical-align: middle;
  padding: 10px;
  margin: 10px;
}

#wctoayqwwr .gt_sep_right {
  border-right: 5px solid #FFFFFF;
}

#wctoayqwwr .gt_group_heading {
  padding: 8px;
  color: #000000;
  background-color: #FFFFFF;
  /* row_group.background.color */
  font-size: 16px;
  /* row_group.font.size */
  font-weight: initial;
  /* row_group.font.weight */
  border-top-style: solid;
  /* row_group.border.top.style */
  border-top-width: 2px;
  /* row_group.border.top.width */
  border-top-color: #A8A8A8;
  /* row_group.border.top.color */
  border-bottom-style: solid;
  /* row_group.border.bottom.style */
  border-bottom-width: 2px;
  /* row_group.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* row_group.border.bottom.color */
  vertical-align: middle;
}

#wctoayqwwr .gt_empty_group_heading {
  padding: 0.5px;
  color: #000000;
  background-color: #FFFFFF;
  /* row_group.background.color */
  font-size: 16px;
  /* row_group.font.size */
  font-weight: initial;
  /* row_group.font.weight */
  border-top-style: solid;
  /* row_group.border.top.style */
  border-top-width: 2px;
  /* row_group.border.top.width */
  border-top-color: #A8A8A8;
  /* row_group.border.top.color */
  border-bottom-style: solid;
  /* row_group.border.bottom.style */
  border-bottom-width: 2px;
  /* row_group.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* row_group.border.bottom.color */
  vertical-align: middle;
}

#wctoayqwwr .gt_striped {
  background-color: #f2f2f2;
}

#wctoayqwwr .gt_from_md > :first-child {
  margin-top: 0;
}

#wctoayqwwr .gt_from_md > :last-child {
  margin-bottom: 0;
}

#wctoayqwwr .gt_row {
  padding: 10px;
  /* row.padding */
  margin: 10px;
  vertical-align: middle;
}

#wctoayqwwr .gt_stub {
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #A8A8A8;
  padding-left: 12px;
}

#wctoayqwwr .gt_stub.gt_row {
  background-color: #FFFFFF;
}

#wctoayqwwr .gt_summary_row {
  background-color: #FFFFFF;
  /* summary_row.background.color */
  padding: 6px;
  /* summary_row.padding */
  text-transform: inherit;
  /* summary_row.text_transform */
}

#wctoayqwwr .gt_first_summary_row {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
}

#wctoayqwwr .gt_table_body {
  border-top-style: solid;
  /* table_body.border.top.style */
  border-top-width: 2px;
  /* table_body.border.top.width */
  border-top-color: #A8A8A8;
  /* table_body.border.top.color */
  border-bottom-style: solid;
  /* table_body.border.bottom.style */
  border-bottom-width: 2px;
  /* table_body.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* table_body.border.bottom.color */
}

#wctoayqwwr .gt_footnote {
  font-size: 90%;
  /* footnote.font.size */
  padding: 4px;
  /* footnote.padding */
}

#wctoayqwwr .gt_sourcenote {
  font-size: 90%;
  /* sourcenote.font.size */
  padding: 4px;
  /* sourcenote.padding */
}

#wctoayqwwr .gt_center {
  text-align: center;
}

#wctoayqwwr .gt_left {
  text-align: left;
}

#wctoayqwwr .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#wctoayqwwr .gt_font_normal {
  font-weight: normal;
}

#wctoayqwwr .gt_font_bold {
  font-weight: bold;
}

#wctoayqwwr .gt_font_italic {
  font-style: italic;
}

#wctoayqwwr .gt_super {
  font-size: 65%;
}

#wctoayqwwr .gt_footnote_glyph {
  font-style: italic;
  font-size: 65%;
}
</style>
<div id="wctoayqwwr" style="overflow-x:auto;"><!--gt table start-->
<table class='gt_table'>
<tr>
<th class='gt_col_heading gt_center' rowspan='1' colspan='1'>article</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>y</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>n</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>v</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>R</th>
</tr>
<tbody class='gt_table_body'>
<tr>
<td class='gt_row gt_center'>A</td>
<td class='gt_row gt_right'>0.50</td>
<td class='gt_row gt_right'>10</td>
<td class='gt_row gt_right'>0.04</td>
<td class='gt_row gt_right'>1.6487213</td>
</tr>
<tr>
<td class='gt_row gt_center gt_striped'>B</td>
<td class='gt_row gt_right gt_striped'>0.01</td>
<td class='gt_row gt_right gt_striped'>150</td>
<td class='gt_row gt_right gt_striped'>0.01</td>
<td class='gt_row gt_right gt_striped'>1.0100502</td>
</tr>
<tr>
<td class='gt_row gt_center'>C</td>
<td class='gt_row gt_right'>-0.10</td>
<td class='gt_row gt_right'>12</td>
<td class='gt_row gt_right'>0.03</td>
<td class='gt_row gt_right'>0.9048374</td>
</tr>
</tbody>
</table>
<!--gt table end-->
</div><!--/html_preserve-->

Autrement dit, 64% d'augmentation, 1% d'augmentation et 10% de diminution du QI

Par contre, le problème lorsque l'on modélise de tels ratios est que la partie <1 est "coincée" entre 0 et 1, alors que la partie >1 peut exploser dans des valeurs très grandes. Les mesures ne sont pas symétriques à gauche et à droite de 1

```r
1/100 # 0.99 sous 1
```

```
[1] 0.01
```

```r
100/1 # 99 au dessus de 1
```

```
[1] 100
```
La transformation log permet de rétablir cette symétrie

```r
log(1/100) # 4.6 sous zéro
```

```
[1] -4.60517
```

```r
log(100/1) # 4.6 au-dessus de zéro
```

```
[1] 4.60517
```

# Visualisation
La visualisation classique d'une méta-analyse est ce que l'on nomme le forest plot :

```r
forest(m, order = "obs", slab = etudes$article)
```

![](/assets/MA_files/figure-html/unnamed-chunk-15-1.png)<!-- -->

Chaque étude est représentée par une ligne.
L'effet mesurée dans chaque étude est affiché, avec son intervalle de confiance.
La taille du point correspond au poids de l'étude dans le calcul.

La dernière ligne correspond à l'effet global, tel que calculé plus haut.

Il peut parfois être utile de convertir la taille de l'effet à l'inverse (*back-transform*) pour retourner à une version plus facile à interpréter.


```r
exp(-0.09)
```

```
[1] 0.9139312
```

```r
exp(0.22)
```

```
[1] 1.246077
```

Donc, la vraie taille de l'effet est quelque part entre une augmentation de 25% et une diminution de 9% (95% des chances que...)

# Le fameux biais de publication

Un des problèmes avec une méta-analyse basée sur la littérature est qu'il pourrait arriver que les études contraires aux résultats communément attendus n'aient pas été publiées, qu'ils soient restées dans les tiroirs.

## Visualisation
Une des façons de visualiser ce problème est grâce au diagramme en entonnoir (*funnel plot*)

```r
funnel(m)
```

![](/assets/MA_files/figure-html/unnamed-chunk-17-1.png)<!-- -->

En y, on trouve la précision de chaque étude, et en x, l'estimé comme tel. Normalement, plus une étude est précise, plus elle devrait être près de la moyenne globale. Dans le bas de l'entonnoir, les études les moins précises devraient varier plus autour de la moyenne.

Il faut être particulièrement vigilant si ce diagramme n'est pas symétrique (e.g. si il y a beaucoup plus de points d'un côté que de l'autre).

## Tests statistiques
Il existe aussi des tests statistiques pour valider nos impressions du *funnel plot*.


```r
regtest(m, model = "lm", predictor = "sei")
```

```

Regression Test for Funnel Plot Asymmetry

model:     weighted regression with multiplicative dispersion
predictor: standard error

test for funnel plot asymmetry: t = 0.6405, df = 1, p = 0.6373
```
Le test de Egger classique est essentiellement une régression de l'estimé en fonction de l'erreur type
(`lm(y~sqrt(v), weights = 1/v, data = etudes)`)

```r
etudes %>%
  ggplot(aes(x = sqrt(v), y = y)) +
  geom_point(aes(size = 1/v)) +
  geom_smooth(method = "lm") # attention, il faudrait aussi ajuster le poids de chaque observation à 1/v
```

![](/assets/MA_files/figure-html/unnamed-chunk-19-1.png)<!-- -->

Il existe d'autres façons de tester pour le biais de publication, par exemple par des analyses de sensibilité.

Une de ces méthodes est le Trim & Fill. L'algorithme estime combien d'études sont manquantes d'un côté de l'analyse, puis recalcule notre estimé en ajoutant ces *études fantômes*. Ce nouvel estimé ne doit pas être interprété comme étant plus valide que l'original, il doit être uniquement utilisé pour évaluer la robustesse/sensibilité de nos résultats.

(exemple avec un autre jeu de données, puisqu'il n'y en a pas de manquantes de le nôtre)

```r
res <- rma(yi, vi, data = dat.hackshaw1998)
taf <- trimfill(res)
funnel(taf)
```

![](/assets/MA_files/figure-html/unnamed-chunk-20-1.png)<!-- -->

```r
taf
```

```

Estimated number of missing studies on the left side: 7 (SE = 4.0399)

Random-Effects Model (k = 44; tau^2 estimator: REML)

tau^2 (estimated amount of total heterogeneity): 0.0245 (SE = 0.0183)
tau (square root of estimated tau^2 value):      0.1565
I^2 (total heterogeneity / total variability):   28.86%
H^2 (total variability / sampling variability):  1.41

Test for Heterogeneity:
Q(df = 43) = 60.5196, p-val = 0.0400

Model Results:

estimate      se    zval    pval   ci.lb   ci.ub     
  0.1745  0.0484  3.6015  0.0003  0.0795  0.2694  ***

---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```


# Modèle à effets fixes vs. modèle à effets aléatoire

Jusqu'ici, nous avons exploré un modèle simple de méta-analyse, où nous assumions qu'en l'absence d'erreur (de bruit, etc.), toutes les études auraient dû nous donner le même résultat.

Il est possible par contre (et c'est presque toujours le cas en écologie), que la taille de l'effet dépende en fait du contexte dans lequel l'étude a été effectuée ou du groupe d'individus étudiés.

Dans notre exemple de l'effet de Mozart, on pourrait envisager un scénario où l'effet de la musique soit p. ex. différent selon le contexte culturel.

À ce moment, nous ne cherchons plus un seul effet synthétique absolu, identique à toutes les études. Nous assumons qu'il existe une population d'effets possibles qui dépendent du contexte. L'erreur dans l'effet mesuré provient alors de deux sources : l'erreur interne à chaque étude, et la variabilité entre les études (tau). On doit alors appliquer un modèle avec effets aléatoires.

## Implications

Le modèle à effets aléatoires ajoute une composante de variance supplémentaire qui doit être estimée dans le modèle (tau^2). Le calcul est donc plus complexe et doit passer par la vraisemblance maximale (et les possibles erreurs de convergence etc.) alors que le modèle fixe peut être résolu par la méthode des moindres carrés.

Plus important conceptuellement, le poids donné à chaque étude sera différent dans le modèle à effets aléatoires. Puisque notre modèle doit être représentatif de la variabilité inter-études, il doit être plus équilibré dans son attribution des poids. Même si une étude est peu précise, l'information qu'elle apporte quand à la variabilité inter-études doit tout de même être prise en compte (et vice-versa, une étude très précise devra avoir un poids moins grand pour ne pas faire complètement disparaître l'effet des autres)

## Calcul
Dans le package `metafor`, les modèles à effets aléatoires sont ajustés avec la même fonction que le modèle à effets fixes, mais en ne spécifiant pas la méthode `FE`

```r
m2 <- rma(
  yi = y,
  vi = v,
  data = etudes
)
m2
```

```

Random-Effects Model (k = 3; tau^2 estimator: REML)

tau^2 (estimated amount of total heterogeneity): 0.0574 (SE = 0.0827)
tau (square root of estimated tau^2 value):      0.2397
I^2 (total heterogeneity / total variability):   70.75%
H^2 (total variability / sampling variability):  3.42

Test for Heterogeneity:
Q(df = 2) = 5.9405, p-val = 0.0513

Model Results:

estimate      se    zval    pval    ci.lb   ci.ub   
  0.1132  0.1655  0.6843  0.4938  -0.2111  0.4375   

---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

Le résultat est semblable au précédent, mais il est plus conservateur, moins influencé par la grande étude très précise.

Notre tableau des résultats contient maintenant des informations supplémentaires. Tau^2 est la variance inter-études (qui a peu d'importance en absolu).
I^2 par contre est beaucoup plus intéressant, puisqu'il s'agit de la proportion de la variabilité totale du jeu de données qui provient de l'hétérogénéité inter-études. Plus ce chiffre est élevé, plus les études sont différentes entre elles.

Nos résultats (comme les précédents) fournissent le résultat d'un test d'hétérogénéité, qui nous informe si l'hétérogénéité est significative ou non. On pourrait être tenté de se baser sur ce test pour savoir si on doit utiliser un modèle à effets aléatoires ou non, mais comme pour les effets aléatoires dans un modèle de régression, si conceptuellement on devrait mettre l'effet aléatoire, il est fortement recommandé de simplement l'ajouter au modèle.

# Références
Borenstein, M., Hedges, L. V., Higgins, J. P., & Rothstein, H. R. (2011). Introduction to meta-analysis. John Wiley & Sons.

Viechtbauer, W. (2010). Conducting meta-analyses in R with the metafor package. Journal of Statistical Software, 36(3), 1-48. URL: [http://www.jstatsoft.org/v36/i03/](http://www.jstatsoft.org/v36/i03/)

Viechtbauer, W. (2021). The metafor Package: A Meta-Analysis Package for R. [https://www.metafor-project.org/doku.php/metafor](https://www.metafor-project.org/doku.php/metafor)

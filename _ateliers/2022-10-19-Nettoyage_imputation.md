---
layout: default
thumbnail: Rlogo.png
title: "Nettoyage de données et imputation"
author: "Estéban Hamel Jomphe"
date: "2022-10-19"
category: Exploration des données
lang: fr
output:
  html_document:
    highlight: haddock
    keep_md: yes
    theme: readable
    toc: yes
---

# Nettoyage de données et imputation
{:.no_toc}

## Estéban Hamel Jomphe
{:.no_toc}

## Octobre 2022
{:.no_toc}

* TOC
{:toc}


```r
library(tidyverse)
```

```
── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
✔ dplyr     1.1.3     ✔ readr     2.1.4
✔ forcats   1.0.0     ✔ stringr   1.5.0
✔ ggplot2   3.4.3     ✔ tibble    3.2.1
✔ lubridate 1.9.2     ✔ tidyr     1.3.0
✔ purrr     1.0.1     
── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
```

L'objectif de cet atelier est de vous introduire à quelques notions de nettoyages de données et de vous aiguiller sur certaines astuces afin de travailler plus efficacement avec vos données si durement acquises sur le terrain.

# Objectifs
- Importer/ créer un tableau de données à partir d'un ou plusieurs fichiers;
- Modifier des observations;
- Ordonner les observations avec Tidyverse;
- Imputation et gestion des NA.

# Étape 1 Ouvrir un fichier de données

R permet de lire à peu près tout types de fichiers et de les travailler. Cela signifie qu'à moins que vous n'enregistriez une copie de votre jeu de données modifiées, le fait d'ajouter des colonnes, supprimer des observations, etc. *N'AFFECTERA PAS* le fichier d'origine. 

Les fonctions de R débutant par read. permettent d'ouvrir un jeu de données. Prenons par exemple une feuille de calcul Excel.

- Si ce n'est pas déjà fait, débuter par nettoyer l'environnement global de R (panneau à droite)
- Vous pouvez ensuite définir l'environnement de travail si toutes vos données sont au même endroit. Cependant il faut garder en tête que si vos données changent éventuellement d'emplacement, alors conserver les extensions peut être plus souhaitable. 



```r
# Ouvrir un jeu de données Excel
library(readxl)

# Première alternative pour lire un fichier excel lorsqu'on connait le nom des feuilles de calcul.
df<-read_excel("Exercice1_excel.xlsx",sheet = "Feuil1")

# Seconde alternative en décrivant l'emplacement des feuilles de calculs et en retirant des colonnes superflues.
df2<-read_excel("Exercice1_excel.xlsx",sheet = 2,skip = 2)
```


```r
rm(df,df2)
```

**Note** Pour les fichiers DBF par exemple une table d'attributs d'un fichier shapefile, il est possible d'utiliser la fonction read.dbf, cependant cela nécessite le package *foreign*

Plusieurs d'entre vous auront probablement à utiliser des données en format CSV. L'avantage est qu'il permet d'emmagasiner un plus grand nombre d'observations de façon plus compacte. Ainsi, la limite d'environ 1 million de lignes et 16 000 colonnes liées aux fichiers Excel peut être grandement améliorée par un jeu de données en format CSV. 

Un détail à ne pas négliger est le type de séparateur de vos données. Selon les configurations de votre ordinateur, il est possible que certains enregistrent un fichier CSV avec des virgules comme séparateur (',') alors que d'autres l'enregistrent avec des points-virgules (';'). Il faudra donc le spécifier dans la ligne de commande pour ouvrir votre fichier.


```r
# Ouvrir un jeu de données CSV séparé par des points virgules.

df<-read.csv("plusieurs_stations/foret1.csv",sep = ";")

head(df)
```

```
  Station Merle Sitelle Pic
1       1     1       3   1
2       2     0       1   1
3       3     0       2   2
4       4     0       0   0
5       5     1       1   0
```


## Ouvrir plusieurs fichiers

Il est courant d'avoir plusieurs fichiers pour plusieurs stations d'échantillonnage. Le plus simple est cependant d'avoir un jeu de données avec toutes les observations. Certains seront tentés de faire ce travail manuellement en copiant les données dans un même fichier, mais il est possible de sauver du temps avec quelques lignes de codes. 

Pour ce faire, il faudra créer une fonction qui ouvrira et joindra toutes les fichiers. Il s'agit du même type de fonction que celle de type $f(x)=ax+b$. 
La fonction sera plus complexe qu'une pente et un multiplicateur, mais le principe reste le même. On applique une modification à un ensemble pour donner une valeur ajoutée/transformée.


<img src="/assets/Nettoyage/Image/Structure_fonction.PNG" width="805" />



## Créer une liste des fichiers à importer
La première étape est de se créer une liste des fichiers à ouvrir. Dans ce cas-ci, nous utiliserons les fichiers contenus dans le dossier *plusieurs_stations*.


```r
# Créer une liste de valeurs avec la fonction list

liste_fichiers<-list.files("plusieurs_stations/")

liste_fichiers
```

```
[1] "foret1.csv"   "foret2.csv"   "prairie1.csv" "prairie2.csv"
```

## Créer une fonction pour lire les fichiers
Voici comment on écrira la fonction pour lire les fichiers. 


```r
# Créer une fonction qui ouvrira les fichiers contenus dans le dossiers "plusieurs_stations".

# On peut aussi ajouter une colonne pour ajouter le nom du fichier aux observations qui lui sont liées.

#f<-("C:/Users/est_a/Desktop/Numerilab_nettoyage/plusieurs_stations/foret1.csv") # On peut retirer le dièse de cette ligne pour valider la fonction avec un seul élément de la liste

lire_csv<-function(f)
{
  read.csv2(f,sep = ";") %>% 
    mutate(Environnement=f)%>%
    rename_at(vars(starts_with("P")),funs(sub( "Pic", "Pics",.)))
}
```
## Appliquer la fonction à la liste de données

Pour cela, il suffit d'utiliser la fonction map_df du package *purr* (inclus dans le Tidyverse). 
C'est comme si on venait dire d'appliquer la transformation décrite dans la fonction (a) à tous les éléments de la liste (x) pour créer le nouvel élément (y). 


```r
# Créer le jeu de données assemblé avec toutes les observations.

# Notez qu'il faut ajouter le chemin d'emplacement des fichiers sinon seuls les éléments de la liste seront appliqué à la fonction.
df<-map_df(paste0("plusieurs_stations/",liste_fichiers),lire_csv)

head(df)
```

```
  Station Merle Sitelle Pics                 Environnement
1       1     1       3    1 plusieurs_stations/foret1.csv
2       2     0       1    1 plusieurs_stations/foret1.csv
3       3     0       2    2 plusieurs_stations/foret1.csv
4       4     0       0    0 plusieurs_stations/foret1.csv
5       5     1       1    0 plusieurs_stations/foret1.csv
6       1     1       2    1 plusieurs_stations/foret2.csv
```



```r
# ajuster la colonne "Environnement"

df$Environnement<-str_replace(df$Environnement,".csv","")

df$Environnement<-str_replace(df$Environnement,"C:/Users/est_a/Desktop/Numerilab_nettoyage/plusieurs_stations/","")

head(df)
```

```
  Station Merle Sitelle Pics             Environnement
1       1     1       3    1 plusieurs_stations/foret1
2       2     0       1    1 plusieurs_stations/foret1
3       3     0       2    2 plusieurs_stations/foret1
4       4     0       0    0 plusieurs_stations/foret1
5       5     1       1    0 plusieurs_stations/foret1
6       1     1       2    1 plusieurs_stations/foret2
```


```r
# Une fois le jeu de données construit, il est possible de faire quelques commandes pour mieux comprendre le jeux de données créés

summary(df) # Un résumé des valeurs contenues
```

```
    Station      Merle         Sitelle          Pics      Environnement     
 Min.   :1   Min.   :0.00   Min.   :0.00   Min.   :0.00   Length:20         
 1st Qu.:2   1st Qu.:0.00   1st Qu.:0.00   1st Qu.:0.00   Class :character  
 Median :3   Median :1.00   Median :1.00   Median :1.00   Mode  :character  
 Mean   :3   Mean   :1.10   Mean   :1.50   Mean   :1.05                     
 3rd Qu.:4   3rd Qu.:1.25   3rd Qu.:2.25   3rd Qu.:1.25                     
 Max.   :5   Max.   :4.00   Max.   :5.00   Max.   :3.00                     
```

```r
str(df) # Le type de variable présente
```

```
'data.frame':	20 obs. of  5 variables:
 $ Station      : int  1 2 3 4 5 1 2 3 4 5 ...
 $ Merle        : int  1 0 0 0 1 1 4 0 2 0 ...
 $ Sitelle      : int  3 1 2 0 1 2 2 1 0 0 ...
 $ Pics         : int  1 1 2 0 0 1 0 1 0 3 ...
 $ Environnement: chr  "plusieurs_stations/foret1" "plusieurs_stations/foret1" "plusieurs_stations/foret1" "plusieurs_stations/foret1" ...
```

# Étape 2: Modifier les données 

Après avoir importé les données dans R, il n'est pas assuré que celles-ci soient prêtes à être analysées directement. Certaines modifications du tableau de données ou des valeurs directement éviteront les erreurs de calcul par la suite.

Il peut s'agir d'un ajout de colonne de description des sites, une observation terrain mal retranscrite ou d'un changement de format du tableau de données pour prévenir les erreurs dans les analyses subséquentes, etc.

D'abord, il est important de savoir que R n'aime pas particulièrement:
les espaces, les accents et les caractères spéciaux (!@#), c'est donc à considérer quand on importe des données qui ont été traitées par un autre logiciel.

Une première façon de modifier les données peut se faire en faisant référence aux colonnes et aux lignes d'origine. Pour ce faire, l'utilisation des crochets ("[]") est de mise.

Cette façon de modifier les données est plus difficilement réversible dans un même objet R, cependant le fichier d'origine lui reste toujours intact.

Nous verrons ensuite une seconde façon de faire avec le package *dplyr* qui ne nécessite pas l'utilisation des crochets et qui crée plutôt des sous-jeux de donnée.


## Modifier des observations
Changer directement une observation à la fois dans le jeu de données avec les crochets.



```r
# Modifier l'observation de la deuxième ligne, deuxième colonne pour la valeur 39 dans le jeu de données df.
df[2,2]<-39

head(df)
```

```
  Station Merle Sitelle Pics             Environnement
1       1     1       3    1 plusieurs_stations/foret1
2       2    39       1    1 plusieurs_stations/foret1
3       3     0       2    2 plusieurs_stations/foret1
4       4     0       0    0 plusieurs_stations/foret1
5       5     1       1    0 plusieurs_stations/foret1
6       1     1       2    1 plusieurs_stations/foret2
```

## Ajouter une colonne


```r
# Ajouter une colonne avec dplyr
df %>% mutate(nouvelle_colonne=Environnement) #cette modification n'est pas permanente puisque l'objet df n'a pas été réassigné.
```

```
   Station Merle Sitelle Pics               Environnement
1        1     1       3    1   plusieurs_stations/foret1
2        2    39       1    1   plusieurs_stations/foret1
3        3     0       2    2   plusieurs_stations/foret1
4        4     0       0    0   plusieurs_stations/foret1
5        5     1       1    0   plusieurs_stations/foret1
6        1     1       2    1   plusieurs_stations/foret2
7        2     4       2    0   plusieurs_stations/foret2
8        3     0       1    1   plusieurs_stations/foret2
9        4     2       0    0   plusieurs_stations/foret2
10       5     0       0    3   plusieurs_stations/foret2
11       1     0       0    1 plusieurs_stations/prairie1
12       2     3       1    0 plusieurs_stations/prairie1
13       3     0       5    3 plusieurs_stations/prairie1
14       4     1       0    2 plusieurs_stations/prairie1
15       5     1       0    1 plusieurs_stations/prairie1
16       1     1       4    1 plusieurs_stations/prairie2
17       2     2       4    0 plusieurs_stations/prairie2
18       3     3       4    1 plusieurs_stations/prairie2
19       4     1       0    2 plusieurs_stations/prairie2
20       5     1       0    1 plusieurs_stations/prairie2
              nouvelle_colonne
1    plusieurs_stations/foret1
2    plusieurs_stations/foret1
3    plusieurs_stations/foret1
4    plusieurs_stations/foret1
5    plusieurs_stations/foret1
6    plusieurs_stations/foret2
7    plusieurs_stations/foret2
8    plusieurs_stations/foret2
9    plusieurs_stations/foret2
10   plusieurs_stations/foret2
11 plusieurs_stations/prairie1
12 plusieurs_stations/prairie1
13 plusieurs_stations/prairie1
14 plusieurs_stations/prairie1
15 plusieurs_stations/prairie1
16 plusieurs_stations/prairie2
17 plusieurs_stations/prairie2
18 plusieurs_stations/prairie2
19 plusieurs_stations/prairie2
20 plusieurs_stations/prairie2
```

```r
# Ajouter une colonne sans dplyr
df$colonne2<-df$Environnement # En ajoutant l'opérateur d'assignation, l'ajout est permanent.

head(df)
```

```
  Station Merle Sitelle Pics             Environnement
1       1     1       3    1 plusieurs_stations/foret1
2       2    39       1    1 plusieurs_stations/foret1
3       3     0       2    2 plusieurs_stations/foret1
4       4     0       0    0 plusieurs_stations/foret1
5       5     1       1    0 plusieurs_stations/foret1
6       1     1       2    1 plusieurs_stations/foret2
                   colonne2
1 plusieurs_stations/foret1
2 plusieurs_stations/foret1
3 plusieurs_stations/foret1
4 plusieurs_stations/foret1
5 plusieurs_stations/foret1
6 plusieurs_stations/foret2
```

## Effacer une colonne


```r
# Retirer la sixième colonne avec les crochets

df<-df[,-c(6)]

head(df)
```

```
  Station Merle Sitelle Pics             Environnement
1       1     1       3    1 plusieurs_stations/foret1
2       2    39       1    1 plusieurs_stations/foret1
3       3     0       2    2 plusieurs_stations/foret1
4       4     0       0    0 plusieurs_stations/foret1
5       5     1       1    0 plusieurs_stations/foret1
6       1     1       2    1 plusieurs_stations/foret2
```


## Ajouter un ID avec les numéros de colonne

Lorsque les données traitées sont très répétitives et qu'elles n'ont pas un ordre particulier, il est tout de même recommandé d'avoir un identifiant unique pour chacune des observations. En regardant le tableau de données, on voit que R indique déjà un numéro unique par ligne. Il est possible d'utiliser ces numéros uniques pour en faire une nouvelle colonne. 



```r
# Utiliser l'index des colonnes pour en créer une colonne d'identifiant
df$colonne2<-as.numeric(rownames(df))

head(df)
```

```
  Station Merle Sitelle Pics             Environnement colonne2
1       1     1       3    1 plusieurs_stations/foret1        1
2       2    39       1    1 plusieurs_stations/foret1        2
3       3     0       2    2 plusieurs_stations/foret1        3
4       4     0       0    0 plusieurs_stations/foret1        4
5       5     1       1    0 plusieurs_stations/foret1        5
6       1     1       2    1 plusieurs_stations/foret2        6
```



## Modifier les en-têtes

Pour modifier seulement certains en-têtes de colonnes spécifiques, il est possible de préciser la colonne en question et d'attribuer les nouveaux noms avec les crochets.


```r
# Renommer les colonnes d'un jeu de données
colnames(df)[c(1,5,6)]<-c("Parcelle","Station","Identifiant_1")

head(df)
```

```
  Parcelle Merle Sitelle Pics                   Station Identifiant_1
1        1     1       3    1 plusieurs_stations/foret1             1
2        2    39       1    1 plusieurs_stations/foret1             2
3        3     0       2    2 plusieurs_stations/foret1             3
4        4     0       0    0 plusieurs_stations/foret1             4
5        5     1       1    0 plusieurs_stations/foret1             5
6        1     1       2    1 plusieurs_stations/foret2             6
```

Sans l'utilisation des crochets, cette ligne de code aurait modifié tous les en-têtes du tableau en débutant par le premier à gauche. Les colonnes non spécifiées auraient aussi pu devenir sans nom.

## Caractères non-ASCII

Si les caractères avec des accents d'un champ ou d'une valeur n'étaient pas lisibles, il peut s'agir d'une erreur d'encodage. Ce type de problème peut régler avec la fonction *stri_enc_toascii* du package *stringi*. Voir exemple ci-dessous.


```r
# Rechange les caractères non-ASCII en caractères lisibles.
library(stringi)

df$W<-stri_enc_toascii(df$W)
```

## Effacer une observation

Bien que peu recommandé, il est possible de retirer des observations du jeu de données. 
De la même manière que pour modifier une observation précise, on peut transformer la case du tableau en NA ou retirer toute la ligne. 


```r
# Créons d'abord un jeu de données alternatif pour faire les suppressions
df2<-df

# On ne peut pas exactement retirer une donnée seulement, mais on peut la transformer en NA.
df2[2,2]<-NA

head(df2)
```

```
  Parcelle Merle Sitelle Pics                   Station Identifiant_1
1        1     1       3    1 plusieurs_stations/foret1             1
2        2    NA       1    1 plusieurs_stations/foret1             2
3        3     0       2    2 plusieurs_stations/foret1             3
4        4     0       0    0 plusieurs_stations/foret1             4
5        5     1       1    0 plusieurs_stations/foret1             5
6        1     1       2    1 plusieurs_stations/foret2             6
```

```r
# Supprimer la ligne #2 entièrement d'un jeu de données
df2<-df[-c(2),]

head(df2)
```

```
  Parcelle Merle Sitelle Pics                   Station Identifiant_1
1        1     1       3    1 plusieurs_stations/foret1             1
3        3     0       2    2 plusieurs_stations/foret1             3
4        4     0       0    0 plusieurs_stations/foret1             4
5        5     1       1    0 plusieurs_stations/foret1             5
6        1     1       2    1 plusieurs_stations/foret2             6
7        2     4       2    0 plusieurs_stations/foret2             7
```

```r
#pour supprimer une colonne
df2<-df[,-c(2)]

head(df2)
```

```
  Parcelle Sitelle Pics                   Station Identifiant_1
1        1       3    1 plusieurs_stations/foret1             1
2        2       1    1 plusieurs_stations/foret1             2
3        3       2    2 plusieurs_stations/foret1             3
4        4       0    0 plusieurs_stations/foret1             4
5        5       1    0 plusieurs_stations/foret1             5
6        1       2    1 plusieurs_stations/foret2             6
```


```r
rm(df2)
```

## Manipuler les caractères d'un ou plusieurs champs

Dans l'éventualité où une colonne contiendrait plusieurs informations pertinentes, il est possible de conserver seulement quelques bouts qui nous intéresse ou à l'inverse de joindre les attributs de différentes colonnes pour en faire un identifiant unique.

La fonction *paste* permet joindre des données en les transformant en une chaine de caractères.



```r
# Regrouper les attributs de la colonne station et parcelle dans une seule.
df<-df %>% mutate(identifiant2=paste(Station,Parcelle,sep='_'))

head(df)
```

```
  Parcelle Merle Sitelle Pics                   Station Identifiant_1
1        1     1       3    1 plusieurs_stations/foret1             1
2        2    39       1    1 plusieurs_stations/foret1             2
3        3     0       2    2 plusieurs_stations/foret1             3
4        4     0       0    0 plusieurs_stations/foret1             4
5        5     1       1    0 plusieurs_stations/foret1             5
6        1     1       2    1 plusieurs_stations/foret2             6
                 identifiant2
1 plusieurs_stations/foret1_1
2 plusieurs_stations/foret1_2
3 plusieurs_stations/foret1_3
4 plusieurs_stations/foret1_4
5 plusieurs_stations/foret1_5
6 plusieurs_stations/foret2_1
```


La fonction *substr* extrait ou remplace des valeurs d'un champ. On peut alors conserver seulement une partie d'un champ existant, par exemple des coordonnées géographiques.


```r
# Conserver seulement quelques caractères d'une colonnes

df %>% mutate(colonne=substr(identifiant2, 1, 5)) # Extrait les valeur 1 à 5 de la colonne identifiant2
```

```
   Parcelle Merle Sitelle Pics                     Station Identifiant_1
1         1     1       3    1   plusieurs_stations/foret1             1
2         2    39       1    1   plusieurs_stations/foret1             2
3         3     0       2    2   plusieurs_stations/foret1             3
4         4     0       0    0   plusieurs_stations/foret1             4
5         5     1       1    0   plusieurs_stations/foret1             5
6         1     1       2    1   plusieurs_stations/foret2             6
7         2     4       2    0   plusieurs_stations/foret2             7
8         3     0       1    1   plusieurs_stations/foret2             8
9         4     2       0    0   plusieurs_stations/foret2             9
10        5     0       0    3   plusieurs_stations/foret2            10
11        1     0       0    1 plusieurs_stations/prairie1            11
12        2     3       1    0 plusieurs_stations/prairie1            12
13        3     0       5    3 plusieurs_stations/prairie1            13
14        4     1       0    2 plusieurs_stations/prairie1            14
15        5     1       0    1 plusieurs_stations/prairie1            15
16        1     1       4    1 plusieurs_stations/prairie2            16
17        2     2       4    0 plusieurs_stations/prairie2            17
18        3     3       4    1 plusieurs_stations/prairie2            18
19        4     1       0    2 plusieurs_stations/prairie2            19
20        5     1       0    1 plusieurs_stations/prairie2            20
                    identifiant2 colonne
1    plusieurs_stations/foret1_1   plusi
2    plusieurs_stations/foret1_2   plusi
3    plusieurs_stations/foret1_3   plusi
4    plusieurs_stations/foret1_4   plusi
5    plusieurs_stations/foret1_5   plusi
6    plusieurs_stations/foret2_1   plusi
7    plusieurs_stations/foret2_2   plusi
8    plusieurs_stations/foret2_3   plusi
9    plusieurs_stations/foret2_4   plusi
10   plusieurs_stations/foret2_5   plusi
11 plusieurs_stations/prairie1_1   plusi
12 plusieurs_stations/prairie1_2   plusi
13 plusieurs_stations/prairie1_3   plusi
14 plusieurs_stations/prairie1_4   plusi
15 plusieurs_stations/prairie1_5   plusi
16 plusieurs_stations/prairie2_1   plusi
17 plusieurs_stations/prairie2_2   plusi
18 plusieurs_stations/prairie2_3   plusi
19 plusieurs_stations/prairie2_4   plusi
20 plusieurs_stations/prairie2_5   plusi
```

Pour extraire les valeurs d'un champ donné en partant de la droite au lieu de la gauche, il faut une étape supplémentaire pour définir ou arrêter l'extraction en partant de la droite


```r
#Décrire le nombre de chactère à conserver  en partant de la droite
n_last<-3

# Appliquer la fonction substr pour extraire les valeurs
df %>% mutate(colonne3=substr(df$identifiant2, nchar(df$identifiant2) - n_last + 1, nchar(df$identifiant2))) 
```

```
   Parcelle Merle Sitelle Pics                     Station Identifiant_1
1         1     1       3    1   plusieurs_stations/foret1             1
2         2    39       1    1   plusieurs_stations/foret1             2
3         3     0       2    2   plusieurs_stations/foret1             3
4         4     0       0    0   plusieurs_stations/foret1             4
5         5     1       1    0   plusieurs_stations/foret1             5
6         1     1       2    1   plusieurs_stations/foret2             6
7         2     4       2    0   plusieurs_stations/foret2             7
8         3     0       1    1   plusieurs_stations/foret2             8
9         4     2       0    0   plusieurs_stations/foret2             9
10        5     0       0    3   plusieurs_stations/foret2            10
11        1     0       0    1 plusieurs_stations/prairie1            11
12        2     3       1    0 plusieurs_stations/prairie1            12
13        3     0       5    3 plusieurs_stations/prairie1            13
14        4     1       0    2 plusieurs_stations/prairie1            14
15        5     1       0    1 plusieurs_stations/prairie1            15
16        1     1       4    1 plusieurs_stations/prairie2            16
17        2     2       4    0 plusieurs_stations/prairie2            17
18        3     3       4    1 plusieurs_stations/prairie2            18
19        4     1       0    2 plusieurs_stations/prairie2            19
20        5     1       0    1 plusieurs_stations/prairie2            20
                    identifiant2 colonne3
1    plusieurs_stations/foret1_1      1_1
2    plusieurs_stations/foret1_2      1_2
3    plusieurs_stations/foret1_3      1_3
4    plusieurs_stations/foret1_4      1_4
5    plusieurs_stations/foret1_5      1_5
6    plusieurs_stations/foret2_1      2_1
7    plusieurs_stations/foret2_2      2_2
8    plusieurs_stations/foret2_3      2_3
9    plusieurs_stations/foret2_4      2_4
10   plusieurs_stations/foret2_5      2_5
11 plusieurs_stations/prairie1_1      1_1
12 plusieurs_stations/prairie1_2      1_2
13 plusieurs_stations/prairie1_3      1_3
14 plusieurs_stations/prairie1_4      1_4
15 plusieurs_stations/prairie1_5      1_5
16 plusieurs_stations/prairie2_1      2_1
17 plusieurs_stations/prairie2_2      2_2
18 plusieurs_stations/prairie2_3      2_3
19 plusieurs_stations/prairie2_4      2_4
20 plusieurs_stations/prairie2_5      2_5
```


## Outils supplémentaires 

Selon vos besoins, il se pourrait que les outils montrés plus haut ne vous suffisent pas. Voici quelques autres possibilités que nous n'avons pas traitées, mais qui existe quand même dans R

- L'outil *distinct* permet de retirer les doublons entre les lignes d'un jeu de données.



```r
# Créer un sous jeu de données avec quelques lignes. La dernière est identique à la première.
x<-data.frame(i=c(1,2,3,4,5,6,6,7,1),j=c(1,5,6,7,7,8,9,3,1),k=c(1,12,14,15,2,4,5,6,1))

x
```

```
  i j  k
1 1 1  1
2 2 5 12
3 3 6 14
4 4 7 15
5 5 7  2
6 6 8  4
7 6 9  5
8 7 3  6
9 1 1  1
```

```r
# Appliquer la fonction distinct pour retirer les lignes en double
w<-distinct(x)

w
```

```
  i j  k
1 1 1  1
2 2 5 12
3 3 6 14
4 4 7 15
5 5 7  2
6 6 8  4
7 6 9  5
8 7 3  6
```


```r
rm(x,w)
```

- Changer le format des données


```r
#as.numeric(dataframe$colonne)

#Voir as.numeric/ as.character/ as.factor/ as.matrix
```


- Changement de projection spatiale (crs)


```r
#library(sp)

#spTransform((dataset,CRS("+init=epsg:XXX"))
```

- Changement des caractères non-ASCII

```r
#library(sringi)

#stri_enc_toascii(str=dataset$colonne)
```

# Étape 3: Manipuler les données
Dans un monde idéal, tous les jeux de données seraient bien compilés pour nos projets d'avance. Malheureusement, ce n'est pas toujours le cas. Cependant il existe quelques fonctions dans le package Dplyr pour organiser nos données afin que R puisse les traiter sans avoir recours aux crochets.

En résumé, il est plus optimal d'avoir un tableau avec plusieurs colonnes répétées plutôt que quelque chose esthétiquement joli. Ainsi, on va privilégier un format qui présente une observation par ligne.  


## Quelques opérations de Dplyr (arrange/slice/select/filter)

Parmi les opérations possibles avec Dplyr certaines permettent de sous-diviser un jeu de données original. 

### Slice
Par exemple, la fonction slice permet de sélectionner des lignes


```r
# Créer un sous jeu de données avec quelques lignes
df %>% slice(5:13)
```

```
  Parcelle Merle Sitelle Pics                     Station Identifiant_1
1        5     1       1    0   plusieurs_stations/foret1             5
2        1     1       2    1   plusieurs_stations/foret2             6
3        2     4       2    0   plusieurs_stations/foret2             7
4        3     0       1    1   plusieurs_stations/foret2             8
5        4     2       0    0   plusieurs_stations/foret2             9
6        5     0       0    3   plusieurs_stations/foret2            10
7        1     0       0    1 plusieurs_stations/prairie1            11
8        2     3       1    0 plusieurs_stations/prairie1            12
9        3     0       5    3 plusieurs_stations/prairie1            13
                   identifiant2
1   plusieurs_stations/foret1_5
2   plusieurs_stations/foret2_1
3   plusieurs_stations/foret2_2
4   plusieurs_stations/foret2_3
5   plusieurs_stations/foret2_4
6   plusieurs_stations/foret2_5
7 plusieurs_stations/prairie1_1
8 plusieurs_stations/prairie1_2
9 plusieurs_stations/prairie1_3
```


### Select
Idem pour sélectionner des colonnes, on utilisera la fonction *select* pour n'avoir que quelques colonnes. L'ordre dans lequel on indiquera les colonnes seront l'ordre dans lequel elles apparaiteront.


```r
# Créer un sous jeu de données avec quelques colonnes
df %>% select(c(6,2,3))
```

```
   Identifiant_1 Merle Sitelle
1              1     1       3
2              2    39       1
3              3     0       2
4              4     0       0
5              5     1       1
6              6     1       2
7              7     4       2
8              8     0       1
9              9     2       0
10            10     0       0
11            11     0       0
12            12     3       1
13            13     0       5
14            14     1       0
15            15     1       0
16            16     1       4
17            17     2       4
18            18     3       4
19            19     1       0
20            20     1       0
```

### Arrange
Un autre cas type est de vouloir réarranger les colonnes d'un tableau de données par ordre croissant/décroissant. Pour ce faire, la fonction *arrange* permet de classer les observations d'un jeu de données selon l'ordre d'une ou plusieurs de ses colonnes.


```r
# Réorganiser les lignes d'un jeu de données
df %>% arrange(Sitelle)
```

```
   Parcelle Merle Sitelle Pics                     Station Identifiant_1
1         4     0       0    0   plusieurs_stations/foret1             4
2         4     2       0    0   plusieurs_stations/foret2             9
3         5     0       0    3   plusieurs_stations/foret2            10
4         1     0       0    1 plusieurs_stations/prairie1            11
5         4     1       0    2 plusieurs_stations/prairie1            14
6         5     1       0    1 plusieurs_stations/prairie1            15
7         4     1       0    2 plusieurs_stations/prairie2            19
8         5     1       0    1 plusieurs_stations/prairie2            20
9         2    39       1    1   plusieurs_stations/foret1             2
10        5     1       1    0   plusieurs_stations/foret1             5
11        3     0       1    1   plusieurs_stations/foret2             8
12        2     3       1    0 plusieurs_stations/prairie1            12
13        3     0       2    2   plusieurs_stations/foret1             3
14        1     1       2    1   plusieurs_stations/foret2             6
15        2     4       2    0   plusieurs_stations/foret2             7
16        1     1       3    1   plusieurs_stations/foret1             1
17        1     1       4    1 plusieurs_stations/prairie2            16
18        2     2       4    0 plusieurs_stations/prairie2            17
19        3     3       4    1 plusieurs_stations/prairie2            18
20        3     0       5    3 plusieurs_stations/prairie1            13
                    identifiant2
1    plusieurs_stations/foret1_4
2    plusieurs_stations/foret2_4
3    plusieurs_stations/foret2_5
4  plusieurs_stations/prairie1_1
5  plusieurs_stations/prairie1_4
6  plusieurs_stations/prairie1_5
7  plusieurs_stations/prairie2_4
8  plusieurs_stations/prairie2_5
9    plusieurs_stations/foret1_2
10   plusieurs_stations/foret1_5
11   plusieurs_stations/foret2_3
12 plusieurs_stations/prairie1_2
13   plusieurs_stations/foret1_3
14   plusieurs_stations/foret2_1
15   plusieurs_stations/foret2_2
16   plusieurs_stations/foret1_1
17 plusieurs_stations/prairie2_1
18 plusieurs_stations/prairie2_2
19 plusieurs_stations/prairie2_3
20 plusieurs_stations/prairie1_3
```

```r
# Pour réorganiser selon 2 colonnes à la fois
df %>% arrange(Parcelle,Station)
```

```
   Parcelle Merle Sitelle Pics                     Station Identifiant_1
1         1     1       3    1   plusieurs_stations/foret1             1
2         1     1       2    1   plusieurs_stations/foret2             6
3         1     0       0    1 plusieurs_stations/prairie1            11
4         1     1       4    1 plusieurs_stations/prairie2            16
5         2    39       1    1   plusieurs_stations/foret1             2
6         2     4       2    0   plusieurs_stations/foret2             7
7         2     3       1    0 plusieurs_stations/prairie1            12
8         2     2       4    0 plusieurs_stations/prairie2            17
9         3     0       2    2   plusieurs_stations/foret1             3
10        3     0       1    1   plusieurs_stations/foret2             8
11        3     0       5    3 plusieurs_stations/prairie1            13
12        3     3       4    1 plusieurs_stations/prairie2            18
13        4     0       0    0   plusieurs_stations/foret1             4
14        4     2       0    0   plusieurs_stations/foret2             9
15        4     1       0    2 plusieurs_stations/prairie1            14
16        4     1       0    2 plusieurs_stations/prairie2            19
17        5     1       1    0   plusieurs_stations/foret1             5
18        5     0       0    3   plusieurs_stations/foret2            10
19        5     1       0    1 plusieurs_stations/prairie1            15
20        5     1       0    1 plusieurs_stations/prairie2            20
                    identifiant2
1    plusieurs_stations/foret1_1
2    plusieurs_stations/foret2_1
3  plusieurs_stations/prairie1_1
4  plusieurs_stations/prairie2_1
5    plusieurs_stations/foret1_2
6    plusieurs_stations/foret2_2
7  plusieurs_stations/prairie1_2
8  plusieurs_stations/prairie2_2
9    plusieurs_stations/foret1_3
10   plusieurs_stations/foret2_3
11 plusieurs_stations/prairie1_3
12 plusieurs_stations/prairie2_3
13   plusieurs_stations/foret1_4
14   plusieurs_stations/foret2_4
15 plusieurs_stations/prairie1_4
16 plusieurs_stations/prairie2_4
17   plusieurs_stations/foret1_5
18   plusieurs_stations/foret2_5
19 plusieurs_stations/prairie1_5
20 plusieurs_stations/prairie2_5
```


### Filter
Enfin la fonction *filter* permet de filtrer les valeurs d'une colonne. Les filtres sont notamment une alternative qui permet souvent de limiter le nombre de sous jeux de données que nous créons. 

```r
# Filtrer les valeurs d'une colonne pour en faire un sous jeu de données
df %>% filter(Parcelle>3)
```

```
  Parcelle Merle Sitelle Pics                     Station Identifiant_1
1        4     0       0    0   plusieurs_stations/foret1             4
2        5     1       1    0   plusieurs_stations/foret1             5
3        4     2       0    0   plusieurs_stations/foret2             9
4        5     0       0    3   plusieurs_stations/foret2            10
5        4     1       0    2 plusieurs_stations/prairie1            14
6        5     1       0    1 plusieurs_stations/prairie1            15
7        4     1       0    2 plusieurs_stations/prairie2            19
8        5     1       0    1 plusieurs_stations/prairie2            20
                   identifiant2
1   plusieurs_stations/foret1_4
2   plusieurs_stations/foret1_5
3   plusieurs_stations/foret2_4
4   plusieurs_stations/foret2_5
5 plusieurs_stations/prairie1_4
6 plusieurs_stations/prairie1_5
7 plusieurs_stations/prairie2_4
8 plusieurs_stations/prairie2_5
```

### Filter + Str
Il est aussi possible de filtrer selon plusieurs valeurs à la fois, cependant cela demande l'utilisation d'outils appartenant au package *Stringr* (inclus dans le Tidyverse) pour aller faire plusieurs filtres simultanés.


```r
# Filtrer les valeurs d'une colonne pour en faire un sous jeu de données basé sur l'espèce d'oiseau
df %>% filter(Merle!=0, Pics==2)
```

```
  Parcelle Merle Sitelle Pics                     Station Identifiant_1
1        4     1       0    2 plusieurs_stations/prairie1            14
2        4     1       0    2 plusieurs_stations/prairie2            19
                   identifiant2
1 plusieurs_stations/prairie1_4
2 plusieurs_stations/prairie2_4
```

```r
#Pour filtrer deux valeurs dans une même colonne
df %>% filter(str_detect(Station,"prairie2|foret2")) # Ici la barre verticale | signifie "ou"
```

```
   Parcelle Merle Sitelle Pics                     Station Identifiant_1
1         1     1       2    1   plusieurs_stations/foret2             6
2         2     4       2    0   plusieurs_stations/foret2             7
3         3     0       1    1   plusieurs_stations/foret2             8
4         4     2       0    0   plusieurs_stations/foret2             9
5         5     0       0    3   plusieurs_stations/foret2            10
6         1     1       4    1 plusieurs_stations/prairie2            16
7         2     2       4    0 plusieurs_stations/prairie2            17
8         3     3       4    1 plusieurs_stations/prairie2            18
9         4     1       0    2 plusieurs_stations/prairie2            19
10        5     1       0    1 plusieurs_stations/prairie2            20
                    identifiant2
1    plusieurs_stations/foret2_1
2    plusieurs_stations/foret2_2
3    plusieurs_stations/foret2_3
4    plusieurs_stations/foret2_4
5    plusieurs_stations/foret2_5
6  plusieurs_stations/prairie2_1
7  plusieurs_stations/prairie2_2
8  plusieurs_stations/prairie2_3
9  plusieurs_stations/prairie2_4
10 plusieurs_stations/prairie2_5
```

### Gather/Spread
Lorsqu'un jeu de données contient plus d'une colonne par observation, il est possible d'inverser les lignes et les colonnes du jeu de données. La fonction *gather* rapporte le tableau à une observation par ligne. À l'inverse, la fonction *spread* vient étendre un tableau qui était sous la forme d'une observation par ligne en subdivisant les observations en différentes colonnes.



```r
# Inverser les colonnes et les lignes pour avoir une seule observation par ligne
df %>% gather(key ="Espèce",value = "Nb_oiseaux") 
```

```
           Espèce                    Nb_oiseaux
1        Parcelle                             1
2        Parcelle                             2
3        Parcelle                             3
4        Parcelle                             4
5        Parcelle                             5
6        Parcelle                             1
7        Parcelle                             2
8        Parcelle                             3
9        Parcelle                             4
10       Parcelle                             5
11       Parcelle                             1
12       Parcelle                             2
13       Parcelle                             3
14       Parcelle                             4
15       Parcelle                             5
16       Parcelle                             1
17       Parcelle                             2
18       Parcelle                             3
19       Parcelle                             4
20       Parcelle                             5
21          Merle                             1
22          Merle                            39
23          Merle                             0
24          Merle                             0
25          Merle                             1
26          Merle                             1
27          Merle                             4
28          Merle                             0
29          Merle                             2
30          Merle                             0
31          Merle                             0
32          Merle                             3
33          Merle                             0
34          Merle                             1
35          Merle                             1
36          Merle                             1
37          Merle                             2
38          Merle                             3
39          Merle                             1
40          Merle                             1
41        Sitelle                             3
42        Sitelle                             1
43        Sitelle                             2
44        Sitelle                             0
45        Sitelle                             1
46        Sitelle                             2
47        Sitelle                             2
48        Sitelle                             1
49        Sitelle                             0
50        Sitelle                             0
51        Sitelle                             0
52        Sitelle                             1
53        Sitelle                             5
54        Sitelle                             0
55        Sitelle                             0
56        Sitelle                             4
57        Sitelle                             4
58        Sitelle                             4
59        Sitelle                             0
60        Sitelle                             0
61           Pics                             1
62           Pics                             1
63           Pics                             2
64           Pics                             0
65           Pics                             0
66           Pics                             1
67           Pics                             0
68           Pics                             1
69           Pics                             0
70           Pics                             3
71           Pics                             1
72           Pics                             0
73           Pics                             3
74           Pics                             2
75           Pics                             1
76           Pics                             1
77           Pics                             0
78           Pics                             1
79           Pics                             2
80           Pics                             1
81        Station     plusieurs_stations/foret1
82        Station     plusieurs_stations/foret1
83        Station     plusieurs_stations/foret1
84        Station     plusieurs_stations/foret1
85        Station     plusieurs_stations/foret1
86        Station     plusieurs_stations/foret2
87        Station     plusieurs_stations/foret2
88        Station     plusieurs_stations/foret2
89        Station     plusieurs_stations/foret2
90        Station     plusieurs_stations/foret2
91        Station   plusieurs_stations/prairie1
92        Station   plusieurs_stations/prairie1
93        Station   plusieurs_stations/prairie1
94        Station   plusieurs_stations/prairie1
95        Station   plusieurs_stations/prairie1
96        Station   plusieurs_stations/prairie2
97        Station   plusieurs_stations/prairie2
98        Station   plusieurs_stations/prairie2
99        Station   plusieurs_stations/prairie2
100       Station   plusieurs_stations/prairie2
101 Identifiant_1                             1
102 Identifiant_1                             2
103 Identifiant_1                             3
104 Identifiant_1                             4
105 Identifiant_1                             5
106 Identifiant_1                             6
107 Identifiant_1                             7
108 Identifiant_1                             8
109 Identifiant_1                             9
110 Identifiant_1                            10
111 Identifiant_1                            11
112 Identifiant_1                            12
113 Identifiant_1                            13
114 Identifiant_1                            14
115 Identifiant_1                            15
116 Identifiant_1                            16
117 Identifiant_1                            17
118 Identifiant_1                            18
119 Identifiant_1                            19
120 Identifiant_1                            20
121  identifiant2   plusieurs_stations/foret1_1
122  identifiant2   plusieurs_stations/foret1_2
123  identifiant2   plusieurs_stations/foret1_3
124  identifiant2   plusieurs_stations/foret1_4
125  identifiant2   plusieurs_stations/foret1_5
126  identifiant2   plusieurs_stations/foret2_1
127  identifiant2   plusieurs_stations/foret2_2
128  identifiant2   plusieurs_stations/foret2_3
129  identifiant2   plusieurs_stations/foret2_4
130  identifiant2   plusieurs_stations/foret2_5
131  identifiant2 plusieurs_stations/prairie1_1
132  identifiant2 plusieurs_stations/prairie1_2
133  identifiant2 plusieurs_stations/prairie1_3
134  identifiant2 plusieurs_stations/prairie1_4
135  identifiant2 plusieurs_stations/prairie1_5
136  identifiant2 plusieurs_stations/prairie2_1
137  identifiant2 plusieurs_stations/prairie2_2
138  identifiant2 plusieurs_stations/prairie2_3
139  identifiant2 plusieurs_stations/prairie2_4
140  identifiant2 plusieurs_stations/prairie2_5
```


```r
# Lorsqu'on conserve une ligne supplémentaire
test<-df %>% gather(key ="Espèce",value = "Nb_oiseaux",-identifiant2)

test
```

```
                     identifiant2        Espèce                  Nb_oiseaux
1     plusieurs_stations/foret1_1      Parcelle                           1
2     plusieurs_stations/foret1_2      Parcelle                           2
3     plusieurs_stations/foret1_3      Parcelle                           3
4     plusieurs_stations/foret1_4      Parcelle                           4
5     plusieurs_stations/foret1_5      Parcelle                           5
6     plusieurs_stations/foret2_1      Parcelle                           1
7     plusieurs_stations/foret2_2      Parcelle                           2
8     plusieurs_stations/foret2_3      Parcelle                           3
9     plusieurs_stations/foret2_4      Parcelle                           4
10    plusieurs_stations/foret2_5      Parcelle                           5
11  plusieurs_stations/prairie1_1      Parcelle                           1
12  plusieurs_stations/prairie1_2      Parcelle                           2
13  plusieurs_stations/prairie1_3      Parcelle                           3
14  plusieurs_stations/prairie1_4      Parcelle                           4
15  plusieurs_stations/prairie1_5      Parcelle                           5
16  plusieurs_stations/prairie2_1      Parcelle                           1
17  plusieurs_stations/prairie2_2      Parcelle                           2
18  plusieurs_stations/prairie2_3      Parcelle                           3
19  plusieurs_stations/prairie2_4      Parcelle                           4
20  plusieurs_stations/prairie2_5      Parcelle                           5
21    plusieurs_stations/foret1_1         Merle                           1
22    plusieurs_stations/foret1_2         Merle                          39
23    plusieurs_stations/foret1_3         Merle                           0
24    plusieurs_stations/foret1_4         Merle                           0
25    plusieurs_stations/foret1_5         Merle                           1
26    plusieurs_stations/foret2_1         Merle                           1
27    plusieurs_stations/foret2_2         Merle                           4
28    plusieurs_stations/foret2_3         Merle                           0
29    plusieurs_stations/foret2_4         Merle                           2
30    plusieurs_stations/foret2_5         Merle                           0
31  plusieurs_stations/prairie1_1         Merle                           0
32  plusieurs_stations/prairie1_2         Merle                           3
33  plusieurs_stations/prairie1_3         Merle                           0
34  plusieurs_stations/prairie1_4         Merle                           1
35  plusieurs_stations/prairie1_5         Merle                           1
36  plusieurs_stations/prairie2_1         Merle                           1
37  plusieurs_stations/prairie2_2         Merle                           2
38  plusieurs_stations/prairie2_3         Merle                           3
39  plusieurs_stations/prairie2_4         Merle                           1
40  plusieurs_stations/prairie2_5         Merle                           1
41    plusieurs_stations/foret1_1       Sitelle                           3
42    plusieurs_stations/foret1_2       Sitelle                           1
43    plusieurs_stations/foret1_3       Sitelle                           2
44    plusieurs_stations/foret1_4       Sitelle                           0
45    plusieurs_stations/foret1_5       Sitelle                           1
46    plusieurs_stations/foret2_1       Sitelle                           2
47    plusieurs_stations/foret2_2       Sitelle                           2
48    plusieurs_stations/foret2_3       Sitelle                           1
49    plusieurs_stations/foret2_4       Sitelle                           0
50    plusieurs_stations/foret2_5       Sitelle                           0
51  plusieurs_stations/prairie1_1       Sitelle                           0
52  plusieurs_stations/prairie1_2       Sitelle                           1
53  plusieurs_stations/prairie1_3       Sitelle                           5
54  plusieurs_stations/prairie1_4       Sitelle                           0
55  plusieurs_stations/prairie1_5       Sitelle                           0
56  plusieurs_stations/prairie2_1       Sitelle                           4
57  plusieurs_stations/prairie2_2       Sitelle                           4
58  plusieurs_stations/prairie2_3       Sitelle                           4
59  plusieurs_stations/prairie2_4       Sitelle                           0
60  plusieurs_stations/prairie2_5       Sitelle                           0
61    plusieurs_stations/foret1_1          Pics                           1
62    plusieurs_stations/foret1_2          Pics                           1
63    plusieurs_stations/foret1_3          Pics                           2
64    plusieurs_stations/foret1_4          Pics                           0
65    plusieurs_stations/foret1_5          Pics                           0
66    plusieurs_stations/foret2_1          Pics                           1
67    plusieurs_stations/foret2_2          Pics                           0
68    plusieurs_stations/foret2_3          Pics                           1
69    plusieurs_stations/foret2_4          Pics                           0
70    plusieurs_stations/foret2_5          Pics                           3
71  plusieurs_stations/prairie1_1          Pics                           1
72  plusieurs_stations/prairie1_2          Pics                           0
73  plusieurs_stations/prairie1_3          Pics                           3
74  plusieurs_stations/prairie1_4          Pics                           2
75  plusieurs_stations/prairie1_5          Pics                           1
76  plusieurs_stations/prairie2_1          Pics                           1
77  plusieurs_stations/prairie2_2          Pics                           0
78  plusieurs_stations/prairie2_3          Pics                           1
79  plusieurs_stations/prairie2_4          Pics                           2
80  plusieurs_stations/prairie2_5          Pics                           1
81    plusieurs_stations/foret1_1       Station   plusieurs_stations/foret1
82    plusieurs_stations/foret1_2       Station   plusieurs_stations/foret1
83    plusieurs_stations/foret1_3       Station   plusieurs_stations/foret1
84    plusieurs_stations/foret1_4       Station   plusieurs_stations/foret1
85    plusieurs_stations/foret1_5       Station   plusieurs_stations/foret1
86    plusieurs_stations/foret2_1       Station   plusieurs_stations/foret2
87    plusieurs_stations/foret2_2       Station   plusieurs_stations/foret2
88    plusieurs_stations/foret2_3       Station   plusieurs_stations/foret2
89    plusieurs_stations/foret2_4       Station   plusieurs_stations/foret2
90    plusieurs_stations/foret2_5       Station   plusieurs_stations/foret2
91  plusieurs_stations/prairie1_1       Station plusieurs_stations/prairie1
92  plusieurs_stations/prairie1_2       Station plusieurs_stations/prairie1
93  plusieurs_stations/prairie1_3       Station plusieurs_stations/prairie1
94  plusieurs_stations/prairie1_4       Station plusieurs_stations/prairie1
95  plusieurs_stations/prairie1_5       Station plusieurs_stations/prairie1
96  plusieurs_stations/prairie2_1       Station plusieurs_stations/prairie2
97  plusieurs_stations/prairie2_2       Station plusieurs_stations/prairie2
98  plusieurs_stations/prairie2_3       Station plusieurs_stations/prairie2
99  plusieurs_stations/prairie2_4       Station plusieurs_stations/prairie2
100 plusieurs_stations/prairie2_5       Station plusieurs_stations/prairie2
101   plusieurs_stations/foret1_1 Identifiant_1                           1
102   plusieurs_stations/foret1_2 Identifiant_1                           2
103   plusieurs_stations/foret1_3 Identifiant_1                           3
104   plusieurs_stations/foret1_4 Identifiant_1                           4
105   plusieurs_stations/foret1_5 Identifiant_1                           5
106   plusieurs_stations/foret2_1 Identifiant_1                           6
107   plusieurs_stations/foret2_2 Identifiant_1                           7
108   plusieurs_stations/foret2_3 Identifiant_1                           8
109   plusieurs_stations/foret2_4 Identifiant_1                           9
110   plusieurs_stations/foret2_5 Identifiant_1                          10
111 plusieurs_stations/prairie1_1 Identifiant_1                          11
112 plusieurs_stations/prairie1_2 Identifiant_1                          12
113 plusieurs_stations/prairie1_3 Identifiant_1                          13
114 plusieurs_stations/prairie1_4 Identifiant_1                          14
115 plusieurs_stations/prairie1_5 Identifiant_1                          15
116 plusieurs_stations/prairie2_1 Identifiant_1                          16
117 plusieurs_stations/prairie2_2 Identifiant_1                          17
118 plusieurs_stations/prairie2_3 Identifiant_1                          18
119 plusieurs_stations/prairie2_4 Identifiant_1                          19
120 plusieurs_stations/prairie2_5 Identifiant_1                          20
```


```r
# Lorsqu'on conserve deux lignes supplémentaires
test2<-df %>% gather(key ="Espèce",value = "Nb_oiseaux",-identifiant2,-Station)

test2 # On voit que ça ne change pas grand chose
```

```
                        Station                  identifiant2        Espèce
1     plusieurs_stations/foret1   plusieurs_stations/foret1_1      Parcelle
2     plusieurs_stations/foret1   plusieurs_stations/foret1_2      Parcelle
3     plusieurs_stations/foret1   plusieurs_stations/foret1_3      Parcelle
4     plusieurs_stations/foret1   plusieurs_stations/foret1_4      Parcelle
5     plusieurs_stations/foret1   plusieurs_stations/foret1_5      Parcelle
6     plusieurs_stations/foret2   plusieurs_stations/foret2_1      Parcelle
7     plusieurs_stations/foret2   plusieurs_stations/foret2_2      Parcelle
8     plusieurs_stations/foret2   plusieurs_stations/foret2_3      Parcelle
9     plusieurs_stations/foret2   plusieurs_stations/foret2_4      Parcelle
10    plusieurs_stations/foret2   plusieurs_stations/foret2_5      Parcelle
11  plusieurs_stations/prairie1 plusieurs_stations/prairie1_1      Parcelle
12  plusieurs_stations/prairie1 plusieurs_stations/prairie1_2      Parcelle
13  plusieurs_stations/prairie1 plusieurs_stations/prairie1_3      Parcelle
14  plusieurs_stations/prairie1 plusieurs_stations/prairie1_4      Parcelle
15  plusieurs_stations/prairie1 plusieurs_stations/prairie1_5      Parcelle
16  plusieurs_stations/prairie2 plusieurs_stations/prairie2_1      Parcelle
17  plusieurs_stations/prairie2 plusieurs_stations/prairie2_2      Parcelle
18  plusieurs_stations/prairie2 plusieurs_stations/prairie2_3      Parcelle
19  plusieurs_stations/prairie2 plusieurs_stations/prairie2_4      Parcelle
20  plusieurs_stations/prairie2 plusieurs_stations/prairie2_5      Parcelle
21    plusieurs_stations/foret1   plusieurs_stations/foret1_1         Merle
22    plusieurs_stations/foret1   plusieurs_stations/foret1_2         Merle
23    plusieurs_stations/foret1   plusieurs_stations/foret1_3         Merle
24    plusieurs_stations/foret1   plusieurs_stations/foret1_4         Merle
25    plusieurs_stations/foret1   plusieurs_stations/foret1_5         Merle
26    plusieurs_stations/foret2   plusieurs_stations/foret2_1         Merle
27    plusieurs_stations/foret2   plusieurs_stations/foret2_2         Merle
28    plusieurs_stations/foret2   plusieurs_stations/foret2_3         Merle
29    plusieurs_stations/foret2   plusieurs_stations/foret2_4         Merle
30    plusieurs_stations/foret2   plusieurs_stations/foret2_5         Merle
31  plusieurs_stations/prairie1 plusieurs_stations/prairie1_1         Merle
32  plusieurs_stations/prairie1 plusieurs_stations/prairie1_2         Merle
33  plusieurs_stations/prairie1 plusieurs_stations/prairie1_3         Merle
34  plusieurs_stations/prairie1 plusieurs_stations/prairie1_4         Merle
35  plusieurs_stations/prairie1 plusieurs_stations/prairie1_5         Merle
36  plusieurs_stations/prairie2 plusieurs_stations/prairie2_1         Merle
37  plusieurs_stations/prairie2 plusieurs_stations/prairie2_2         Merle
38  plusieurs_stations/prairie2 plusieurs_stations/prairie2_3         Merle
39  plusieurs_stations/prairie2 plusieurs_stations/prairie2_4         Merle
40  plusieurs_stations/prairie2 plusieurs_stations/prairie2_5         Merle
41    plusieurs_stations/foret1   plusieurs_stations/foret1_1       Sitelle
42    plusieurs_stations/foret1   plusieurs_stations/foret1_2       Sitelle
43    plusieurs_stations/foret1   plusieurs_stations/foret1_3       Sitelle
44    plusieurs_stations/foret1   plusieurs_stations/foret1_4       Sitelle
45    plusieurs_stations/foret1   plusieurs_stations/foret1_5       Sitelle
46    plusieurs_stations/foret2   plusieurs_stations/foret2_1       Sitelle
47    plusieurs_stations/foret2   plusieurs_stations/foret2_2       Sitelle
48    plusieurs_stations/foret2   plusieurs_stations/foret2_3       Sitelle
49    plusieurs_stations/foret2   plusieurs_stations/foret2_4       Sitelle
50    plusieurs_stations/foret2   plusieurs_stations/foret2_5       Sitelle
51  plusieurs_stations/prairie1 plusieurs_stations/prairie1_1       Sitelle
52  plusieurs_stations/prairie1 plusieurs_stations/prairie1_2       Sitelle
53  plusieurs_stations/prairie1 plusieurs_stations/prairie1_3       Sitelle
54  plusieurs_stations/prairie1 plusieurs_stations/prairie1_4       Sitelle
55  plusieurs_stations/prairie1 plusieurs_stations/prairie1_5       Sitelle
56  plusieurs_stations/prairie2 plusieurs_stations/prairie2_1       Sitelle
57  plusieurs_stations/prairie2 plusieurs_stations/prairie2_2       Sitelle
58  plusieurs_stations/prairie2 plusieurs_stations/prairie2_3       Sitelle
59  plusieurs_stations/prairie2 plusieurs_stations/prairie2_4       Sitelle
60  plusieurs_stations/prairie2 plusieurs_stations/prairie2_5       Sitelle
61    plusieurs_stations/foret1   plusieurs_stations/foret1_1          Pics
62    plusieurs_stations/foret1   plusieurs_stations/foret1_2          Pics
63    plusieurs_stations/foret1   plusieurs_stations/foret1_3          Pics
64    plusieurs_stations/foret1   plusieurs_stations/foret1_4          Pics
65    plusieurs_stations/foret1   plusieurs_stations/foret1_5          Pics
66    plusieurs_stations/foret2   plusieurs_stations/foret2_1          Pics
67    plusieurs_stations/foret2   plusieurs_stations/foret2_2          Pics
68    plusieurs_stations/foret2   plusieurs_stations/foret2_3          Pics
69    plusieurs_stations/foret2   plusieurs_stations/foret2_4          Pics
70    plusieurs_stations/foret2   plusieurs_stations/foret2_5          Pics
71  plusieurs_stations/prairie1 plusieurs_stations/prairie1_1          Pics
72  plusieurs_stations/prairie1 plusieurs_stations/prairie1_2          Pics
73  plusieurs_stations/prairie1 plusieurs_stations/prairie1_3          Pics
74  plusieurs_stations/prairie1 plusieurs_stations/prairie1_4          Pics
75  plusieurs_stations/prairie1 plusieurs_stations/prairie1_5          Pics
76  plusieurs_stations/prairie2 plusieurs_stations/prairie2_1          Pics
77  plusieurs_stations/prairie2 plusieurs_stations/prairie2_2          Pics
78  plusieurs_stations/prairie2 plusieurs_stations/prairie2_3          Pics
79  plusieurs_stations/prairie2 plusieurs_stations/prairie2_4          Pics
80  plusieurs_stations/prairie2 plusieurs_stations/prairie2_5          Pics
81    plusieurs_stations/foret1   plusieurs_stations/foret1_1 Identifiant_1
82    plusieurs_stations/foret1   plusieurs_stations/foret1_2 Identifiant_1
83    plusieurs_stations/foret1   plusieurs_stations/foret1_3 Identifiant_1
84    plusieurs_stations/foret1   plusieurs_stations/foret1_4 Identifiant_1
85    plusieurs_stations/foret1   plusieurs_stations/foret1_5 Identifiant_1
86    plusieurs_stations/foret2   plusieurs_stations/foret2_1 Identifiant_1
87    plusieurs_stations/foret2   plusieurs_stations/foret2_2 Identifiant_1
88    plusieurs_stations/foret2   plusieurs_stations/foret2_3 Identifiant_1
89    plusieurs_stations/foret2   plusieurs_stations/foret2_4 Identifiant_1
90    plusieurs_stations/foret2   plusieurs_stations/foret2_5 Identifiant_1
91  plusieurs_stations/prairie1 plusieurs_stations/prairie1_1 Identifiant_1
92  plusieurs_stations/prairie1 plusieurs_stations/prairie1_2 Identifiant_1
93  plusieurs_stations/prairie1 plusieurs_stations/prairie1_3 Identifiant_1
94  plusieurs_stations/prairie1 plusieurs_stations/prairie1_4 Identifiant_1
95  plusieurs_stations/prairie1 plusieurs_stations/prairie1_5 Identifiant_1
96  plusieurs_stations/prairie2 plusieurs_stations/prairie2_1 Identifiant_1
97  plusieurs_stations/prairie2 plusieurs_stations/prairie2_2 Identifiant_1
98  plusieurs_stations/prairie2 plusieurs_stations/prairie2_3 Identifiant_1
99  plusieurs_stations/prairie2 plusieurs_stations/prairie2_4 Identifiant_1
100 plusieurs_stations/prairie2 plusieurs_stations/prairie2_5 Identifiant_1
    Nb_oiseaux
1            1
2            2
3            3
4            4
5            5
6            1
7            2
8            3
9            4
10           5
11           1
12           2
13           3
14           4
15           5
16           1
17           2
18           3
19           4
20           5
21           1
22          39
23           0
24           0
25           1
26           1
27           4
28           0
29           2
30           0
31           0
32           3
33           0
34           1
35           1
36           1
37           2
38           3
39           1
40           1
41           3
42           1
43           2
44           0
45           1
46           2
47           2
48           1
49           0
50           0
51           0
52           1
53           5
54           0
55           0
56           4
57           4
58           4
59           0
60           0
61           1
62           1
63           2
64           0
65           0
66           1
67           0
68           1
69           0
70           3
71           1
72           0
73           3
74           2
75           1
76           1
77           0
78           1
79           2
80           1
81           1
82           2
83           3
84           4
85           5
86           6
87           7
88           8
89           9
90          10
91          11
92          12
93          13
94          14
95          15
96          16
97          17
98          18
99          19
100         20
```



```r
# Sous cette forme, certaines lignes deviennent caduques, on peut donc les retirer avec un "slice"

test<-test %>% slice(21:80) # Car on focus sur la clé qui est l'espèce. Lorsque l'espèce n'est pas respecté, on peut suspecter que ce n'est pas une vrai donnée. Une alternative aurait été de supprimer la colonne identifiant 1 auparavant.

test
```

```
                    identifiant2  Espèce Nb_oiseaux
1    plusieurs_stations/foret1_1   Merle          1
2    plusieurs_stations/foret1_2   Merle         39
3    plusieurs_stations/foret1_3   Merle          0
4    plusieurs_stations/foret1_4   Merle          0
5    plusieurs_stations/foret1_5   Merle          1
6    plusieurs_stations/foret2_1   Merle          1
7    plusieurs_stations/foret2_2   Merle          4
8    plusieurs_stations/foret2_3   Merle          0
9    plusieurs_stations/foret2_4   Merle          2
10   plusieurs_stations/foret2_5   Merle          0
11 plusieurs_stations/prairie1_1   Merle          0
12 plusieurs_stations/prairie1_2   Merle          3
13 plusieurs_stations/prairie1_3   Merle          0
14 plusieurs_stations/prairie1_4   Merle          1
15 plusieurs_stations/prairie1_5   Merle          1
16 plusieurs_stations/prairie2_1   Merle          1
17 plusieurs_stations/prairie2_2   Merle          2
18 plusieurs_stations/prairie2_3   Merle          3
19 plusieurs_stations/prairie2_4   Merle          1
20 plusieurs_stations/prairie2_5   Merle          1
21   plusieurs_stations/foret1_1 Sitelle          3
22   plusieurs_stations/foret1_2 Sitelle          1
23   plusieurs_stations/foret1_3 Sitelle          2
24   plusieurs_stations/foret1_4 Sitelle          0
25   plusieurs_stations/foret1_5 Sitelle          1
26   plusieurs_stations/foret2_1 Sitelle          2
27   plusieurs_stations/foret2_2 Sitelle          2
28   plusieurs_stations/foret2_3 Sitelle          1
29   plusieurs_stations/foret2_4 Sitelle          0
30   plusieurs_stations/foret2_5 Sitelle          0
31 plusieurs_stations/prairie1_1 Sitelle          0
32 plusieurs_stations/prairie1_2 Sitelle          1
33 plusieurs_stations/prairie1_3 Sitelle          5
34 plusieurs_stations/prairie1_4 Sitelle          0
35 plusieurs_stations/prairie1_5 Sitelle          0
36 plusieurs_stations/prairie2_1 Sitelle          4
37 plusieurs_stations/prairie2_2 Sitelle          4
38 plusieurs_stations/prairie2_3 Sitelle          4
39 plusieurs_stations/prairie2_4 Sitelle          0
40 plusieurs_stations/prairie2_5 Sitelle          0
41   plusieurs_stations/foret1_1    Pics          1
42   plusieurs_stations/foret1_2    Pics          1
43   plusieurs_stations/foret1_3    Pics          2
44   plusieurs_stations/foret1_4    Pics          0
45   plusieurs_stations/foret1_5    Pics          0
46   plusieurs_stations/foret2_1    Pics          1
47   plusieurs_stations/foret2_2    Pics          0
48   plusieurs_stations/foret2_3    Pics          1
49   plusieurs_stations/foret2_4    Pics          0
50   plusieurs_stations/foret2_5    Pics          3
51 plusieurs_stations/prairie1_1    Pics          1
52 plusieurs_stations/prairie1_2    Pics          0
53 plusieurs_stations/prairie1_3    Pics          3
54 plusieurs_stations/prairie1_4    Pics          2
55 plusieurs_stations/prairie1_5    Pics          1
56 plusieurs_stations/prairie2_1    Pics          1
57 plusieurs_stations/prairie2_2    Pics          0
58 plusieurs_stations/prairie2_3    Pics          1
59 plusieurs_stations/prairie2_4    Pics          2
60 plusieurs_stations/prairie2_5    Pics          1
```



```r
# Pour revenir au tableau de départ on utilise la fonction spread qui est l'inverse d'un gather

test %>% spread(key="Espèce",value= "Nb_oiseaux")
```

```
                    identifiant2 Merle Pics Sitelle
1    plusieurs_stations/foret1_1     1    1       3
2    plusieurs_stations/foret1_2    39    1       1
3    plusieurs_stations/foret1_3     0    2       2
4    plusieurs_stations/foret1_4     0    0       0
5    plusieurs_stations/foret1_5     1    0       1
6    plusieurs_stations/foret2_1     1    1       2
7    plusieurs_stations/foret2_2     4    0       2
8    plusieurs_stations/foret2_3     0    1       1
9    plusieurs_stations/foret2_4     2    0       0
10   plusieurs_stations/foret2_5     0    3       0
11 plusieurs_stations/prairie1_1     0    1       0
12 plusieurs_stations/prairie1_2     3    0       1
13 plusieurs_stations/prairie1_3     0    3       5
14 plusieurs_stations/prairie1_4     1    2       0
15 plusieurs_stations/prairie1_5     1    1       0
16 plusieurs_stations/prairie2_1     1    1       4
17 plusieurs_stations/prairie2_2     2    0       4
18 plusieurs_stations/prairie2_3     3    1       4
19 plusieurs_stations/prairie2_4     1    2       0
20 plusieurs_stations/prairie2_5     1    1       0
```

### Cut et breaks pour classer un champ numérique
Il arrive parfois que les observations soient à un niveau trop détaillé et qu'on veuille plutôt observer les tendances avec un certain recul. La création de classe serait la bienvenue.
La fonction *cut* permet de créer des intervalles dans les données selon un nombre de classes prédéfinis à partir d'un champ numérique.


```r
# Posons l'hypothèse que les données on été prises à des endroit sur un transect de 4 mètres et ajoutons la colonne en question
df<-df %>% mutate(Transect=(floor(runif(20,1,4))))


# Ajouter une colonne avec 5 classes selon l'emplacement sur un transect imaginaire
df %>% mutate(classes=cut(Transect,breaks=2))
```

```
   Parcelle Merle Sitelle Pics                     Station Identifiant_1
1         1     1       3    1   plusieurs_stations/foret1             1
2         2    39       1    1   plusieurs_stations/foret1             2
3         3     0       2    2   plusieurs_stations/foret1             3
4         4     0       0    0   plusieurs_stations/foret1             4
5         5     1       1    0   plusieurs_stations/foret1             5
6         1     1       2    1   plusieurs_stations/foret2             6
7         2     4       2    0   plusieurs_stations/foret2             7
8         3     0       1    1   plusieurs_stations/foret2             8
9         4     2       0    0   plusieurs_stations/foret2             9
10        5     0       0    3   plusieurs_stations/foret2            10
11        1     0       0    1 plusieurs_stations/prairie1            11
12        2     3       1    0 plusieurs_stations/prairie1            12
13        3     0       5    3 plusieurs_stations/prairie1            13
14        4     1       0    2 plusieurs_stations/prairie1            14
15        5     1       0    1 plusieurs_stations/prairie1            15
16        1     1       4    1 plusieurs_stations/prairie2            16
17        2     2       4    0 plusieurs_stations/prairie2            17
18        3     3       4    1 plusieurs_stations/prairie2            18
19        4     1       0    2 plusieurs_stations/prairie2            19
20        5     1       0    1 plusieurs_stations/prairie2            20
                    identifiant2 Transect   classes
1    plusieurs_stations/foret1_1        3     (2,3]
2    plusieurs_stations/foret1_2        2 (0.998,2]
3    plusieurs_stations/foret1_3        3     (2,3]
4    plusieurs_stations/foret1_4        3     (2,3]
5    plusieurs_stations/foret1_5        3     (2,3]
6    plusieurs_stations/foret2_1        2 (0.998,2]
7    plusieurs_stations/foret2_2        2 (0.998,2]
8    plusieurs_stations/foret2_3        1 (0.998,2]
9    plusieurs_stations/foret2_4        3     (2,3]
10   plusieurs_stations/foret2_5        3     (2,3]
11 plusieurs_stations/prairie1_1        2 (0.998,2]
12 plusieurs_stations/prairie1_2        3     (2,3]
13 plusieurs_stations/prairie1_3        2 (0.998,2]
14 plusieurs_stations/prairie1_4        2 (0.998,2]
15 plusieurs_stations/prairie1_5        2 (0.998,2]
16 plusieurs_stations/prairie2_1        3     (2,3]
17 plusieurs_stations/prairie2_2        2 (0.998,2]
18 plusieurs_stations/prairie2_3        1 (0.998,2]
19 plusieurs_stations/prairie2_4        3     (2,3]
20 plusieurs_stations/prairie2_5        1 (0.998,2]
```

# Étape 4: Quoi faire avec des données manquantes

Afin de savoir comment traiter nos données manquantes, il est important de connaître et comprendre les différents types reconnus par R. Il en existe trois:

- **NULL** : (En majuscule) Un objet retourné par R quand une expression ou le résultat d'une fonction est de valeur indéfinie; c'est à dire rien ou vide. NULL peut également être le produit lors d'importation de données de type inconnu pour R. Il est très rare d'en rencontrer dans une matrice (dataframe).
- **NaN** : Un vecteur logique de longueur 1. NaN signifie "Not a Number"et s'applique autant à des valeurs numériques qu'à des données plus complexes.
- **NA** : (En majuscule) Une constante logique de longueur 1. NA signifie "Not Available" et est l'indication d'une valeur maquante.

## Les NULL pour les nuls

Pour commencer, nous allons aller chercher à nouveau le jeu de données "airquality":


```r
data("airquality")
airquality
```


Les **NULL** représentent "pas de données" :


```r
airquality$GES <- I(list(NULL, NULL, NULL))
head(airquality) # création d'une colonne de NULL
```

```
  Ozone Solar.R Wind Temp Month Day  GES
1    41     190  7.4   67     5   1 NULL
2    36     118  8.0   72     5   2 NULL
3    12     149 12.6   74     5   3 NULL
4    18     313 11.5   62     5   4 NULL
5    NA      NA 14.3   56     5   5 NULL
6    28      NA 14.9   66     5   6 NULL
```

Les **NULL** peuvent être assignés à n'importe quelle valeur:


```r
airquality$GES <- NA # assignation de la colonne GES vers des valeurs manquantes

summary(airquality) # création de la colonne GES avec 153 NAs
```

```
     Ozone           Solar.R           Wind             Temp      
 Min.   :  1.00   Min.   :  7.0   Min.   : 1.700   Min.   :56.00  
 1st Qu.: 18.00   1st Qu.:115.8   1st Qu.: 7.400   1st Qu.:72.00  
 Median : 31.50   Median :205.0   Median : 9.700   Median :79.00  
 Mean   : 42.13   Mean   :185.9   Mean   : 9.958   Mean   :77.88  
 3rd Qu.: 63.25   3rd Qu.:258.8   3rd Qu.:11.500   3rd Qu.:85.00  
 Max.   :168.00   Max.   :334.0   Max.   :20.700   Max.   :97.00  
 NA's   :37       NA's   :7                                       
     Month            Day         GES         
 Min.   :5.000   Min.   : 1.0   Mode:logical  
 1st Qu.:6.000   1st Qu.: 8.0   NA's:153      
 Median :7.000   Median :16.0                 
 Mean   :6.993   Mean   :15.8                 
 3rd Qu.:8.000   3rd Qu.:23.0                 
 Max.   :9.000   Max.   :31.0                 
                                              
```

Ceci signifie que si vous avez des colonnes **NULL** dans un jeu de données, vous pouvez les assigner à des valeurs NAs ou à n'importe quelles autres catégories ou valeurs de votre choix:


```r
airquality$pollution <-I(list(NULL, NULL, NULL))
airquality$pollution <- "demonstration"

airquality$pollen <-I(list(NULL, NULL, NULL))
airquality$pollen <- c(1:153)

head(airquality)
```

```
  Ozone Solar.R Wind Temp Month Day GES     pollution pollen
1    41     190  7.4   67     5   1  NA demonstration      1
2    36     118  8.0   72     5   2  NA demonstration      2
3    12     149 12.6   74     5   3  NA demonstration      3
4    18     313 11.5   62     5   4  NA demonstration      4
5    NA      NA 14.3   56     5   5  NA demonstration      5
6    28      NA 14.9   66     5   6  NA demonstration      6
```

C'est l'équivalent de la création d'une nouvelle colonne.

## NaN  pour les nuls

Généralement, les ***NaN** et les **NAs** agissent généralement de la même manière dans un jeu de données. Ceci veut dire que même si les fonctions diffèrent un peu entre les deux types de données de manquantes, la syntaxe restera la même.

Commençons par introduire des **NaN** dans notre jeux de données:


```r
airquality$testNan <- ifelse(airquality$Ozone < 20, NaN, airquality$Ozone) #introduction de NaN dans notre jeu de données

head(airquality) 
```

```
  Ozone Solar.R Wind Temp Month Day GES     pollution pollen testNan
1    41     190  7.4   67     5   1  NA demonstration      1      41
2    36     118  8.0   72     5   2  NA demonstration      2      36
3    12     149 12.6   74     5   3  NA demonstration      3     NaN
4    18     313 11.5   62     5   4  NA demonstration      4     NaN
5    NA      NA 14.3   56     5   5  NA demonstration      5      NA
6    28      NA 14.9   66     5   6  NA demonstration      6      28
```

Voici quelques trucs pour traiter les **NaN** :

Identifier la position des **NaN**


```r
which(is.nan(airquality$testNan)) # donne les numéros de ligne comportant des NaN
```

```
 [1]   3   4   8   9  11  12  13  14  15  16  18  20  21  22  23  50  51  73  76
[20]  82  94  95 114 137 138 140 141 143 144 147 148 151 152
```

Compter le nombre NaN


```r
sum(is.nan(airquality$testNan)) # Il y a 33 NaN
```

```
[1] 33
```

Éliminer complètement les NaN


```r
test_no_nan <- data.frame(airquality$testNan[!is.nan(airquality$testNan)])#création d'un nouveau dataframe avec la colonne sans les NaN. Pas très pratique, mais faisable...
```

Remplacer les NaN (l'option la plus pratique!!!)


```r
airquality$testNan[is.nan(airquality$testNan)] <- NA # les NaN ont été remplacé par des NA. On aurait pu aussi les remplacer par des 0 sans problème

head(airquality)
```

```
  Ozone Solar.R Wind Temp Month Day GES     pollution pollen testNan
1    41     190  7.4   67     5   1  NA demonstration      1      41
2    36     118  8.0   72     5   2  NA demonstration      2      36
3    12     149 12.6   74     5   3  NA demonstration      3      NA
4    18     313 11.5   62     5   4  NA demonstration      4      NA
5    NA      NA 14.3   56     5   5  NA demonstration      5      NA
6    28      NA 14.9   66     5   6  NA demonstration      6      28
```

##NAs pour les nuls

Les **NAs** sont les données manquantes les plus communes. Tout comme les **NaN**, les mêmes opérations peuvent être effectuées. 

Identifier la position des **NAs**


```r
data(airquality)# Reprendre le jeu de données original
which(is.na(airquality)) # donne les numéros de ligne comportant des NAs
```

```
 [1]   5  10  25  26  27  32  33  34  35  36  37  39  42  43  45  46  52  53  54
[20]  55  56  57  58  59  60  61  65  72  75  83  84 102 103 107 115 119 150 158
[39] 159 164 180 249 250 251
```

Compter le nombre NAs


```r
sum(is.na(airquality)) # Il y a 44 NAs
```

```
[1] 44
```

Éliminer complètement les NAs


```r
airquality2<-na.omit(airquality)#Toute les lignes comportant des NAs ont été exclues. 
```

Remplacer les NAs par zéro


```r
airquality[is.na(airquality)] <- 0 # Les NAs ont tous été remplcés par des 0

head(airquality)
```

```
  Ozone Solar.R Wind Temp Month Day
1    41     190  7.4   67     5   1
2    36     118  8.0   72     5   2
3    12     149 12.6   74     5   3
4    18     313 11.5   62     5   4
5     0       0 14.3   56     5   5
6    28       0 14.9   66     5   6
```

Pour plusieurs fonctions statistiques, l'argument **na.rm = T** peut être utilisé, afin d'exclure les **NAs** durant le calcul. Les lignes contenant des **NAs** seront alors complètement exclues. Les fonctions les plus fréquantes sont:

- mean()
- sum()
- min()
- max()
- colSums()
- rda()
- etc...

# Étape 5: Imputations

Les données manquantes peuvent poser plusieurs problèmes lorsque vient le temps des analyses statistiques. Par exemple, certaines analyses peuvent ne pas fonctionner avec des **NAs** présents dans le jeu de données ou encore, avoir ces données manquantes pourrait augmenter le pouvoir statistiques de certains tests. La solution la plus simple est l'imputation. Il existe plusieurs paquets pouvant répondre à ce besoin. Ici, nous aborderons la méthode offerte par le paquet **mice**. Mice veut dire "Multivariate Imputation by Chained Equations".

Plusieurs méthodes d'imputation sont offertes par la fonction **mice()** via l'argument **meth = **. Voici les plus courantes:

-pmm : Méthode par défaut de la fonction. Technique d'imputation qui estime les données manquantes à partir des données déjà présentes. Les données peuvent être de n'importe quel type.

-logreg : Régression logistique. Modèle de régression binomiale permettant d'estimer les chances qu'un évènement se produise ou non. Les données doivent être binomiales.

-polyreg : Régression logistique multinomiale. Modèle de régression comme la régression logistique, mais généralisé à plus de deux classes. Les données doivent être des facteurs ou des caractères.

-mean : Moyenne. Utilise la moyenne de manière non-conditionnelle. Les données doivent être numériques 

Essayons d'imputer les données manquantes à notre jeu de données:


```r
data("airquality")
library("mice")
```

```

Attaching package: 'mice'
```

```
The following object is masked from 'package:stats':

    filter
```

```
The following objects are masked from 'package:base':

    cbind, rbind
```

```r
airquality.mice <- mice(airquality, meth = "pmm", maxit = 10)
```

```

 iter imp variable
  1   1  Ozone  Solar.R
  1   2  Ozone  Solar.R
  1   3  Ozone  Solar.R
  1   4  Ozone  Solar.R
  1   5  Ozone  Solar.R
  2   1  Ozone  Solar.R
  2   2  Ozone  Solar.R
  2   3  Ozone  Solar.R
  2   4  Ozone  Solar.R
  2   5  Ozone  Solar.R
  3   1  Ozone  Solar.R
  3   2  Ozone  Solar.R
  3   3  Ozone  Solar.R
  3   4  Ozone  Solar.R
  3   5  Ozone  Solar.R
  4   1  Ozone  Solar.R
  4   2  Ozone  Solar.R
  4   3  Ozone  Solar.R
  4   4  Ozone  Solar.R
  4   5  Ozone  Solar.R
  5   1  Ozone  Solar.R
  5   2  Ozone  Solar.R
  5   3  Ozone  Solar.R
  5   4  Ozone  Solar.R
  5   5  Ozone  Solar.R
  6   1  Ozone  Solar.R
  6   2  Ozone  Solar.R
  6   3  Ozone  Solar.R
  6   4  Ozone  Solar.R
  6   5  Ozone  Solar.R
  7   1  Ozone  Solar.R
  7   2  Ozone  Solar.R
  7   3  Ozone  Solar.R
  7   4  Ozone  Solar.R
  7   5  Ozone  Solar.R
  8   1  Ozone  Solar.R
  8   2  Ozone  Solar.R
  8   3  Ozone  Solar.R
  8   4  Ozone  Solar.R
  8   5  Ozone  Solar.R
  9   1  Ozone  Solar.R
  9   2  Ozone  Solar.R
  9   3  Ozone  Solar.R
  9   4  Ozone  Solar.R
  9   5  Ozone  Solar.R
  10   1  Ozone  Solar.R
  10   2  Ozone  Solar.R
  10   3  Ozone  Solar.R
  10   4  Ozone  Solar.R
  10   5  Ozone  Solar.R
```

```r
# "maxit = " représente le nombre d'itération effectuées par la fonction (par défaut c'est 5)
# Le résultat est une liste contenant nos variables, mais ce n'est pas très pratique!

airquality.complete <- complete(airquality.mice)# Permet d'ajouter les variables imputées au jeu de données

head(airquality.complete) #Fini les NAs!!!
```

```
  Ozone Solar.R Wind Temp Month Day
1    41     190  7.4   67     5   1
2    36     118  8.0   72     5   2
3    12     149 12.6   74     5   3
4    18     313 11.5   62     5   4
5     6     193 14.3   56     5   5
6    28     313 14.9   66     5   6
```

En espérant que cet atelier vous fera sauver du temps et des maux de tête dans un avenir pas si loin!

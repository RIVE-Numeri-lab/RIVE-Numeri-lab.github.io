---
title: Guide to using the Hmsc package for the production of Joint Species Distribution
  Models
author: "Geoffrey Marselli"
date: '2020-06-11'
layout: default
category: Stats
rbloggers: true
output: 
  html_document:
    keep_md: yes
    theme: readable
    toc: yes
    self_contained: no
---



This document presents the different steps to follow to produce a Joint Species Distribution Models (JSDM) and more precisely the one presented by Ovaskainen et al (2017) using the Hmsc package. This document is divided into several parts. First, the installation and download of the different packages and files that will be used.  Then, it presents the production of the statistical analysis under HMSC. Finally, it presents different tools to extract useful information from the posterior distribution of the model.

# **Installation and loading of the different packages and files**

## *Installation of the packages*

Before starting, it is necessary to install the different packages if they are not already installed. This part may not be done if the packages were already installed previously.


```r
install.packages("Hmsc")
install.packages("snow") In the event that it is not installed with Hmsc
install.packages("corrplot")
```


## *Package loading*

Here we load the packages, this step has to be done for the proper functioning of the code suite.


```r
library(Hmsc)
```

```
## Loading required package: coda
```

```r
library(corrplot)
```

```
## corrplot 0.84 loaded
```


## *Import of databases*

Here we are going to import the fungi dataset made from a dataset present in the [Guillaume Blanchet's Github](https://github.com/guiblanchet/) necessary to our analysis and that we have to download previously [here](/assets/Numerilab_HMSC_files/numerilab_data.zip). The dataset is composed of three csv files. First the main file including the species occurrence and the environmental variables for each sample. Secondly, a file containing the functional traits of each species. Finally, a phylogenetic distance file between each species.


```r
data = read.csv("fungiHMSC.csv")
phylo = read.csv("phyloHMSC.csv")
Tr = read.csv("TrHMSC.csv")
```

The three databases take the following forms :

```r
head(data)
```

```
##   site plot managed distance_to_edge decay diam Aleurodiscus.wakefieldiae
## 1    1    1       1              174     1    3                         0
## 2    1    1       1              174     1    1                         0
## 3    1    1       1              174     1    2                         0
## 4    1    1       1              174     1    8                         0
## 5    1    1       1              174     1    1                         0
## 6    1    1       1              174     1    1                         0
##   Athelopsis.glaucina Bisporella.citrina Ceriporia.reticulata
## 1                   0                  0                    0
## 2                   0                  0                    0
## 3                   0                  0                    0
## 4                   0                  0                    0
## 5                   0                  0                    0
## 6                   0                  0                    0
##   Crustomyces.subabruptus Dacrymyces.stillatus Diatrype.stigma
## 1                       0                    0               0
## 2                       0                    0               0
## 3                       0                    0               0
## 4                       0                    0               0
## 5                       0                    0               0
## 6                       0                    0               0
##   Eutypella.quaternata Fomes.fomentarius Fomitopsis.pinicola
## 1                    0                 0                   0
## 2                    0                 0                   0
## 3                    0                 0                   0
## 4                    0                 0                   0
## 5                    0                 0                   0
## 6                    0                 0                   0
##   Hyphoderma.cremeoalbum Hyphoderma.litschaueri Hyphoderma.roseocremeum
## 1                      0                      0                       0
## 2                      0                      0                       0
## 3                      0                      0                       0
## 4                      0                      0                       0
## 5                      0                      0                       0
## 6                      0                      0                       0
##   Hyphoderma.transiens Hyphodermella.rosae Hyphodontia.sambuci
## 1                    0                   0                   0
## 2                    0                   0                   0
## 3                    0                   0                   0
## 4                    0                   0                   0
## 5                    0                   0                   0
## 6                    0                   0                   0
##   Hypoxylon.fragiforme Hypoxylon.rubiginosum Junghuhnia.nitida
## 1                    0                     0                 0
## 2                    0                     0                 0
## 3                    0                     0                 0
## 4                    0                     0                 0
## 5                    0                     0                 0
## 6                    0                     0                 0
##   Kretzschmaria.deusta Marasmius.alliaceus Melogramma.spiniferum Mycoacia.uda
## 1                    0                   0                     0            0
## 2                    0                   0                     0            0
## 3                    0                   0                     0            0
## 4                    0                   0                     0            0
## 5                    0                   0                     0            0
## 6                    0                   0                     0            0
##   Peniophora.cinerea Phanerochaete.laevis Phanerochaete.sordida
## 1                  1                    0                     0
## 2                  0                    0                     0
## 3                  0                    0                     0
## 4                  0                    0                     0
## 5                  0                    0                     0
## 6                  0                    0                     0
##   Postia.subcaesia Rigidoporus.sanguinolentus Schizopora.flavipora
## 1                0                          0                    0
## 2                0                          0                    0
## 3                0                          0                    0
## 4                0                          0                    0
## 5                0                          0                    0
## 6                0                          0                    0
##   Scopuloides.rimosa Sidera.lenis Sistotrema.brinkmannii Skeletocutis.nivea
## 1                  0            0                      0                  0
## 2                  0            0                      0                  0
## 3                  0            0                      0                  0
## 4                  0            0                      0                  0
## 5                  0            0                      0                  0
## 6                  0            0                      0                  0
##   Stereum.ochraceoflavum Tapesia.fusca Tomentella.botryoides
## 1                      0             0                     0
## 2                      0             0                     0
## 3                      0             0                     0
## 4                      0             0                     0
## 5                      0             0                     0
## 6                      0             0                     0
##   Trametes.versicolor Trichaptum.biforme Tulasnella.violea Xylaria.hypoxylon
## 1                   0                  0                 0                 0
## 2                   0                  0                 0                 0
## 3                   0                  0                 0                 0
## 4                   0                  0                 0                 0
## 5                   0                  0                 0                 0
## 6                   0                  0                 0                 0
```

```r
head(phylo)
```

```
##   Aleurodiscus.wakefieldiae Athelopsis.glaucina Bisporella.citrina
## 1                         1                   0                  0
## 2                         0                   1                  0
## 3                         0                   0                  1
## 4                         0                   0                  0
## 5                         0                   0                  0
## 6                         0                   0                  0
##   Ceriporia.reticulata Crustomyces.subabruptus Dacrymyces.stillatus
## 1            0.0000000               0.0000000                    0
## 2            0.0000000               0.0000000                    0
## 3            0.0000000               0.0000000                    0
## 4            1.0000000               0.3333333                    0
## 5            0.3333333               1.0000000                    0
## 6            0.0000000               0.0000000                    1
##   Diatrype.stigma Eutypella.quaternata Fomes.fomentarius Fomitopsis.pinicola
## 1               0                    0         0.0000000           0.0000000
## 2               0                    0         0.0000000           0.0000000
## 3               0                    0         0.0000000           0.0000000
## 4               0                    0         0.3333333           0.3333333
## 5               0                    0         0.3333333           0.3333333
## 6               0                    0         0.0000000           0.0000000
##   Hyphoderma.cremeoalbum Hyphoderma.litschaueri Hyphoderma.roseocremeum
## 1              0.0000000              0.0000000               0.0000000
## 2              0.0000000              0.0000000               0.0000000
## 3              0.0000000              0.0000000               0.0000000
## 4              0.3333333              0.3333333               0.3333333
## 5              0.3333333              0.3333333               0.3333333
## 6              0.0000000              0.0000000               0.0000000
##   Hyphoderma.transiens Hyphodermella.rosae Hyphodontia.sambuci
## 1            0.0000000           0.0000000                   0
## 2            0.0000000           0.0000000                   0
## 3            0.0000000           0.0000000                   0
## 4            0.3333333           0.6666667                   0
## 5            0.3333333           0.3333333                   0
## 6            0.0000000           0.0000000                   0
##   Hypoxylon.fragiforme Hypoxylon.rubiginosum Junghuhnia.nitida
## 1                    0                     0         0.0000000
## 2                    0                     0         0.0000000
## 3                    0                     0         0.0000000
## 4                    0                     0         0.3333333
## 5                    0                     0         0.3333333
## 6                    0                     0         0.0000000
##   Kretzschmaria.deusta Marasmius.alliaceus Melogramma.spiniferum Mycoacia.uda
## 1                    0                   0                     0    0.0000000
## 2                    0                   0                     0    0.0000000
## 3                    0                   0                     0    0.0000000
## 4                    0                   0                     0    0.3333333
## 5                    0                   0                     0    0.3333333
## 6                    0                   0                     0    0.0000000
##   Peniophora.cinerea Phanerochaete.laevis Phanerochaete.sordida
## 1          0.3333333            0.0000000             0.0000000
## 2          0.0000000            0.0000000             0.0000000
## 3          0.0000000            0.0000000             0.0000000
## 4          0.0000000            0.6666667             0.6666667
## 5          0.0000000            0.3333333             0.3333333
## 6          0.0000000            0.0000000             0.0000000
##   Postia.subcaesia Rigidoporus.sanguinolentus Schizopora.flavipora
## 1        0.0000000                  0.0000000                    0
## 2        0.0000000                  0.0000000                    0
## 3        0.0000000                  0.0000000                    0
## 4        0.3333333                  0.3333333                    0
## 5        0.3333333                  0.3333333                    0
## 6        0.0000000                  0.0000000                    0
##   Scopuloides.rimosa Sidera.lenis Sistotrema.brinkmannii Skeletocutis.nivea
## 1          0.0000000            0                      0          0.0000000
## 2          0.0000000            0                      0          0.0000000
## 3          0.0000000            0                      0          0.0000000
## 4          0.3333333            0                      0          0.3333333
## 5          0.3333333            0                      0          0.3333333
## 6          0.0000000            0                      0          0.0000000
##   Stereum.ochraceoflavum Tapesia.fusca Tomentella.botryoides
## 1              0.6666667     0.0000000                     0
## 2              0.0000000     0.0000000                     0
## 3              0.0000000     0.6666667                     0
## 4              0.0000000     0.0000000                     0
## 5              0.0000000     0.0000000                     0
## 6              0.0000000     0.0000000                     0
##   Trametes.versicolor Trichaptum.biforme Tulasnella.violea Xylaria.hypoxylon
## 1           0.0000000          0.0000000                 0                 0
## 2           0.0000000          0.0000000                 0                 0
## 3           0.0000000          0.0000000                 0                 0
## 4           0.3333333          0.3333333                 0                 0
## 5           0.3333333          0.3333333                 0                 0
## 6           0.0000000          0.0000000                 0                 0
```

```r
head(Tr)
```

```
##                     species spore_volume ornamented_spores thick_spores
## 1 Aleurodiscus.wakefieldiae   6936.00000                 1            1
## 2       Athelopsis.glaucina     48.09375                 0            0
## 3        Bisporella.citrina    108.90000                 0            0
## 4      Ceriporia.reticulata     66.17188                 0            0
## 5   Crustomyces.subabruptus     20.25000                 0            0
## 6      Dacrymyces.stillatus    468.87500                 0            0
##   cystidia_or_paraphyses
## 1                      1
## 2                      1
## 3                      1
## 4                      1
## 5                      1
## 6                      1
```


# **Production of the statistical analysis**

## *Transformation and assembly of the boxes that will be introduced into the model*

### Environmental features

Here we select the environmental variables, present in the main database, which will be integrated into the analysis. Then we transform them and create an "X box" containing its transformed variables. Finally, we create an XFormula object giving the equation that will be used, here we create additive effects but it is possible to create for example interactions between the environmental variables in the XFormula object.



```r
cov = data[,c(3,4,5,6)]

cov$logDist = log(cov$distance_to_edge)
cov$logdiam = log(cov$diam)
cov$decay2 = cov$decay^2


X = as.data.frame(cov[,c("managed","logDist","logdiam","decay","decay2" )])
XFormula = ~managed + logDist + logdiam+ decay + decay2
```


### Species occurrence box

This box contains the occurrences of the species included in the analysis. This corresponds to columns 7 to 46 of the database.


```r
Y = as.matrix(data[,7:46]) 
```

### Study design

This box contains the variables representing the structure of the analysis, such as the year or sampling site.


```r
# Variable selection 
studyDesign = data[,c("site","plot")]
studyDesign = data.frame(apply(studyDesign,2,as.factor))

# Variable structuring 
site = HmscRandomLevel(units = studyDesign$site)
plot = HmscRandomLevel(units = studyDesign$plot)
ranlevels = list(site = site, plot = plot) 
ranlevels
```

```
## $site
## Hmsc random level object with 6216 units. Spatial dimensionality is 0 and number of covariates is 0.
## 
## $plot
## Hmsc random level object with 6216 units. Spatial dimensionality is 0 and number of covariates is 0.
```

### Phylogenetic matrix

Transformation of the phylogenetic database into a matrix.

```r
## Matrice contenant la phylogénie

C = as.matrix(phylo)
```


### Traits matrix

Transformation of the traits database into a matrix and creation of a TrFormula object of the same type as XFormula seen earlier.


```r
colnames(Tr)
```

```
## [1] "species"                "spore_volume"           "ornamented_spores"     
## [4] "thick_spores"           "cystidia_or_paraphyses"
```

```r
Tr = as.data.frame(Tr[,-1])

TrFormula = ~spore_volume + 
  ornamented_spores +
  thick_spores +
  cystidia_or_paraphyses
```

## *Creating and running the model*

In this part we will create the model in itself from the different boxes previously created.Here we will see the model containing the environmental, phylogenetic and specific features data. However, it is possible not to integrate the phylogenetic matrix or the specific traits, by not specifying their boxes. 

### Creating the model

This part consists in assembling the previously produced boxes containing the data and the structure of the model (XFormulta TrFormula).


```r
simul <- Hmsc(Y=Y, XData = X,
              XFormula = XFormula,
              TrData = Tr, 
              TrFormula = TrFormula , 
              C = C,
              studyDesign = studyDesign,
              ranLevels  = ranlevels,
              distr = "probit")  
```


### Run the model

Before running the model we specify the thin, the number of samples, the transient and the number of chains
Here for a quick test we specify a small set that does not allow a correct analysis.
We then integrate the specified elements in the sampleMcmc function to create a final Hmsc object containing the model information and the posterior distribution of the different coefficients. Finally, we save this model which will allow us to load it later to work on the posterior distributions, for example to create figures.



```r
thin = 1
samples = 50
nChains = 2
transient = 50

mod_HMSC = sampleMcmc(simul,
                      samples = samples,
                      thin = thin,
                      transient = transient,
                      nChains = nChains, 
                      nParallel = nChains)



save(mod_HMSC,file="mod_HMSC.Rdata")
```


# **Main results and graphs**

In this last part we will see how to use posterior distributions to make graphs to answer ecological questions such as the impact of the environment on the species occurrence for example.
Here we will work on the same model that we have created above, but which has been previously run with a total size of 10,000 and 3 chains, which will allow us to make the graphs and other results without having any problems due to the lack of information that could generate the model above. However this length will not be enough for a good convergence of the chains and therefore in the framework of a scientific publication it will be necessary to run the model for higher values of thin, samples and transient until the convergence of the chains.

## *Loading and verification of the convergence of MCMC chains*

To start we will load the template contained in the files uploaded at the beginning of this document.
Then we are going to perform convergence tests of the MCMC chains. Here we look at the first 5 chains for beta and gamma in order not to overload this document but a visualization of all the channels allows to better account for the convergence.

```r
## Load the model
load("mod_HMSC10k.Rdata")


## Convergence tests

mcoda <- convertToCodaObject(mod_HMSC)
par(mar = rep(2, 4))

#Visual chain tests for different coefficients of interest 

plot(mcoda$Beta[,1:5])
```

![](/assets/Numerilab_HMSC_files/figure-html/load and convergence tests-1.png)<!-- -->![](/assets/Numerilab_HMSC_files/figure-html/load and convergence tests-2.png)<!-- -->

```r
plot(mcoda$Rho)
```

![](/assets/Numerilab_HMSC_files/figure-html/load and convergence tests-3.png)<!-- -->

```r
plot(mcoda$Gamma[,1:5])
```

![](/assets/Numerilab_HMSC_files/figure-html/load and convergence tests-4.png)<!-- -->![](/assets/Numerilab_HMSC_files/figure-html/load and convergence tests-5.png)<!-- -->

```r
# Gelman's diagnosis, which should be at most close to 1.0 for good convergence.
gelman.diag(mcoda$Beta[,1:50])
```

```
## Potential scale reduction factors:
## 
##                                                     Point est. Upper C.I.
## B[(Intercept) (C1), Aleurodiscus.wakefieldiae (S1)]     231.46    1266.34
## B[managed (C2), Aleurodiscus.wakefieldiae (S1)]         193.48     492.45
## B[logDist (C3), Aleurodiscus.wakefieldiae (S1)]          78.67     289.26
## B[logdiam (C4), Aleurodiscus.wakefieldiae (S1)]           4.95      24.01
## B[decay (C5), Aleurodiscus.wakefieldiae (S1)]           618.34    2763.83
## B[decay2 (C6), Aleurodiscus.wakefieldiae (S1)]          654.05    2960.84
## B[(Intercept) (C1), Athelopsis.glaucina (S2)]            24.46      82.86
## B[managed (C2), Athelopsis.glaucina (S2)]                 1.38       3.72
## B[logDist (C3), Athelopsis.glaucina (S2)]                 1.56       3.12
## B[logdiam (C4), Athelopsis.glaucina (S2)]                 1.54       2.40
## B[decay (C5), Athelopsis.glaucina (S2)]                   1.40       2.05
## B[decay2 (C6), Athelopsis.glaucina (S2)]                  1.35       1.93
## B[(Intercept) (C1), Bisporella.citrina (S3)]             13.45      71.44
## B[managed (C2), Bisporella.citrina (S3)]                  4.45      25.71
## B[logDist (C3), Bisporella.citrina (S3)]                  3.47       6.69
## B[logdiam (C4), Bisporella.citrina (S3)]                  3.10       5.73
## B[decay (C5), Bisporella.citrina (S3)]                    1.04       1.13
## B[decay2 (C6), Bisporella.citrina (S3)]                   1.04       1.13
## B[(Intercept) (C1), Ceriporia.reticulata (S4)]            5.78      34.56
## B[managed (C2), Ceriporia.reticulata (S4)]                2.02      10.05
## B[logDist (C3), Ceriporia.reticulata (S4)]                1.24       1.73
## B[logdiam (C4), Ceriporia.reticulata (S4)]                1.14       1.42
## B[decay (C5), Ceriporia.reticulata (S4)]                  1.01       1.03
## B[decay2 (C6), Ceriporia.reticulata (S4)]                 1.01       1.04
## B[(Intercept) (C1), Crustomyces.subabruptus (S5)]        38.14     160.71
## B[managed (C2), Crustomyces.subabruptus (S5)]            13.06      77.52
## B[logDist (C3), Crustomyces.subabruptus (S5)]             3.42       7.49
## B[logdiam (C4), Crustomyces.subabruptus (S5)]             2.43       5.55
## B[decay (C5), Crustomyces.subabruptus (S5)]               3.05      11.62
## B[decay2 (C6), Crustomyces.subabruptus (S5)]              2.97      10.97
## B[(Intercept) (C1), Dacrymyces.stillatus (S6)]           25.73      67.60
## B[managed (C2), Dacrymyces.stillatus (S6)]               87.59     330.53
## B[logDist (C3), Dacrymyces.stillatus (S6)]               10.84      26.50
## B[logdiam (C4), Dacrymyces.stillatus (S6)]                3.95      20.69
## B[decay (C5), Dacrymyces.stillatus (S6)]                  2.24      10.88
## B[decay2 (C6), Dacrymyces.stillatus (S6)]                 2.26      11.32
## B[(Intercept) (C1), Diatrype.stigma (S7)]                 6.15      17.00
## B[managed (C2), Diatrype.stigma (S7)]                    10.42      64.20
## B[logDist (C3), Diatrype.stigma (S7)]                     1.11       1.36
## B[logdiam (C4), Diatrype.stigma (S7)]                     1.12       1.37
## B[decay (C5), Diatrype.stigma (S7)]                       5.14      29.76
## B[decay2 (C6), Diatrype.stigma (S7)]                      5.15      29.94
## B[(Intercept) (C1), Eutypella.quaternata (S8)]          192.53     526.55
## B[managed (C2), Eutypella.quaternata (S8)]               28.34     164.96
## B[logDist (C3), Eutypella.quaternata (S8)]                4.31      24.96
## B[logdiam (C4), Eutypella.quaternata (S8)]                2.40       4.22
## B[decay (C5), Eutypella.quaternata (S8)]                511.74    1035.02
## B[decay2 (C6), Eutypella.quaternata (S8)]               556.69    1135.55
## B[(Intercept) (C1), Fomes.fomentarius (S9)]              14.73      42.16
## B[managed (C2), Fomes.fomentarius (S9)]                  18.95      72.95
## 
## Multivariate psrf
## 
## 17595
```


## *Beta*

One of the questions that is asked when using a JSDM is how the environment influences the species being studied. This influence is quantified by Beta coefficients that can be viewed using the *getPostEstimate* and *plotBeta* functions. Moreover, in the plotBeta function, we can visualize either the means of the posterior distribution of the Beta coefficient or a support level (by default).


```r
postBeta = getPostEstimate(mod_HMSC, parName = "Beta")

par(mar=c(5,11,2.5,0))

plotBeta(mod_HMSC,
         post = postBeta, 
         plotTree = F,
         spNamesNumbers = c(T,F))
```

![](/assets/Numerilab_HMSC_files/figure-html/Beta-1.png)<!-- -->

```r
plotBeta(mod_HMSC, 
         post = postBeta,
         param = "Mean",
         plotTree = F,  
         spNamesNumbers = c(T,F))
```

![](/assets/Numerilab_HMSC_files/figure-html/Beta-2.png)<!-- -->


## *Gamma*

The other questions asked when using a JSDM is how the species traits influence the species response to the environment. This influence is quantified by Gamma coefficients that we can visualize using the *getPostEstimate* and *plotGamma* functions. Moreover as the plotBeta, we can visualize either the means of the posterior distribution of the coefficient Beta or a support level (by default).



```r
par(mar=c(5,11,2.5,0))

postGamma = getPostEstimate(mod_HMSC, parName = "Gamma")


plotGamma(mod_HMSC, post = postGamma)
```

```
## Warning in plotGamma(mod_HMSC, post = postGamma): Nothing to plot at this level
## of posterior support
```

![](/assets/Numerilab_HMSC_files/figure-html/gamma-1.png)<!-- -->

As you can see on the warning message, the support level here does not show any correlation between the response to the environment and the different features. This may be due to the problem of model convergence. To "force" the thing we will decrease the support level. 


```r
par(mar=c(5,11,2.5,0))

postGamma = getPostEstimate(mod_HMSC, parName = "Gamma")


plotGamma(mod_HMSC, post = postGamma, supportLevel = 0.2)
```

![](/assets/Numerilab_HMSC_files/figure-html/gamma SL-1.png)<!-- -->

## *Variance partitionning*

Another interesting thing we can look at from the posterior distributions is how much each environmental and study design variable influences the species of interest. This can be looked at using the Variance Partitioning functions.


```r
VP = computeVariancePartitioning(mod_HMSC)

par(mar=c(4,4,4,4))

plotVariancePartitioning(mod_HMSC, VP = VP,
                         las = 2, horiz=F)
```

![](/assets/Numerilab_HMSC_files/figure-html/VP-1.png)<!-- -->


## *Predictions*

It is interesting to know for example how species are influenced by the environment, as can be seen from the Beta coefficients. However, it is difficult to visualize shape of the influence of a variable, for example. To visualize this we can use a tool present in Hmsc, this tool allows to build an environmental gradient and then see how species are influenced by this gradient. This tool allows to plot predictions according to the gradient, for species richness, a single species or even for a species trait.


```r
Gradient = constructGradient(mod_HMSC,
                             focalVariable = "logdiam")

head(Gradient$XDataNew)
```

```
##      logdiam  managed  logDist     decay     decay2
## 1 -2.3025851 1.308102 3.900249 0.1680480 -2.5181826
## 2 -1.9176788 1.247936 4.017576 0.3298778 -1.8535490
## 3 -1.5327724 1.187771 4.134902 0.4917077 -1.1889154
## 4 -1.1478661 1.127605 4.252228 0.6535376 -0.5242818
## 5 -0.7629597 1.067440 4.369554 0.8153675  0.1403518
## 6 -0.3780534 1.007274 4.486880 0.9771974  0.8049854
```

```r
predY = predict(mod_HMSC,
                XData = Gradient$XDataNew, 
                studyDesign = Gradient$studyDesignNew,
                ranLevels = Gradient$rLNew,
                expected = TRUE)

### Species richness

plotGradient(mod_HMSC,
             Gradient,
             pred=predY,
             measure="S",
             showData = TRUE)
```

![](/assets/Numerilab_HMSC_files/figure-html/Predictions-1.png)<!-- -->

```
## [1] 0.4166667
```

```r
### Single species (ex: species 35)

plotGradient(mod_HMSC,
             Gradient,
             pred=predY,
             measure="Y",
             index = 35,
             showData = TRUE)
```

![](/assets/Numerilab_HMSC_files/figure-html/Predictions-2.png)<!-- -->

```
## [1] 0.1666667
```

```r
### Species traits


plotGradient(mod_HMSC, 
             Gradient,
             pred=predY,
             measure="T",
             index = 2,
             showData = TRUE)
```

![](/assets/Numerilab_HMSC_files/figure-html/Predictions-3.png)<!-- -->

```
## [1] 0.4326667
```


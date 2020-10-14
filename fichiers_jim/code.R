########################################################
#### Script of the Data table manipulation workshop ####
########################################################

# Jim FELIX-FAURE
# 22/10/2020


# Change table format

## From wide format to longer format

#
library(tidyverse)
Tbl_Weight <- tibble(
  Observation = c("A", "B"),
  "2010" = c(3, 3),
  "2011" = c(5, 2),
  "2012" = c(4, 3),
  "2013" = c(5, 3)
)
Tbl_Weight
#

#
Tbl_WeightTidy <- Tbl_Weight %>% 
  pivot_longer(
    cols = !Observation, 
    names_to = "Year", 
    names_transform = list(Year = as.integer), 
    values_to = "Weight"
  ) 
Tbl_WeightTidy
#

#
Tbl_WeightTidy %>%
  group_by(Observation) %>%
  summarise(Mean = mean(Weight),
            Sd = sd(Weight),
            n = n())
#

#
Tbl_WeightTidy %>%
  ggplot() +
  geom_line(aes(x = Year, y = Weight, color = Observation))
#


## From large format to wider format

#
Tbl_Water <- tibble(
  Observation = rep(c("A", "B", "C", "D"), each = 2),
  Measure = rep(c("pH", "O2"), 4),
  Value = c(6, 99, 7, 90, 7.2, 85, 6.5, 96)
)
Tbl_Water
#

#
Tbl_WaterTidy <- Tbl_Water %>% 
  pivot_wider(names_from = Measure, 
              values_from = Value 
  )
Tbl_WaterTidy
#


#
Tbl_WaterTidy %>%
  ggplot(aes(x = pH, y = O2)) +
  geom_point()
#


# Split two values from one cell

#
Tbl_Effect <- tibble(
  Molecule = c("A","B","C"),
  Result = c("87/112","23/48","34/89")
)
Tbl_Effect
#

#
Tbl_Effect %>% 
  separate(
    col = Result, # which column to separate
    into = c("Positive_animals", "Tested_animals"), # how to call the new columns
    convert = TRUE, # convert the new columns to the appropriate type
    remove = TRUE # remove the former column
  ) %>% 
  mutate(Ratio = Positive_animals/Tested_animals)
#




# Data set connection

## The joins

#
Tbl_Site <- tibble(
  Site = c("356a", "da4b", "77de", "1b64"),
  Landuse = c("Forest", "Forest", "Pasture", "Wetland"),
  Area = c(12, 30, 8, 17)
)
Tbl_Site
#

#
Tbl_Result <- tibble(
  Site = c("1b64", "1b64", "356a", "da4b", "da4b", "abcd"),
  Measure = c("pH", "pH", "Corg", "pH", "Corg", "Corg"),
  Value = c(7, 7.2, 3.5, 5.8, 2.7, 5.8)
)
Tbl_Result
#



### Full joins
#
full_join(Tbl_Site, Tbl_Result, by = "Site")
#



### *Left* joins
#
left_join(Tbl_Site, Tbl_Result, by = "Site")
#



### *Right* joins
#
right_join(Tbl_Site, Tbl_Result, by = "Site")
#



### Filtering joins
#
semi_join(Tbl_Site, Tbl_Result, by = "Site")
#

#
anti_join(Tbl_Site, Tbl_Result, by = "Site")
#





## Bind data table

#
Tbl_Site1970 <- tibble(
  Site = c("356a", "da4b", "77de", "1b64"),
  Landuse = c("Crop", "Pasture", "Pasture", "Wetland")
)
Tbl_Site2020 <- tibble(
  Site = c("356a", "da4b", "77de", "1b64"),
  Landuse = c("Forest", "Forest", "Pasture", "Crop"),
  Area = c(12, 30, 8, 17)
)
Tbl_Site1970
Tbl_Site2020
#


### By columns
#
bind_cols(Tbl_Site1970, Tbl_Site2020)
#

#
bind_cols(Tbl_Site1970, select(Tbl_Site2020, Area))
#


### By rows
#
bind_rows(Tbl_Site1970, Tbl_Site2020)
#

#
bind_rows("1970" = Tbl_Site1970, "2020" = Tbl_Site2020, .id = "Year")
#





# Manipulation of *NA*


## Convert values to *NA*.

#
Tbl_Temperature <- tibble(Site = c("A", "A", "A", "B", "B", "B"),
                          Month = c("January", "NoData", "September", "January", "June", "September"), 
                          Temp = c(-12, 16, 13, 9999, 19, 15 ))
Tbl_Temperature
#

#
Tbl_TempNA <- Tbl_Temperature %>% 
  mutate(Month = na_if(Month, "NoData")) %>% 
  mutate(Temp = na_if(Temp, 9999))
Tbl_TempNA
#


## Replace *NA*

#
Tbl_TempNA
#

#
Tbl_TempNA %>% 
  mutate(Month = replace_na(Month, "June")) %>% 
  mutate(Temp = replace_na(Temp, -17))
#

#
Tbl_TempNA %>%
  replace_na(list(Month = "June", Temp = -17))
#





# Working with categorical data



## Towards factorial variables

#
Vector_Character <- c("Apple", "Apple", "Pear", "Apricot", "Pear")
Vector_Character
levels(Vector_Character)
#

#
Vector_Factor <- factor(Vector_Character)
Vector_Factor
levels(Vector_Factor)
#


## Changing the order of factor levels

#
msleep %>%
  top_n(20) %>% # Only the first 20 rows
  ggplot() +
  geom_point(aes(x = sleep_total,
                 y = name))
#


### According to another variable
#
msleep %>%
  top_n(20) %>% # Only the first 20 rows
  ggplot() +
  geom_point(aes(x = sleep_total,
                 y = fct_reorder(name, # variable to sort
                                 sleep_total, # variable on which to sort
                                 .desc = TRUE) # sort in descending order
  ))
#

### Manually
#
msleep %>%
  top_n(20) %>% # Only the first 20 lines
  mutate(name = fct_relevel(name, # variable to sort
                            "Horse", "Cow")) %>% # "levels" to place first ("1", "2", ...))
  ggplot() +
  geom_point(aes(x = sleep_total,
                 y = name))
#



## Changing Factor Levels

#
msleep_recode <- msleep %>% 
  select(name:vore) %>%  # facilitates visualization of the tibble
  mutate(
    vore = factor(vore), # change the type of variable -> from "character" to "factor".
    vore_recode = fct_recode(vore, # Modifies the levels of the variable
                             "Carnivore" = "carni",
                             "Herbivore" = "herbi",
                             "Autre" = "omni",
                             "Autre" = "insecti"
    )
  )
#

#
levels(msleep_recode$vore)
levels(msleep_recode$vore_recode)
msleep_recode
#





# Practice



## Table formatting

#
Tbl_Weather <- tribble(
  ~State, ~Temp, ~Rain,
  "Quebec", 15, 300,
  "Ontario", 17, 280,
  "Manitoba", 12, 360
)
#

#
Tbl_Obs <- tribble(
  ~State, ~Spring, ~Fall,
  "Quebec", "22/30", "10/12",
  "Ontario", "18/50", "3/4"
)
#



## Categorical variable

# ...

































#### Correction

# Practice
## Table formatting

#
Tbl_ObsTidy <- Tbl_Obs %>% 
  pivot_longer(
    cols = !State, # Columns to be used
    names_to = "Season", # Variable where the column names will be stored
    values_to = "Obs" # Variable where the values will be stored
  ) %>% 
  separate(
    col = Obs, # which column to separate
    into = c("Obs_posi", "Obs_total"), # how to name the new columns
    convert = TRUE, # convert the new columns to the appropriate type
    remove = TRUE # remove the old column
  ) %>% 
  mutate(Obs_nega = Obs_total - Obs_posi)

Tbl_Final <- Tbl_Weather %>% 
  right_join(Tbl_ObsTidy, by = "State") %>% 
  select(-Obs_total)

Tbl_Final
#


## Categorical variable

#
msleep %>%
  mutate(
    vore_new = fct_recode(
      vore,
      "Carnivore" = "carni",
      "Herbivore" = "herbi",
      "Omnivore" = "omni",
      "Carnivore" = "insecti"
    ),
    vore_new = fct_relevel(vore_new, 
                           "Herbivore", "Omnivore", "Carnivore")
  ) %>% 
  ggplot() + 
  geom_boxplot(aes(x = vore_new, 
                   y = sleep_total))
#

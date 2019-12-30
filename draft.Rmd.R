apes <- c("Pongo", "Pan", "Gorilla", "Hoolock", "Homo")
resolved_names <- rotl::tnrs_match_names(apes)


In R, phylogenetic trees are stored as a list of at least 4 elements.

```{r, eval = TRUE}
str(amphibia_subtree)
```

# Extract _ott ids_ from tip labels of a subtree or induced subtree

By default, the tip labels of an induced subtree contain both the taxon name and the ott id. 
```{r, eval = TRUE}
head(subtree$tip.label)
tail(subtree$tip.label)
```

Splitting by the pattern "_ott" should help us get the _ott ids_ from the tip labels of the subtree.

```{r, eval = TRUE}
my_ott_ids <- sapply(strsplit(subtree$tip.label, "_ott"), "[", 2)
head(my_ott_ids)
```

However, it can get us in trouble when one of the tip labels is something like "`r subtree$tip.label[which(is.na(as.numeric(my_ott_ids)))]`", that contains the "_ott" pattern somewhere we did not expect it.

Try to get an induced subtree using this vector of _ott ids_. What do you think will happen?
```{r, eval = TRUE, error = TRUE}
rotl::tol_induced_subtree(my_ott_ids)
```

The function needs a numeric vector, not a character vector. You can verify the type of a vector with `class(my_ott_ids)` or `type(my_ott_ids)`.
If we are sure that our character vector is composed of only numeric characters, we can force a character vector into a numeric one using the function `as.numeric()`.

Now, try it again.

```{r, eval = TRUE, error = TRUE}
rotl::tol_induced_subtree(as.numeric(my_ott_ids))
```
This error means that one or more elements in our vector of _ott ids_ contains alphanumeric characters.
Sure enough, forcing a character vector to numeric when there are not numeric elements in the vector introduces NAs into the new vector.
Verify if there are one or more NAs in your vector of _ott ids_ with the function `anyNA()`.

```{r, eval = TRUE, error = TRUE}
anyNA(as.numeric(my_ott_ids))
```

Find out the culprit in this case.
```{r, eval = TRUE, error = TRUE}
my_ott_ids[which(is.na(as.numeric(my_ott_ids)))]
```

Originally:
```{r, eval = TRUE, error = TRUE}
subtree$tip.label[which(is.na(as.numeric(my_ott_ids)))]
```

The `stringr` package provides another way to get the _ott ids_ from the tip labels.
```{r, eval = TRUE}
my_ott_ids <- stringr::str_extract(subtree$tip.label, "_ott\\d+")
head(my_ott_ids)
my_ott_ids <- gsub("_ott", "", my_ott_ids)
my_ott_ids <- as.numeric(my_ott_ids)
anyNA(my_ott_ids)
```

It seems that our _ott ids_ are good. Try to get an induced subtree for those.

```{r, eval = TRUE, results = 'hide', warning = FALSE}
subtree <- rotl::tol_induced_subtree(my_ott_ids) # yay!
```





# Explore the lineage (higher taxa) of a taxon

```{r, eval = TRUE, warning= FALSE, error = TRUE}
canis_node_info <- rotl::tol_node_info(canis$ott_id, include_lineage = TRUE)
canis_lineage <- rotl::tol_lineage(xx)  
```

Sometimes, the ott taxonomy "breaks" taxa that are well known as monophyletic, i.e., flags them as non monophyletic. 

# Get a subtree of a rank

In datelife, we have a function that gets all "unflagged" children from a given rank. By default, we get all species.
```{r, eval = TRUE, results= 'hide', warning= FALSE, error = TRUE}
canis_species <- datelife::get_ott_children(ott_ids = canis$ott_id)
```
```{r, eval = TRUE}
canis_species
```

Get an induced subtree of these _ott ids_.
```{r, eval = TRUE, results= 'hide', warning= FALSE, error = TRUE}
canis_species_subtree <- rotl::tol_induced_subtree(canis_species$Canis$ott_id)
```
```{r, eval = TRUE}
canis_species_subtree
```
```{r, eval = TRUE, results= 'asis', warning= FALSE, error = TRUE, fig.height = 4}
ape::plot.phylo(canis_species_subtree, cex = 1)
```

Try to get all families of Amphibia.

```{r, eval = TRUE, results= 'hide', warning= FALSE, error = TRUE}
amphibia_ott_ids_families <- datelife::get_ott_children(ott_ids = amphibia_ott_ids, ott_rank = "family")
```
```{r, eval = TRUE}
amphibia_ott_ids_families
```

Get the subtree.
```{r, eval = TRUE, results= 'hide', warning= FALSE, error = TRUE}
amphibia_families_subtree <- rotl::tol_induced_subtree(amphibia_ott_ids_families$Amphibia$ott_id)
```
```{r, eval = TRUE, results= 'asis', warning= FALSE, error = TRUE, fig.height = 8}
ape::plot.phylo(amphibia_families_subtree, cex = 0.5)
amphibia_families_subtree
```
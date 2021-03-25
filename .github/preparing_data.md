Preparing Data
================
Erik Christensen
24/03/2021

## Preparing Datasets For Upload

This is document is a brief example on how data can be prepared for
upload to TMExplorer. I’ll use GSE75688 since it has additional columns
in the matrix and a separate cell-type info file.

First let’s look at the dataset in TMExplorer.

``` r
gse75688 <- queryTME(geo_accession = 'GSE75688')[[1]]
dim(counts(gse75688))
```

    ## [1] 57915   563

``` r
counts(gse75688)[1:5,1:4]
```

    ##                             BC01_Pooled BC01_Tumor BC02_Pooled BC03_Pooled
    ## TSPAN6_ENSG00000000003.10          2.33       1.25       43.96        7.64
    ## TNMD_ENSG00000000005.5             0.00       0.00        0.00        0.00
    ## DPM1_ENSG00000000419.8            60.70      28.44       74.73       41.41
    ## SCYL3_ENSG00000000457.9           47.93       4.43        9.89        7.61
    ## C1orf112_ENSG00000000460.12        4.79       1.67       10.87        0.92

The counts file is a 57915x563 matrix with a single column of rownames.
This is the target format. Let’s compare that to the dataset downloaded
from GEO.

``` r
geo <- read.csv('GSE75688_GEO_processed_Breast_Cancer_raw_TPM_matrix.txt.gz',
                sep='\t')
dim(geo)
```

    ## [1] 57915   566

``` r
geo[1:5,1:4]
```

    ##              gene_id gene_name      gene_type BC01_Pooled
    ## 1 ENSG00000000003.10    TSPAN6 protein_coding        2.33
    ## 2  ENSG00000000005.5      TNMD protein_coding        0.00
    ## 3  ENSG00000000419.8      DPM1 protein_coding       60.70
    ## 4  ENSG00000000457.9     SCYL3 protein_coding       47.93
    ## 5 ENSG00000000460.12  C1orf112 protein_coding        4.79

The GEO matrix has three additional columns. In order to match the
target format, we’ll drop the `gene_type` column, merge the `gene_id`
and `gene_name` columns, then set the merged result as the rownames.
NOTE: The rownames here can be gene names, gene IDs, some combination of
the two like we have here, but they must be unique (R cannot set
non-unique rownames) and identify the gene (instead of just being
numbers).

``` r
geo$gene_type <- NULL
geo$gene_id <- paste(geo$gene_name, geo$gene_id,sep='_')
rownames(geo) <- geo$gene_id
geo$gene_id <- NULL
geo$gene_name <- NULL

dim(geo)
```

    ## [1] 57915   563

``` r
geo[1:5,1:4]
```

    ##                             BC01_Pooled BC01_Tumor BC02_Pooled BC03_Pooled
    ## TSPAN6_ENSG00000000003.10          2.33       1.25       43.96        7.64
    ## TNMD_ENSG00000000005.5             0.00       0.00        0.00        0.00
    ## DPM1_ENSG00000000419.8            60.70      28.44       74.73       41.41
    ## SCYL3_ENSG00000000457.9           47.93       4.43        9.89        7.61
    ## C1orf112_ENSG00000000460.12        4.79       1.67       10.87        0.92

``` r
all(geo == counts(gse75688))
```

    ## [1] TRUE

After modification, the dimensions are the same and all values in the
matrix match the file in TMExplorer. If this was a new dataset, the
modified `geo` object would be what you submit as the genes x cells
matrix.

This dataset also has cell type information available. In order to
prepare that for TMExplorer we’ll need to load in the file and remove
the extra columns.

``` r
geo_cellinfo <- read.csv('GSE75688_final_sample_information.txt',sep='\t')
head(geo_cellinfo)
```

    ##    sample type index index2 index3
    ## 1 BC01_02   SC Tumor  Tumor  Tumor
    ## 2 BC01_03   SC Tumor  Tumor  Tumor
    ## 3 BC01_04   SC Tumor  Tumor  Tumor
    ## 4 BC01_05   SC Tumor  Tumor  Tumor
    ## 5 BC01_06   SC Tumor  Tumor  Tumor
    ## 6 BC01_08   SC Tumor  Tumor  Tumor

``` r
geo_cellinfo$type <- NULL
geo_cellinfo$index <- NULL
geo_cellinfo$index2 <- NULL
names(geo_cellinfo)[2] <- "label"
dim(geo_cellinfo)
```

    ## [1] 528   2

``` r
head(geo_cellinfo)
```

    ##    sample label
    ## 1 BC01_02 Tumor
    ## 2 BC01_03 Tumor
    ## 3 BC01_04 Tumor
    ## 4 BC01_05 Tumor
    ## 5 BC01_06 Tumor
    ## 6 BC01_08 Tumor

This file contains the cell type for each cell in the original dataset,
as shown below.

``` r
table(geo_cellinfo$label)
```

    ## 
    ##   Bcell  Immune Myeloid Stromal   Tcell   Tumor 
    ##      83       4      38      23      54     326

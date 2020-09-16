library(here)

meta <- data.frame(
    Title = ,
    Description = paste( #TODO write description
        'For more information, check the TMExplorer package.'
    ),
    BiocVersion = "3.11", #TODO ensure 3.11 is the dev cycle
    Genome = , #TODO check acceptable genome values and see if I can use any
    SourceType = , #TODO Check valid source types
    SourceUrl = , #TODO these should be GEO urls for the most part
    SourceVersion = , #TODO all data is from different sources, rip
    Species = "Homo sapiens",
    TaxonomyId = , #TODO might not need this
    Coordinate_1_based = TRUE,
    DataProvider = "", #TODO either the original authors or GEO
    Maintainer = "Erik Christensen <echris3@uwo.ca>",
    RDataClass = 'matrix', #TODO make sure this is accurate for all data
    DispatchClass = 'Rds',
    RDataPath = file.path(pkgname, outdir, c()), #TODO
    Tags = as.character(), #TODO
    row.names = NULL,
    stringsAsFactors = FALSE
   )

write.csv(meta, 
    file = here:here('inst', 'extdata', 'metadata.csv'),)
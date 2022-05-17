#' @importFrom BiocFileCache BiocFileCache bfcadd
downloadTME <- function(df, row, column, bfc){
    if (is.na(df[row,column])){
        return(NULL)
    } else {
        filename <- bfcadd(bfc, "TestWeb", fpath=toString(df[row,column]))
        return(readRDS(filename))
    }
    
}

fetchTME <- function(df, row, sparse){
    #download the data into dataframes
    cache_path <- tempfile()
    bfc <- BiocFileCache(cache_path, ask = FALSE)
    if (sparse == FALSE){
        expression <- downloadTME(df, row, 'expression_link', bfc)
    } else if (sparse == TRUE){
        expression <- downloadTME(df, row, 'sparse_expression_link', bfc)
    }
    labels <- downloadTME(df, row, 'truth_label_link', bfc)
    if (!is.null(labels) && length(labels$cell)!=length(colnames(expression))){
        col.num <- which(colnames(expression) %in% labels$cell)
        expression <- expression[,col.num]
    }
    sigs <- downloadTME(df, row, 'signature_link', bfc)

    tme_data_meta <- list(signatures = sigs,
                        pmid = df[row, 'PMID'],
                        technology = df[row, 'Technology'],
                        score_type = df[row, 'score_type'],
                        organism  = df[row, 'Organism'],
                        author = df[row, 'author'],
                        tumour_type = df[row, 'tumor_type'],
                        patients = df[row, 'patients'],
                        tumours  = df[row, 'tumours'],
                        cells = colnames(expression),
                        #TODO maybe figure out how to make this a dataframe with
                        #the first few columns if a dataset has multiple
                        #identifiers for each gene
                        genes = row.names(expression),
                        geo_accession = df[row, 'accession'],
                        summary = df[row,'summary']
                        )
    if (is.null(labels)){
        tme_dataset <- SingleCellExperiment(list(counts = expression),
                                            metadata = tme_data_meta)
    }else{
        tme_dataset <- SingleCellExperiment(list(counts = expression),
                                    colData = data.frame(label=labels$truth),
                                    metadata = tme_data_meta)
    }


    return(tme_dataset)

}

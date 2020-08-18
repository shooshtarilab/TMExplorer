downloadTME <- function(df, row, column){
    if (df[row, column] != ''){
        filename <- tempfile()
        utils::download.file(df[row,column], 
                            destfile=filename, 
                            mode="wb",
                            quiet = TRUE)
        return(readRDS(filename))
    } else {
        return(NULL)
    }

}

fetchTME <- function(df, row, sparse){
    #download the data into dataframes
    if (sparse == FALSE){
        expression <- downloadTME(df, row, 'expression_link')
    } else if (sparse == TRUE){
        expression <- downloadTME(df, row, 'sparse_expression_link')
    }
    labels <- downloadTME(df, row, 'truth_label_link')
    sigs <- downloadTME(df, row, 'signature_link')

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
                        #TODO maybe figure out how to make this a dataframe with the 
                        #first few columns if a dataset has multiple identifiers for
                        #each gene
                        genes = row.names(expression),
                        geo_accession = df[row, 'accession'])
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

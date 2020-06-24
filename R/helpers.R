downloadTME <- function(df, row, column){
    if (df[row, column] != ''){
        filename <- tempfile()
        utils::download.file(df[row,column], 
                            destfile=filename, 
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

    tme_dataset <- list(expression = expression,
                        labels = labels,
                        signatures = sigs,
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
    class(tme_dataset) <- "tme_data"
    return(tme_dataset)

}
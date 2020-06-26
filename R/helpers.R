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

downloadMultipleFormats <- function(df, row, sparse, formats){
    valid_formats <- c('counts', 'tpm', 'fpkm')
    expression <- vector('list', length(formats))
    i <- 1
    for (format in formats){
        #TODO input validation for formats
            # counts should always be first, or the list should be named
        if (tolower(format) %in% valid_formats){
            if (sparse == FALSE){
                expression[[i]] <- downloadTME(df, 
                                            row, 
                                            paste(tolower(format), 
                                                'expression_link', 
                                                sep='_'))
            } else if (sparse == TRUE){
                expression[[i]] <- downloadTME(df, 
                                            row, 
                                            paste('sparse', 
                                                tolower(format), 
                                                'expression_link', 
                                                sep='_'))
            }
            #this test is a nice idea but the item in the list 
            # is removed if NULL is returned by downloadTME
            if (is.null(expression[[i]])){
                print(paste(format, 
                            'unavailable for', 
                            df[row, 'accession'],
                            sep=' '))
            }
        } else {
            print(paste('Invalid format:', 
                        format, 
                        'try one of counts, tpm, fpkm'))
            expression[[i]] <- NULL
        }
        i <- i + 1
    }
    names(expression) <- tolower(formats)
    return(expression)
}

fetchTME <- function(df, row, sparse, download_format){
    #download the data into dataframes
    expression_list <- downloadMultipleFormats(df, row, sparse, download_format)
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
                        #TODO maybe figure out how to make this a 
                        # dataframe with the first few columns if a 
                        # dataset has multiple identifiers for each gene
                        genes = row.names(expression),
                        geo_accession = df[row, 'accession'])
    tme_dataset <- SingleCellExperiment(list(counts = expression_list[[1]]),
                                    colData = data.frame(label=labels$truth),
                                    metadata = tme_data_meta)
    if (length(expression_list)>1){
        expression_list <- expression_list[-1]
        for (i in seq_along(expression_list)){
            #TODO make sure this works
                # maybe find a way to make a list of sce's with vapply
            altExp(tme_dataset, names(expression_list)[[i]]) <- SingleCellExperiment(list(counts=expression_list[[i]]))
        }
    }

    #class(tme_dataset) <- "tme_data"
    return(tme_dataset)

}

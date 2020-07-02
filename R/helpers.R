downloadTME <- function(df, row, column){
    if (df[row, column] != ''){
        filename <- tempfile()
        utils::download.file(df[row,column], 
                            destfile=filename, 
                            quiet = TRUE)
        return(readRDS(filename))
    } else {
        return()
    }

}

downloadMultipleFormats <- function(df, row, sparse, formats){
    formats <- as.list(formats)
    valid_formats <- c('counts', 'tpm', 'fpkm')
    expression <- vector('list', length(formats))
    i <- 1
    for (format in formats){
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
            if (is.null(expression[[i]])){
                print(paste(format, 
                            'unavailable for', 
                            df[row, 'accession'],
                            sep=' '))
                # remove the unavailable format from the lists
                expression[[i]] <- NULL
                formats[[i]] <- NULL
                i <- i-1
                #TODO download other format for dataset if user wants
            }
        } else {
            print(paste('Invalid format:', 
                        format, 
                        'try one of counts, tpm, fpkm'))
            # remove the invalid format from the lists
            expression[[i]] <- NULL
            formats[[i]] <- NULL
            i <- i-1
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
    #see about adding named getters for new formats (named getters and setters man page)
    tme_dataset <- SingleCellExperiment(expression_list[[1]],
                                    colData = data.frame(label=labels$truth),
                                    metadata = tme_data_meta)
    assayNames(tme_dataset) <- names(expression_list)[[1]] 
    if (length(expression_list)>1){
        expression_list <- expression_list[-1]
        for (i in seq_along(expression_list)){
            # maybe find a way to make a list of sce's with vapply
            altExp(tme_dataset, names(expression_list)[[i]]) <- SingleCellExperiment(expression_list[[i]],
                                                                                    colData = data.frame(label=labels$truth),
                                                                                    metadata = tme_data_meta)
            assayNames(altExp(tme_dataset, names(expression_list)[[i]])) <- names(expression_list)[[i]]
        }
    }

    #class(tme_dataset) <- "tme_data"
    return(tme_dataset)

}

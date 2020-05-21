tme_data <- setRefClass("tme_data",
                        fields = list(expression = "data.frame",
                        labels = "data.frame",
                        signatures = "data.frame",
                        pmid = "numeric",
                        technology = "character",
                        score_type = "character",
                        organism = "character",
                        author = "character",
                        tumour_type = "character",
                        patients = "numeric",
                        tumours = "numeric",
                        cells = "numeric",
                        genes = "numeric",
                        geo_accession = "character"))

#' A function to query TME datasets available in this package
#'
#' This function allows you to search and subset included TME datasets
#' @param geo_accession Search by geo accession number
#' @param metadata_only Return rows of metadata instead of actual datasets. Defaults to FALSE
#' @keywords tumour
#' @export
#' @examples
#' queryTME

queryTME <- function(geo_accession=NULL,
                       score_type=NULL,
                       has_signatures=NULL,
                       has_truth=NULL,
                       tumour_type=NULL,
                       metadata_only=FALSE){
    data("tme_meta")
    df = tme_meta
    if (!is.null(geo_accession)) {
        df <- df[df$accession == geo_accession,]
    }
    if (!is.null(score_type)) {
        df <- df[df$score_type == score_type ,]
    }
    if (!is.null(has_signatures)) {
        if (has_signatures) {
            df <- df[df$signatures == 't' ,]
        }else if (!has_signatures) {
            df <- df[df$signatures == 'f' ,]
        }
    }
    if (!is.null(has_truth)) {
        if (has_truth) {
            df <- df[df$cell_labels == 'Y', ]
        }else if (!has_truth) {
            df <- df[df$cell_labels == 'N', ]
        }
    }
    if (!is.null(tumour_type)) {
        df <- df[df$tumour_type == tumour_type,]
    }
    if (metadata_only) {
        return(list(df))
    } else {
        df_list <- list()
        for (row in 1:nrow(df)){
            geo <- df[row, 'accession']
            if (geo == 'GSE72056') {
                data('GSE572056_expression')
                data('GSE572056_labels')
                data('GSE572056_signatures')
                tme_dataset <- tme_data$new(expression = GSE572056_expression,
                                         labels = GSE572056_labels,
                                         signatures= GSE572056_signatures,
                                         pmid = df[row, 'PMID'],
                                         technology = df[row, 'Technology'],
                                         score_type = df[row, 'score_type'], 
                                         organism  = df[row, 'Organism'],
                                         author = df[row, 'author'],
                                         tumour_type = df[row, 'tumor_type'],
                                         patients = df[row, 'patients'],
                                         tumours  = df[row, 'tumours'],
                                         cells = df[row, 'cells'],
                                         genes = df[row, 'genes'],
                                         geo_accession = geo)
 
            } else {
                expression <- paste('../data/',geo, '_expression.rda', sep='')
                labels <- paste('../data/',geo, 'labels', sep='')
                sigs <- paste('../data/',geo, 'signatures', sep='')
                #data(expression)
                #data(labels)
                #data(sigs)

                #TODO how to load the actual data from the data directory??
                tme_dataset <- tme_data$new(expression = data.frame(),
                                            labels = data.frame(),
                                            signatures= data.frame(),
                                            pmid = df[row, 'PMID'],
                                            technology = df[row, 'Technology'],
                                            score_type = df[row, 'score_type'], 
                                            organism  = df[row, 'Organism'],
                                            author = df[row, 'author'],
                                            tumour_type = df[row, 'tumor_type'],
                                            patients = df[row, 'patients'],
                                            tumours  = df[row, 'tumours'],
                                            cells = df[row, 'cells'],
                                            genes = df[row, 'genes'],
                                            geo_accession = geo)
 
            }
            df_list[[row]] <- tme_dataset

        }
        # load and return dataset (store as accession.rda for now?)
        return(df_list)
    }

    return(list(df))

}


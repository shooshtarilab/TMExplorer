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

            #download the data into dataframes
            if (df[row,'expression_link'] != ''){
                filename = tempfile()
                download.file(df[row,'expression_link'], destfile=filename)
                expression<- read.csv(filename, sep='\t')
                #expression <- read.csv(df[row,'expression_link'], fileEncoding="latin1" sep='\t')
            } else {
                expression <- data.frame()
            }
            if (df[row,'truth_label_link'] != ''){
                filename = tempfile()
                download.file(df[row,'truth_label_link'], destfile=filename)
                labels <- read.csv(filename)
                #labels <- read.csv(df[row,'truth_label_link'], fileEncoding="latin1" sep='\t')
            } else {
                labels <- data.frame()
            }
            if (df[row,'signature_link'] != ''){
                filename = tempfile()
                download.file(df[row,'signature_link'], destfile=filename)
                sigs <- read.csv(filename)
                #sigs <- read.csv(df[row, 'signature_link'], fileEncoding="latin1" sep='\t')
            } else {
                sigs <- data.frame()
            }

            tme_dataset <- tme_data$new(expression = expression,
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
                                        cells = df[row, 'cells'],
                                        genes = df[row, 'genes'],
                                        geo_accession = geo)
 
            
            df_list[[row]] <- tme_dataset

        }
        return(df_list)
    }

    return(list(df))

}


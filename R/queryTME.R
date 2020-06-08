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
                        cells = "character",
                        genes = "character",
                        geo_accession = "character"))

#' A function to query TME datasets available in this package
#'
#' This function allows you to search and subset included TME datasets
#' @param geo_accession Search by geo accession number
#' @param score_type Search by type of score (TPM, FPKM, raw count)
#' @param has_signatures Return datasets that have gene signatures available (TRUE/FALSE)
#' @param has_truth Search by the presence of known cell-type labels
#' @param tumour_type Search by type of tumour contained in the dataset
#' @param author Search by author
#' @param journal Search by journal
#' @param year Search by exact year or year ranges with '<', '>', or '-'
#' @param pmid Search by Pubmed ID
#' @param sequence_tech Search by sequencing technology
#' @param organism Search by source organism
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
                     author=NULL, #TODO
                     journal=NULL, #TODO
                     year=NULL, #TODO
                     pmid=NULL, #TODO
                     sequence_tech=NULL, #TODO
                     organism=NULL,
                     metadata_only=FALSE){
    data("tme_meta")
    df = tme_meta
    if (!is.null(geo_accession)) {
        #TODO what to do for datasets that aren't in GEO
        df <- df[df$accession == geo_accession,]
    }
    if (!is.null(score_type)) {
        #TODO what to do for datasets with multiple score types available?
        df <- df[toupper(df$score_type) == toupper(score_type) ,]
    }
    if (!is.null(has_signatures)) {
        if (has_signatures) {
            df <- df[df$signatures == 'Y' ,]
        }else if (!has_signatures) {
            df <- df[df$signatures == 'N' ,]
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
        df <- df[toupper(df$tumor_type) == toupper(tumour_type),]
    }
    if (!is.null(author)) {
        df <- df[toupper(df$author) == toupper(author),]
    }
    if (!is.null(journal)) {
        df <- df[toupper(df$journal) == toupper(journal),]
    }
    if (!is.null(year)) {
        #TODO should we be able to search year ranges?
        #df <- df[df$year == year,]
        year = gsub(' ', '', year)
        #check greater than
        if (gregexpr('<', year)[[1]][[1]] == 5 || gregexpr('>',year)[[1]][[1]]==1){
            year = sub('>','',year)
            year = sub('<','',year)
            df <- df[df$year>=year,]
        
        #check between
        }else if (grepl('-',year,fixed=TRUE)){
            year = strsplit(year,'-')[[1]]
            df <- df[df$year>=year[[1]]&df$year<=year[[2]],]
        
        #check less than
        }else if (gregexpr('>', year)[[1]][[1]] == 5 || gregexpr('<',year)[[1]][[1]]==1){
            year = sub('>','',year)
            year = sub('<','',year)
            df <- df[df$year<=year,]
        
        #check equals
        }else{
            df <- df[df$year==year,]
        }
    }
    if (!is.null(pmid)) {
        df <- df[df$PMID == pmid,]
    }
    if (!is.null(sequence_tech)) {
        df <- df[toupper(df$Technology) == toupper(sequence_tech),]
    }
    if (!is.null(organism)) {
        df <- df[toupper(df$Organism) == toupper(organism),]
    }
    if (metadata_only) {
        df[,c('signature_link', 'expression_link', 'truth_label_link')] <- list(NULL)
        return(list(df))
    } else {
        df_list <- list()
        for (row in 1:nrow(df)){
            geo <- df[row, 'accession']
            #print(geo)

            #download the data into dataframes
            if (df[row,'expression_link'] != ''){
                #print('expression')
                filename = tempfile()
                download.file(df[row,'expression_link'], destfile=filename, quiet = TRUE)
                #expression<- read.csv(filename, sep='\t')
                expression<- readRDS(filename)
                #expression <- read.csv(df[row,'expression_link'], fileEncoding="latin1" sep='\t')
            } else {
                expression <- data.frame()
            }
            if (df[row,'truth_label_link'] != ''){
                #print('labels')
                filename = tempfile()
                download.file(df[row,'truth_label_link'], destfile=filename, quiet = TRUE)
                labels<- readRDS(filename)
                #labels <- read.csv(filename)
                #labels <- read.csv(df[row,'truth_label_link'], fileEncoding="latin1" sep='\t')
            } else {
                labels <- data.frame()
            }
            if (df[row,'signature_link'] != ''){
                #print('signatures')
                filename = tempfile()
                download.file(df[row,'signature_link'], destfile=filename, quiet = TRUE)
                sigs<- readRDS(filename)
                #sigs <- read.csv(filename)
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
                                        cells = colnames(expression)[-1],
                                        #TODO maybe figure out how to make this a dataframe with the 
                                        #first few columns if a dataset has multiple identifiers for
                                        #each gene
                                        genes = expression[[1]],
                                        geo_accession = geo)
 
            
            df_list[[row]] <- tme_dataset

        }
        return(df_list)
    }

    return(list(df))

}
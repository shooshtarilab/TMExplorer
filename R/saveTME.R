
#' A function to save a TME dataset
#'
#' This function allows you to save the expression, 
#' labels, and cell types to disk in csv format
#' @param object The tme_data object to be written to disk
#' @param outdir The directory to save the tme_data in
#' @keywords tumour
#' @importFrom methods is
#' @export
#' @section Value:
#' Used to save TME datasets to disk.
#' @examples
#' \dontshow{res <- list(); class(res) <- "tme_data"} 
#' saveTME(res, '~/Downloads/GSE72056')
saveTME <- function(object, outdir){
    if (!is(object,"tme_data")){
        stop('object parameter must be of type tme_data')
    }
    if (file.exists(outdir)){
        stop('outdir must not be an existing directory')
    } else {
        dir.create(outdir)
    }
    # need to test this on windows, make sure it still works
    expr_name <- file.path(outdir, paste(object$geo_accession,"expression.csv", sep='_'))
    label_name <- file.path(outdir, paste(object$geo_accession,"cell_types.csv",sep='_'))
    sig_name <- file.path(outdir, paste(object$geo_accession,"gene_signatures.csv",sep='_'))
    utils::write.csv(object$expression, file=expr_name)
    utils::write.csv(object$labels, file=label_name)
    utils::write.csv(object$signatures, file=sig_name)
    print(paste('Done! Check', outdir, 'for files', sep=' '))
}

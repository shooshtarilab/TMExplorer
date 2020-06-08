
#' A function to save a TME dataset
#'
#' This function allows you to save the expression, labels, and cell types to disk in csv format
#' @param object The tme_data object to be written to disk
#' @param outdir The directory to save the tme_data in
#' @keywords tumour
#' @export
#' saveTME
saveTME <- function(object, outdir){
    if (class(object)[[1]] != "tme_data"){
        stop('object parameter must be of type tme_data')
    }
    if (!file.exists(outdir)){
        stop('outdir must be an existing directory')
    }
    # need to test this on windows, make sure it still works
    expr_name = paste(outdir,"/",object$geo_accession,"_expression.csv",sep='')
    label_name = paste(outdir,"/",object$geo_accession,"_cell_types.csv",sep='')
    sig_name = paste(outdir,"/",object$geo_accession,"_gene_signatures.csv",sep='')
    write.csv(object$expression, file=expr_name)
    write.csv(object$labels, file=label_name)
    write.csv(object$signatures, file=sig_name)
    print(paste('Done! Check', outdir, 'for files'))
}

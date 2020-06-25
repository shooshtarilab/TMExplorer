
#' A function to save a TME dataset
#'
#' This function allows you to save the expression, 
#' labels, and cell types to disk in csv format
#' @param object The tme_data object to be written to disk
#' @param outdir The directory to save the tme_data in
#' @keywords tumour
#' @importFrom methods is
#' @importFrom SingleCellExperiment SingleCellExperiment colData 
#' @export
#' @section Value:
#' Used to save TME datasets to disk.
#' @examples
#' \dontrun{res <- queryTME(geo_accession = 'GSE72056')[[1]]}
#' \dontshow{res <- SingleCellExperiment(list(counts=matrix()))
#' tdir = tempdir()
#' filename = file.path(tdir, 'save_tme_data')} 
#' saveTME(res, filename)
saveTME <- function(object, outdir){
    if (!is(object,"SingleCellExperiment")){
        stop('object parameter must be of type SingleCellExperiment')
    }
    if (file.exists(outdir)){
        stop('outdir must not be an existing directory')
    } else {
        dir.create(outdir)
    }
    # need to test this on windows, make sure it still works
    expr_name <- file.path(outdir, 
                            paste(object@metadata$geo_accession,
                            "expression.csv", 
                            sep='_'))
    label_name <- file.path(outdir, 
                            paste(object@metadata$geo_accession,
                            "cell_types.csv",
                            sep='_'))
    sig_name <- file.path(outdir, 
                            paste(object@metadata$geo_accession,
                            "gene_signatures.csv",
                            sep='_'))
    #TODO may need to add an additional option for saving multiple assays if we 
    # end up storing them in a single object
    utils::write.csv(SingleCellExperiment::counts(object), file=expr_name)
    utils::write.csv(colData(object), file=label_name)
    utils::write.csv(object@metadata$signatures, file=sig_name)
    print(paste('Done! Check', outdir, 'for files', sep=' '))
}

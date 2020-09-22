
#' A function to save a TME dataset
#'
#' This function allows you to save the expression, 
#' labels, and cell types to disk in csv format. It takes two options: 
#' an object to save and a directory to save in. Multiple files will be created in 
#' the provided output directory, one for each type of data available in the tme_data object 
#' (expression, gene signatures, cell type annotations).
#' @param object The tme_data object to be written to disk, this should be an individual dataset returned by queryTME.
#' @param outdir The directory to save the tme_data in, the directory should not exist yet. 
#' @keywords tumour
#' @importFrom methods is
#' @importFrom SingleCellExperiment SingleCellExperiment colData 
#' @export
#' @return Nothing
#' 
#' @examples
#' 
#' # Retrieve a previously identified dataset (see queryTME) and save it to disk
#' \dontrun{res <- queryTME(geo_accession = 'GSE72056')[[1]]}
#' \dontshow{res <- SingleCellExperiment(list(counts=matrix()))
#'          tdir = tempdir()
#'          output_directory_name = file.path(tdir, 'save_tme_data')} 
#' saveTME(res, output_directory_name)
#' 
saveTME <- function(object, outdir){
    if (!is(object,"SingleCellExperiment")){
        stop('object parameter must be of type SingleCellExperiment')
    }
    if (file.exists(outdir)){
        stop('outdir must not be an existing directory')
    } else {
        dir.create(outdir)
    }
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

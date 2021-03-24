---
name: New Dataset Submission
about: Suggest a new dataset for inclusion
title: "[Dataset] <name>"
labels: enhancement
assignees: LordSushiPhoenix, parisashooshtari

---

**Please describe the dataset**

This is just a short description of the dataset so we know more about it.

**Link to the reference for the dataset**

This can be a doi, a journal reference, or an Arxiv link.


**Link to the dataset itself**

This should be a link to the elements of the dataset. It can be a link to any file-hosting platform as long as the files are in the format outlined below. 

- Genes x cell matrix in comma or tab-delimited format
    - The first row should be your cell barcodes/identifiers.
    - The first column should be your gene names/IDs.
    - All other cells should be expression values for a gene in a cell.
- Cell-type labels in comma or tab-delimited format
    - This should have one row for each cell in the gene x cell matrix
    - The first column is the same as the first row in the gene x cell matrix (cell barcodes/identifier)
    - Other columns contain information about each cell, such as what type of cell it is
- Gene signature table in comma or tab-delimited format
    - If you used gene signatures or markers to predict cell types in your data, you can include them here
    - This file should be a matrix, where each column is a cell type and contains the gene signatures you identified in that cell type

**Metadata Table**

Please fill out all columns in the metadata_form.csv and attach it here.

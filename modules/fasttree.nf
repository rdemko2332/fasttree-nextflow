#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/**
 * Create a gene tree per group
 *
 * @param fasta: A group fasta file from the keepSeqIdsFromDeflines process  
 * @return tree Output group tree file
*/
process createGeneTrees {
  container = 'veupathdb/orthofinder'

  publishDir "$params.outputDir/geneTrees", mode: "copy"

  input:
    path fasta

  output:
    path '*.tree'

  script:
    template 'createGeneTrees.bash'
}

workflow fasttreeWorkflow { 
  take:
    fastas

  main:

    createGeneTrees(fastas)

}

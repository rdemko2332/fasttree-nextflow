#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process splitBySize {
  container = 'veupathdb/orthofinder'

  input:
    path fasta

  output:
    path 'large/*', optional: true, emit: large
    path 'small/*', optional: true, emit: small    

  script:
    """
    mkdir small
    mkdir large
    for f in *.fasta;
    do
      SEQ_COUNT=\$(grep ">" \$f | wc -l) 
      if [ "\$SEQ_COUNT" -le 8000 ]; then
	mv \$f small
      else
        mv \$f large
      fi	
    done
    """
}

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

process createLargeGeneTrees {
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

    splitBySizeResults = splitBySize(fastas.collate(10000))

    // Create only large gene trees
    createGeneTrees(splitBySizeResults.small.collect().flatten().collate(1000))
    createLargeGeneTrees(splitBySizeResults.large.collect().flatten())    


}

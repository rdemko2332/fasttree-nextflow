#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process skipSmallGroups {
  container = 'veupathdb/orthofinder'

  input:
    path fasta

  output:
    path 'process/*', optional: true, emit: fastas

  script:
    """
    mkdir process
    for f in *.fasta;
    do
      SEQ_COUNT=\$(grep ">" \$f | wc -l) 
      if [ "\$SEQ_COUNT" -ge 200 ]; then
	cp \$f process
      fi	
    done
    """
}

process filterForCoreSequences {
  container = 'veupathdb/orthofinder:1.8.0'

  input:
    path fasta
    path coreSequences

  output:
    path 'filtered/*.fasta', optional: true, emit: filtered

  script:
    template 'filterForCoreSequences.bash'
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

workflow fasttreeWorkflow { 
  take:
    fastas

  main:

    groupsOver200 = skipSmallGroups(fastas.collate(10000))

    coreFilteredGroupFastas = filterForCoreSequences(groupsOver200.fastas.collect().flatten().collate(1000), params.coreSequences)

    createGeneTrees(coreFilteredGroupFastas.filtered.collect().flatten().collate(1000))

}

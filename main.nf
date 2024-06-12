#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//---------------------------------------------------------------
// Including Workflows
//---------------------------------------------------------------

include { fasttreeWorkflow } from './modules/fasttree.nf'

workflow {
    fastas = Channel.fromPath(params.proteomes)    
    fasttreeWorkflow(fastas);
}

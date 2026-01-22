#!/usr/bin/env bash

mkdir filtered

# Output files
seqids="seqIDs.txt"

grep '^>' $coreSequences \
  | sed 's/^>//' \
  | cut -d' ' -f1 \
  > "\$seqids"

for f in OG*.fasta;
    do

    outfasta="\${f}.coreFiltered"
	
    samtools faidx \$f

    # 3. Extract matching sequences from fasta
    samtools faidx -r \$seqids \$f > \$outfasta



    SEQ_COUNT=\$(grep ">" \$outfasta | wc -l) 
    if [ "\$SEQ_COUNT" -le 1000 ]; then
	cp \$outfasta filtered/\$f
    fi	
done

rm *.coreFiltered
rm *.fai
rm seqIDs.txt

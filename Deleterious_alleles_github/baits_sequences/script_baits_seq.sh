awk '
BEGIN {
    FS = "\n";
    OFS = ",";
    print "Chromosome","Start","End"
}
{
    if ($0 ~ /^>/) {
        if (seq != "") {
            print chrom, 1, length(seq);
            seq = "";
        }
        chrom = substr($0, 2);
    } else {
        seq = seq $0;
    }
}
END {
    if (seq != "") {
        print chrom, 1, length(seq);
    }
}
' /home/thibauld/Documents/Bioinformatics/CAPTUS/Hannah_Begonia_baits_edited.fasta > baits_coordinates.csv


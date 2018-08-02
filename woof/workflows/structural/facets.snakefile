configfile: 'config.yaml'

shell.prefix("set -euo pipefail; ")

localrules: all

SAMPLES_HCC2218 = ["HCC2218"]

SAMPLES_A5_batch1 = ["E019", "E120", "E121", "E123", "E124", "E125", "E129",
                     "E130", "E131", "E133", "E134", "E140", "E141", "E142",
                     "E143", "E144", "E153", "E155", "E156", "E158", "E162",
                     "E163", "E164", "E165", "E168", "E170",
                     "E122-1", "E146-1", 
                     "E159-1", 
                     "E169-1"]

SAMPLES_A5_batch2 = ["E126", "E127", "E128-1", "E132-1", "E135",
                     "E136", "E138", "E145", "E147", "E148",
                     "E149", "E150", "E152", "E154", "E157", "E160", "E161",
                     "E166", "E167-1", "E171"]

rule all:
    input:
        expand(config["out_dir"] + config["tools"]["telseq"]["results_dir"] + "{project}/{sample}_telseq.tsv", project = "A5_batch1", sample = SAMPLES_A5_batch1),
        expand(config["out_dir"] + config["tools"]["telseq"]["results_dir"] + "{project}/{sample}_telseq.tsv", project = "A5_batch2", sample = SAMPLES_A5_batch2)




rule facets_coverage:
    input:
        vcf    = config["data_dir"] + config["tools"]["facets"]["vcf"],
        normal = lambda wildcards: config["bam_dir"][wildcards.project] + config["samples"][wildcards.project][wildcards.sample]["normal"]["bam"],
        tumor  = lambda wildcards: config["bam_dir"][wildcards.project] + config["samples"][wildcards.project][wildcards.sample]["tumor"]["bam"]
    output:
        snpfile = config["out_dir"] + config["tools"]["facets"]["cov_dir"] + "{project}/{sample}_cov.csv.gz"
    params:
        pileup = config["tools"]["facets"]["snp-pileup"]
    shell:
        "module load SAMtools; module load HTSlib; "
        "{params.pileup} -g -q 30 -Q 30 -r 10,10 "
        "{input.vcf} "
        "{output.snpfile} "
        "{input.normal} {input.tumor}"


rule facets_run:
    input:
        snpfile = config["out_dir"] + config["tools"]["facets"]["cov_dir"] + "{project}/{sample}_cov.csv.gz"
    output:
        fit = config["out_dir"] + config["tools"]["facets"]["results_dir"] + "{project}/{sample}/{sample}_cval_{cval}_fit.rds"
    params:
        outdir = config["out_dir"] + config["tools"]["facets"]["results_dir"] + "{project}/{sample}",
        run_facets = "/data/cephfs/punim0010/projects/Diakumis_woof/scripts/structural/run_facets.R"
    log:
        log = config["out_dir"] + config["tools"]["facets"]["results_dir"] + "{project}/{sample}/{sample}_run_facets_cval_{cval}.log"
    shell:
        "/usr/local/easybuild/software/R/3.5.0-GCC-4.9.2/bin/Rscript {params.run_facets} "
        "-s {wildcards.sample} -f {input.snpfile} -c {wildcards.cval} -o {params.outdir} 2> {log.log}"


rule facets_circos:
    input:
        manta_vcf = lambda wildcards: config["bam_dir"][wildcards.project] + config["samples"][wildcards.project][wildcards.sample]["tumor"]["vcf"],
        fit = config["out_dir"] + config["tools"]["facets"]["results_dir"] + "{project}/{sample}/{sample}_cval_{cval}_fit.rds"
    output:
        manta_tsv = config["out_dir"] + config["tools"]["facets"]["results_dir"] + "{project}/{sample}/{sample}_cval_{cval}_manta_svs.tsv",
        facets_circos = config["out_dir"] + config["tools"]["facets"]["results_dir"] + "{project}/{sample}/{sample}_cval_{cval}_manta_facets_circos.pdf"
    shell:
        "bcftools query -f \"%CHROM\t%INFO/BPI_START\t%INFO/BPI_END\t%ID\t%INFO/MATEID\t%INFO/SVTYPE\t%FILTER\n\" {input.manta_vcf} > {output.manta_tsv}; "
        "/usr/local/easybuild/software/R/3.5.0-GCC-4.9.2/bin/Rscript ../../scripts/structural/circos/circos.R "
        "-f {input.fit} -m {output.manta_tsv} -o {output.facets_circos}"

rule facets_fit2tsv:
    input:
        fit = config["out_dir"] + config["tools"]["facets"]["results_dir"] + "{project}/{sample}/{sample}_cval_{cval}_fit.rds"
    output:
        segs = config["out_dir"] + config["tools"]["facets"]["results_dir"] + "{project}/{sample}/{sample}_cval_{cval}_fit_segs.tsv",
        purply = config["out_dir"] + config["tools"]["facets"]["results_dir"] + "{project}/{sample}/{sample}_cval_{cval}_fit_purply.tsv"
    shell:
        "/usr/local/easybuild/software/R/3.5.0-GCC-4.9.2/bin/Rscript ../../scripts/structural/facets_fit2tsv.R "
        "-f {input.fit}"




rule facets_report:
    input:
        fit = config["out_dir"] + config["tools"]["facets"]["results_dir"] + "{project}/{sample}/{sample}_cval_{cval}_fit.rds"
    params:
        outdir = config["out_dir"] + config["tools"]["facets"]["results_dir"] + "{project}/{sample}",
    log:
        log = config["out_dir"] + config["tools"]["facets"]["results_dir"] + "{project}/{sample}/{sample}_run_facets_cval_{cval}.log"
    shell:
        "Rscript ../../templates/structural/render_facets_report.R "
        "-r ../../templates/structural/facets_report.Rmd "
        "-s {wildcards.sample} -c {wildcards.cval} -o {params.outdir} 2> {log.log}"


rule pdf2png:
    input:
        pdf = "{path_A}.pdf"
    output:
        png = "{path_A}.png"
    shell:
        "module load ImageMagick; convert -antialias -density 300 {input.pdf} {output.png}"


rule telseq_run:
    input:
        bam = lambda wildcards: config["bam_dir"][wildcards.project] + config["samples"][wildcards.project][wildcards.sample]["normal"]["bam"]
    output:
        telseq = config["out_dir"] + config["tools"]["telseq"]["results_dir"] + "{project}/{sample}_telseq.tsv"
    shell:
        "telseq -k 9 -r 150 -u -o {output.telseq} {input.bam}"
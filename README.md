
# woof
Woofing workflows using
[WDL](https://software.broadinstitute.org/wdl/),
[CWL](https://www.commonwl.org/) and
[Cromwell](https://cromwell.readthedocs.io/en/stable/).

Contents
--------

<!-- vim-markdown-toc GFM -->

* [Quick Start](#quick-start)
    * [Run Cromwell (__draft__)](#run-cromwell-__draft__)
* [Installation](#installation)
    * [Step 1: Clone woof repo](#step-1-clone-woof-repo)
    * [Step 2: Create conda environment](#step-2-create-conda-environment)
* [Repo Structure](#repo-structure)
* [Workflows](#workflows)
    * [bcbio run comparison](#bcbio-run-comparison)
        * [Input](#input)
        * [Command](#command)
        * [Output](#output)
    * [AGHA data validation](#agha-data-validation)

<!-- vim-markdown-toc -->


# Quick Start

## Run Cromwell (__draft__)

* From within the `woof/wdl` directory:

```
cromwell run \
  -i inputs.json \
  -Dconfig.file=conf/cromwell.conf \
  --metadata-output meta.json \
  --options options.json \
  compare_vcf_files.wdl
```

# Installation

## Step 1: Clone woof repo

```
git clone git@github.com:pdiakumis/woof.git
```

## Step 2: Create conda environment

```
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh
conda update -n base -c defaults conda
conda env create -f woof/env/woof.yaml
```

# Repo Structure





# Workflows

bcbio run comparison
----------------

### Input

* `final1` & `final2`: path to two bcbio `final` results
* `name`: name to use for the result output directory e.g. `v1.3_vs_v1.4` or `dev_vs_stable` (default: `<timestamp>_compare`)

### Command

```
woof compare /path/to/final1 /path/to/final2 name
```

### Output

* `<name>`: directory with comparison results
    * `<name>_report.html`: final comparison report
    * `bcftools_isec`: results from `bcftools isec`
    * `counts`: results from simply counting total and `PASS` variants

AGHA data validation
--------------------

```
woof validate /path/to/data
```

* __FASTQ__

- [fqtools validate](https://github.com/alastair-droop/fqtools)

* __BAM__

- GATK ValidateSamFile [link1](https://software.broadinstitute.org/gatk/documentation/article.php?id=7571),
  [link2](http://broadinstitute.github.io/picard/command-line-overview.html#ValidateSamFile)
- [UMich BamUtil validate](https://genome.sph.umich.edu/wiki/BamUtil:_validate)
- [samtools quickcheck](http://www.htslib.org/doc/samtools.html)

* __VCF__

- [EBI vcf-validator](https://github.com/EBIvariation/vcf-validator)


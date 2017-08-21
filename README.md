# snakes
Pipelines and random scripts using
[Snakemake](https://snakemake.readthedocs.io/en/stable/index.html).

<h2>Contents</h2>

<!-- vim-markdown-toc GFM -->
* [quick start](#quick-start)
    * [example runs](#example-runs)
* [resources](#resources)

<!-- vim-markdown-toc -->

## quick start
* `environment.yaml`: contains tools you want to use in the pipeline.
* `rule.snakefile`: contains one or more pipeline steps (called 'rules'). Each
  rule can run for multiple samples, thus creating multiple 'jobs'.
* `cluster.json`: cluster configuration file to specify partition, time etc.

### example runs

* Dry run and print shell command used:

```bash
snakemake -s rule.snakefile -np
```

* Plot DAG:

```bash
snakemake -s rule.snakefile --dag | dot -Tsvg > dag.svg
```

* Run on multiple cores:

```bash
snakemake -s rule.snakefile -j 4
```

* Run on PBS/TORQUE cluster:
    - Each job will be compiled into a shell script that is submitted with the
      given command (e.g. `qsub`). The `--jobs 100` flag limits the number of
      concurrently submitted jobs to 100.
    - You can decorate the specified submission command with parameters from the
      submitted job (e.g. `threads`).

```bash
snakemake -s rule.snakefile --cluster qsub --jobs 100
snakemake -s rule.snakefile --cluster "qsub -pe threaded {threads}" --jobs 100
```

* Run on SLURM cluster:

```bash
snakemake -j 999 \
          --cluster-config cluster.json \
          --cluster "sbatch -A {cluster.account} \
          -p {cluster.partition} \
          -n {cluster.n} \
          -t {cluster.time}"
```

where `cluster.json` is:

```
{
    "__default__" :
    {
        "account" : "my account",
        "time" : "00:15:00",
        "n" : 1,
        "partition" : "core"
    },
    "compute1" :
    {
        "time" : "00:20:00"
    }
}
```


## resources

* Snakemake docs: <https://snakemake.readthedocs.io/en/stable/>
* Snakemake code examples: <https://codegists.com/code/snakefile/>
* Useful rules repo: <https://github.com/percyfal/snakemake-rules>
* Snakemake on SLURM: <https://hpc.nih.gov/apps/snakemake.html>

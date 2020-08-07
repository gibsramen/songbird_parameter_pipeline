This is companion pipeline for pseudo-optimizing parameters in [Songbird](https://github.com/biocore/songbird). The reason for the inclusion of "pseudo" is because this pipeline does *not* use any sort of optimization or cost function. Instead, the user provides a list of parameters they wish to test and the pipeline performs all possible permutations and tabulates the results.

## Setup

### Point to data

Use the included `config.py` script to configure the pipeline for your own use. Arguments are the feature table, and sample metadata.

Example usage:

```
python config.py \
    --feature-table data/feature_table.qza \
    --sample-metadata data/metadata.tsv
```

### Configure Songbird parameters

Open the `config/config.yaml` file and add entries for formulae, diff(erential) prior, and learning rate. You may also change the default number of epochs and/or summary interval if you wish.

### Configure cluster parameters

Open the `config/cluster.yaml` file and edit the `run_songbird` cluster options for memory and walltime if necessary. Additionally, you may want to change the default "out" directory to which PBS logging files go.

Additionally, you may want to edit the `run_snakemake.sh` script with additional Snakemake options. The Snakemake documentation can be found [here](https://snakemake.readthedocs.io/en/stable/executing/cli.html). Chief among these is the `--j` flag which specifies the max number of jobs to run in parallel on your cluster. Please be respectful of your cluster's resources!

Note that this pipeline was written for the Knight Lab cluster which uses TORQUE for scheduling. If you are using a different scheduler you will have to edit the `cluster.yaml` and `run_snakemake.sh` files accordingly.

## Running the pipeline

Assuming all setup was completed correctly, from your cluster you should be able to run the `run_snakemake.sh` script directly to start submitting jobs to your cluster.

There are two main parts to the pipeline:

1. Running all possible permutations of the desired Songbird parameters
2. Tabulating the resulting $$Q^2$$ values from each model comparison

First, Snakemake will run Songbird models with all possible combinations of parameters. For each permutation, both a test model and baseline (formula = 1) model are created. Each run is saved to `results/songbird/` as its own directory containing the following files:

* `differentials.qza`
* `reg_stats.qza`
* `reg_biplot.qza`
* `paired_summary.qzv`

Next, the `paired_summary.qzv` results of each parameter permutation are processed to extract the $$Q^2$$ value. These results are then tabulated into a file located at `results/q2_scores.tsv`. This file lists each parameter set and the $$Q^2$$ value that resulted from the accompanying model.

IMPORTANT NOTE: This pipeline does *not* check the RMSE or loss graphs from the `paired_summary.qzv` files. Please ensure that you check these graphs manually for a selected Songbird parameter set.

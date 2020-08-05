configfile: "config/config.yaml"

import glob

import pandas as pd
from qiime2 import Artifact, Metadata, Visualization
from qiime2.plugins import songbird

from util import get_summary, get_q2, extract_params

param_search_sb_files = expand(
    "results/songbird/f_{formula}_dp_{dp}_lr_{lr}/{res}",
    formula=config["songbird_params"]["formula"],
    dp=config["songbird_params"]["diff_prior"],
    lr=config["songbird_params"]["learning_rate"],
    res=[
        "differentials.qza",
        "reg_stats.qza",
        "reg_biplot.qza",
        "paired_summary.qzv",
    ]
)

localrules: all

rule all:
    input:
        "results/q2_scores.tsv",
        param_search_sb_files

rule create_q2_file:
    input:
        glob.glob(
            "results/songbird/*/paired_summary.qzv"
        )
    output:
        "results/q2_scores.tsv"
    run:
        all_param_dict = dict()
        for i, f in enumerate(input):
            viz = Visualization.load(f)
            q2 = get_q2(viz)
            p = extract_params(f)
            p["q2"] = q2

            all_param_dict[i] = p

        q2_df = pd.DataFrame.from_records(all_param_dict).T
        q2_df = q2_df[
            ["formula", "differential_prior", "learning_rate", "q2"]
        ]
        q2_df.to_csv(output[0], index=False, sep="\t")

rule run_songbird:
    input:
        table = "[[[TABLE]]]",
        metadata = "[[[METADATA]]]"
    output:
        expand(
            "results/songbird/f_{{formula}}_dp_{{dp}}_lr_{{lr}}/{res}",
            res=[
                "differentials.qza",
                "reg_stats.qza",
                "reg_biplot.qza",
                "paired_summary.qzv"
            ]
        )
    run:
        tbl = Artifact.load(input.table)
        meta = Metadata.load(input.metadata)

        sb_results, sb_null_results, summ = get_summary(
            table=tbl,
            metadata=meta,
            formula=str(wildcards.formula),
            base_formula="1",
            differential_prior=float(wildcards.dp),
            learning_rate=float(wildcards.lr),
            epochs=int(config["songbird_params"]["epochs"]),
        )

        diff, stats, bp = sb_results
        diff.save(str(output[0]))
        stats.save(str(output[1]))
        bp.save(str(output[2]))

        summ.visualization.save(str(output[3]))

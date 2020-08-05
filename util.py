#!/usr/bin/env python

import os
import re
import sys

import numpy as np
import pandas as pd
from qiime2 import Artifact
from qiime2.plugins import songbird

def get_summary(table, metadata, formula, base_formula, epochs=10000, **kwargs):
    """Get paired summary of songbird model."""
    sb_null_results = songbird.actions.multinomial(
        table=table,
        metadata=metadata,
        formula=base_formula,
        epochs=epochs,
        random_seed=42,
        min_sample_count=500,
        min_feature_count=10,
        quiet=True,
        summary_interval=1,
        **kwargs,
    )

    sb_results = songbird.actions.multinomial(
        table=table,
        metadata=metadata,
        formula=formula,
        epochs=epochs,
        random_seed=42,
        min_sample_count=500,
        min_feature_count=10,
        quiet=True,
        summary_interval=1,
        **kwargs,
    )

    sb_paired_summary = songbird.actions.summarize_paired(
        regression_stats=sb_results.regression_stats,
        baseline_stats=sb_null_results.regression_stats,
    )

    return sb_results, sb_null_results, sb_paired_summary

def get_q2(summary):
    """Get Q^2 value from paired summary."""
    viz_path = f"{str(summary._archiver.data_dir)}/index.html"

    with open(viz_path, "r") as f:
        text = f.read()

    q2_string = re.search(
        r"Q-squared:</a></strong> (-?[\d\.]+)",
        text,
    )

    return float(q2_string.groups()[0])

def extract_params(text):
    """Extract parameter values from filepath."""
    param_names = ["formula", "differential_prior", "learning_rate"]
    params = list(re.search(
        r"f_(.+)_dp_([\d\.]+)_lr_([\d\.]+)",
        text,
    ).groups())

    param_dict = {
        param: value
        for param, value in zip(param_names, params)
    }

    return param_dict

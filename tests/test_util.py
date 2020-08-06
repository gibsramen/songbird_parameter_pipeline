#!/usr/bin/env python

from qiime2 import Visualization

import util


def test_get_q2():
    paired_summ = Visualization.load("tests/data/paired_summary.qzv")
    q2 = util.get_q2(paired_summ)
    assert q2 == 0.091066


def test_extract_params():
    s = "f_diet*genotype_dp_1.0_lr_0.001"
    test_param_dict = util.extract_params(s)
    actual_param_dict = {
        "formula": "diet*genotype",
        "differential_prior": "1.0",
        "learning_rate": "0.001",
    }

    assert test_param_dict == actual_param_dict

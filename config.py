#!/usr/bin/env python

import fileinput

import click
from qiime2 import Artifact, Metadata


@click.command()
@click.option(
    "--feature-table",
    type=click.Path(exists=True),
    required=True,
)
@click.option(
    "--sample-metadata",
    type=click.Path(exists=True),
    required=True,
)
def setup(feature_table, sample_metadata):
    try:
        Artifact.load(feature_table)
    except Exception as e:
        raise ValueError(e)

    try:
        Metadata.load(sample_metadata)
    except Exception as e:
        raise ValueError(e)

    with fileinput.input("config/config.yaml", inplace=True) as f:
        for line in f:
            if f.filelineno() == 1:
                print(f"feature_table: {feature_table}")
            elif f.filelineno() == 2:
                print(f"sample_metadata: {sample_metadata}")
            else:
                print(line, end="")


if __name__ == "__main__":
    setup()

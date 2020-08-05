#!/bin/bash

# Script to run on barnacle

snakemake \
    -j 10 \
    --latency-wait 60 \
    --cluster-config config/cluster.yaml \
    --cluster "qsub -V -l pmem={cluster.pmem} -l vmem={cluster.vmem} -l walltime={cluster.time} -l nodes={cluster.nodes} -j oe -o {cluster.out} -N {cluster.name}"

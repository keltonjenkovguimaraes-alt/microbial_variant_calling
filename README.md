# Microbial Variant Calling Pipeline

A reproducible Snakemake workflow for calling SNPs and structural variants in organisms without benchmarked variant databases.

## Overview

This pipeline implements the methodology from:

> Gunasekaran, D., Ardell, D. H., & Nobile, C. J. (2024). SNP-SVant: A computational workflow to predict and annotate genomic variants in organisms lacking benchmarked variants. *Current Protocols*, 4, e1046.

## Key Features

- **Unified SNP + SV calling** in a single workflow
- **BQSR without benchmarked variants** using iterative recalibration
- **Snakemake-managed** reproducibility with checkpoint resumption
- **Conda-based** dependency management
- **GATK4 best practices** variant calling and hard filtering
- **VEP** functional effect annotation

## Quick Start

```bash
# Clone
git clone https://github.com/keltonjenkovguimaraes-alt/microbial_variant_calling.git
cd microbial_variant_calling

# Install dependencies
conda env create -f workflow/envs/environment.yaml
conda activate snp_svant

# Configure samples
# Edit config/samples.tsv with your sample information

# Run pipeline
snakemake -s workflow/Snakefile --cores 8 all --latency-wait 30
Requirements
Linux (Ubuntu 18.04+)

≥32 GB RAM

≥8 CPU cores

Conda/Mamba

Pipeline Steps
FastQC quality control

Bowtie2 read alignment

Picard duplicate marking

First-pass GATK HaplotypeCaller

Base quality score recalibration (BQSR) — 2 rounds

Final variant calling and filtering

VEP annotation

Test Data
Example using Candida albicans:

Reference: GCF_000182965.3 (SC5314)

Reads: SRA SRR7801919

License
MIT

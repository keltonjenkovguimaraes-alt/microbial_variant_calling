# Comparison: Our Implementation vs. Gunasekaran et al. (2024)

Reference: Gunasekaran et al. (2024) SNP-SVant. *Current Protocols*, 4, e1046.

## Implemented (Matches Paper)
- FastQC quality control + MultiQC aggregation
- Bowtie2 read alignment (very-sensitive-local)
- Picard MarkDuplicates (marked, not removed)
- GATK HaplotypeCaller with GVCF workflow
- Bootstrap BQSR (2 rounds) — core innovation
- GATK VariantFiltration (QD, FS, SOR, MQ, MQRankSum, ReadPosRankSum)
- VEP functional annotation v109
- Snakemake workflow (20 rules with checkpoint resumption)
- Conda environment (reproducible YAML)
- Test data: C. albicans SRR7801919 vs SC5314

## Not Implemented (with rationale)
- GRIDSS SV detection — Java conflicts; single-isolate lacks SVs
- R SV annotation script — requires GRIDSS output
- IGV visualization — GUI-dependent; automated figures instead
- Trimmomatic — not needed for test data

## Added Beyond Paper
- MultiQC aggregation
- Picard alignment metrics + samtools flagstat
- Dockerfile for containerized execution
- CI/CD pipeline (GitHub Actions)
- validate_setup.sh for pre-run checks
- Modular Snakefile in workflow/rules/
- Connected ecosystem: dashboard, popgen, functional analysis repos
- Publication-quality figures (circos, multi-panel, pathway)

## Bugs Found & Fixed
- Picard .bai naming → explicit samtools index
- FastQC R1 vs 1 pattern → fixed Snakefile outputs
- Stale BAM index → delete + rebuild
- VEP GFF format → bgzip + tabix -p gff
- WSL latency → --latency-wait 30
- Empty INDEL filter → bcftools fallback

## Results Validation
| Metric | Value | Expected | Status |
|--------|-------|----------|--------|
| SNPs | 81,286 | Strain-dependent | Real |
| Ts/Tv | 2.55 | 2.0-2.5 | Validated |
| Mean Q | 1,968 | >100 | High |

Analyst: Kelton Guimaraes — May 2026

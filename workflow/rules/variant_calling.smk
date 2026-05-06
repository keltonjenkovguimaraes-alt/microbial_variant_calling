"""
Core variant calling rules implementing the SNP-SVant approach
"""

rule map_reads:
    """
    Align paired-end reads to reference genome using Bowtie2
    """
    input:
        r1 = "data/raw/{sample}_R1.fastq.gz",
        r2 = "data/raw/{sample}_R2.fastq.gz",
        index = "data/reference/reference.fasta.1.bt2"
    output:
        "results/alignment/{sample}.sam"
    params:
        rg = r"@RG\tID:{sample}\tSM:{sample}\tPL:ILLUMINA"
    threads: 8
    conda:
        "workflow/envs/environment.yaml"
    shell:
        """
        bowtie2 -x data/reference/reference.fasta \
                -1 {input.r1} -2 {input.r2} \
                --rg-id {wildcards.sample} \
                --rg 'PL:ILLUMINA' \
                --rg 'SM:{wildcards.sample}' \
                -p {threads} \
                -S {output} 2> results/alignment/{wildcards.sample}_bowtie2.log
        """

rule sort_bam:
    """
    Sort SAM file and convert to BAM
    """
    input:
        "results/alignment/{sample}.sam"
    output:
        "results/alignment/{sample}.sorted.bam"
    threads: 4
    conda:
        "workflow/envs/environment.yaml"
    shell:
        "samtools sort -@ {threads} -o {output} {input}"

rule mark_duplicates:
    """
    Mark PCR duplicates using Picard
    Important: Duplicates are marked, not removed, per GATK best practices
    """
    input:
        "results/alignment/{sample}.sorted.bam"
    output:
        bam = "results/alignment/{sample}.dedup.bam",
        metrics = "results/alignment/{sample}.dedup_metrics.txt"
    conda:
        "workflow/envs/environment.yaml"
    shell:
        """
        picard MarkDuplicates \
            I={input} \
            O={output.bam} \
            M={output.metrics} \
            CREATE_INDEX=true \
            VALIDATION_STRINGENCY=SILENT
        """

rule first_pass_variant_calling:
    """
    First round of variant calling with HaplotypeCaller
    This is the initial variant discovery before BQSR
    """
    input:
        bam = "results/alignment/{sample}.dedup.bam",
        ref = "data/reference/reference.fasta"
    output:
        "results/variants/first_pass/{sample}.g.vcf.gz"
    threads: 4
    conda:
        "workflow/envs/environment.yaml"
    shell:
        """
        gatk HaplotypeCaller \
            -R {input.ref} \
            -I {input.bam} \
            -O {output} \
            -ERC GVCF \
            --native-pair-hmm-threads {threads}
        """

rule first_pass_filtering:
    """
    Filter first-pass variants using GATK recommended thresholds
    These high-quality variants will serve as the "truth set" for BQSR
    """
    input:
        gvcf = "results/variants/first_pass/{sample}.g.vcf.gz",
        ref = "data/reference/reference.fasta"
    output:
        filtered = "results/variants/first_pass/{sample}.filtered.vcf.gz"
    conda:
        "workflow/envs/environment.yaml"
    shell:
        """
        gatk GenotypeGVCFs \
            -R {input.ref} \
            -V {input.gvcf} \
            -O temp.vcf.gz
        
        gatk VariantFiltration \
            -R {input.ref} \
            -V temp.vcf.gz \
            --filter-expression '{config[snp_filters][QD]}' \
            --filter-name 'QD' \
            --filter-expression '{config[snp_filters][FS]}' \
            --filter-name 'FS' \
            --filter-expression '{config[snp_filters][SOR]}' \
            --filter-name 'SOR' \
            --filter-expression '{config[snp_filters][MQ]}' \
            --filter-name 'MQ' \
            -O {output.filtered}
        
        rm temp.vcf.gz temp.vcf.gz.tbi
        """

rule base_quality_recalibration:
    """
    BQSR using filtered variants from first pass as "known" variants
    This is the key innovation from the paper for organisms without benchmarked variants
    """
    input:
        bam = "results/alignment/{sample}.dedup.bam",
        ref = "data/reference/reference.fasta",
        known_variants = "results/variants/first_pass/{sample}.filtered.vcf.gz"
    output:
        recal_table = "results/bqsr/{sample}.recal.table"
    conda:
        "workflow/envs/environment.yaml"
    shell:
        """
        gatk BaseRecalibrator \
            -R {input.ref} \
            -I {input.bam} \
            --known-sites {input.known_variants} \
            -O {output.recal_table}
        """

rule apply_bqsr:
    """
    Apply base quality recalibration to aligned reads
    """
    input:
        bam = "results/alignment/{sample}.dedup.bam",
        ref = "data/reference/reference.fasta",
        recal_table = "results/bqsr/{sample}.recal.table"
    output:
        "results/alignment/{sample}.recal.bam"
    conda:
        "workflow/envs/environment.yaml"
    shell:
        """
        gatk ApplyBQSR \
            -R {input.ref} \
            -I {input.bam} \
            --bqsr-recal-file {input.recal_table} \
            -O {output}
        """

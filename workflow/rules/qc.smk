"""
Quality control and preprocessing rules
"""

rule fastqc_raw:
    """
    Run FastQC on raw sequencing reads
    """
    input:
        r1 = "data/raw/{sample}_R1.fastq.gz",
        r2 = "data/raw/{sample}_R2.fastq.gz"
    output:
        html_r1 = "results/qc/raw/{sample}_R1_fastqc.html",
        html_r2 = "results/qc/raw/{sample}_R2_fastqc.html",
        zip_r1 = "results/qc/raw/{sample}_R1_fastqc.zip",
        zip_r2 = "results/qc/raw/{sample}_R2_fastqc.zip"
    threads: 2
    conda:
        "workflow/envs/environment.yaml"
    shell:
        """
        fastqc -t {threads} -o results/qc/raw/ {input.r1} {input.r2}
        """

rule multiqc:
    """
    Aggregate FastQC reports with MultiQC
    """
    input:
        expand("results/qc/raw/{sample}_R{rp}_fastqc.zip", 
               sample=config["samples"], rp=[1,2])
    output:
        "results/qc/multiqc_report.html"
    conda:
        "workflow/envs/environment.yaml"
    shell:
        "multiqc results/qc/raw/ -o results/qc/"

"""
Reference genome preparation rules
"""

rule build_bowtie2_index:
    """
    Build Bowtie2 index for reference genome alignment
    """
    input:
        "data/reference/reference.fasta"
    output:
        "data/reference/reference.fasta.1.bt2",
        "data/reference/reference.fasta.2.bt2",
        "data/reference/reference.fasta.3.bt2",
        "data/reference/reference.fasta.4.bt2",
        "data/reference/reference.fasta.rev.1.bt2",
        "data/reference/reference.fasta.rev.2.bt2"
    conda:
        "workflow/envs/environment.yaml"
    shell:
        "bowtie2-build {input} data/reference/reference.fasta"

FROM continuumio/miniconda3:latest

WORKDIR /app

COPY workflow/envs/environment.yaml /app/
RUN conda env create -f environment.yaml

COPY . /app/

ENV PATH /opt/conda/envs/snp_svant/bin:$PATH
ENTRYPOINT ["snakemake", "-s", "workflow/Snakefile"]
CMD ["--cores", "4", "all"]

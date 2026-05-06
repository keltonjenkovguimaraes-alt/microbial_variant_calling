#!/bin/bash

echo "=== Validating Pipeline Setup ==="
echo ""

# Check directories
echo "1. Checking directory structure..."
for dir in data/raw data/reference config workflow/rules workflow/envs results; do
    if [ -d "$dir" ]; then
        echo "   ✓ $dir exists"
    else
        echo "   ✗ $dir MISSING"
    fi
done

# Check required files
echo ""
echo "2. Checking required files..."
for file in data/reference/reference.fasta data/reference/reference.gff config/samples.tsv config/config.yaml; do
    if [ -f "$file" ]; then
        echo "   ✓ $file exists"
    else
        echo "   ✗ $file MISSING"
    fi
done

# Check FASTQ files
echo ""
echo "3. Checking sequencing data..."
if [ -f "data/raw/SRR7801919_1.fastq.gz" ] && [ -f "data/raw/SRR7801919_2.fastq.gz" ]; then
    echo "   ✓ Paired-end FASTQ files found"
    echo "   R1 size: $(du -h data/raw/SRR7801919_1.fastq.gz | cut -f1)"
    echo "   R2 size: $(du -h data/raw/SRR7801919_2.fastq.gz | cut -f1)"
else
    echo "   ✗ FASTQ files missing or incomplete"
fi

# Check reference genome
echo ""
echo "4. Checking reference genome..."
if [ -f "data/reference/reference.fasta" ]; then
    echo "   ✓ Reference genome found"
    echo "   Size: $(du -h data/reference/reference.fasta | cut -f1)"
    head -n 1 data/reference/reference.fasta
else
    echo "   ✗ Reference genome missing"
fi

echo ""
echo "=== Validation Complete ==="

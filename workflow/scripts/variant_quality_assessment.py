#!/usr/bin/env python3
"""
Generate quality control plots for variant calling metrics.
Based on Figure 2 from Gunasekaran et al. (2024).
"""

import argparse
import vcf
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import sys

def parse_args():
    parser = argparse.ArgumentParser(description='Generate variant quality plots')
    parser.add_argument('-i', '--input', required=True, help='Input VCF file')
    parser.add_argument('-o', '--output', required=True, help='Output plot file')
    return parser.parse_args()

def extract_quality_metrics(vcf_file):
    """Extract quality metrics from VCF INFO field"""
    metrics = {
        'QD': [], 'FS': [], 'SOR': [], 'MQ': [],
        'MQRankSum': [], 'ReadPosRankSum': []
    }
    
    try:
        reader = vcf.Reader(filename=vcf_file)
        for record in reader:
            if hasattr(record, 'INFO'):
                for key in metrics.keys():
                    if key in record.INFO:
                        try:
                            val = record.INFO[key]
                            if isinstance(val, list):
                                val = val[0]
                            metrics[key].append(float(val))
                        except (ValueError, TypeError):
                            pass
    except Exception as e:
        print(f"Warning: Could not fully parse {vcf_file}: {e}", file=sys.stderr)
    
    return metrics

def create_plots(metrics, output_file):
    """Create quality metric density plots"""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    axes = axes.flatten()
    
    titles = {
        'QD': 'Quality by Depth (QD)',
        'FS': 'Fisher Strand Bias (FS)',
        'SOR': 'Strand Odds Ratio (SOR)',
        'MQ': 'Mapping Quality (MQ)',
        'MQRankSum': 'Mapping Quality Rank Sum',
        'ReadPosRankSum': 'Read Position Rank Sum'
    }
    
    thresholds = {
        'QD': 2.0, 'FS': 60.0, 'SOR': 4.0,
        'MQ': 40.0, 'MQRankSum': -12.5, 'ReadPosRankSum': -8.0
    }
    
    for idx, (metric, title) in enumerate(titles.items()):
        ax = axes[idx]
        if metrics[metric]:
            sns.kdeplot(data=metrics[metric], ax=ax, fill=True)
            ax.axvline(x=thresholds[metric], color='red', linestyle='--', 
                      label=f'Threshold: {thresholds[metric]}')
        ax.set_title(title)
        ax.set_xlabel(metric)
        ax.set_ylabel('Density')
        ax.legend()
    
    # Remove empty subplot if needed
    if len(titles) < 6:
        axes[-1].set_visible(False)
    
    plt.tight_layout()
    plt.savefig(output_file, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Plot saved to {output_file}")

def main():
    args = parse_args()
    print(f"Extracting quality metrics from {args.input}...")
    metrics = extract_quality_metrics(args.input)
    print(f"Creating quality plots...")
    create_plots(metrics, args.output)

if __name__ == '__main__':
    main()

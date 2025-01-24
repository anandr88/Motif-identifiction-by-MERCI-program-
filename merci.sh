#!/bin/bash

# Define arrays for parameter values
ks=(50)
#ks=(10 20 50 100 500 1000 )
gs=(0)
#gs=(0 1 2)
cs=("KOOLMAN-ROHM")
#cs=("NONE" "KOOLMAN-ROHM" "BETTS-RUSSELL")
#fps=(5 10 15 20)  # Add -fp parameter values
fps=(10) 
#fns=(1 2 3 4)     # Add -fn parameter values
fns=(0)

# Iterate over each combination of k, g, c, fp, and fn
for k in "${ks[@]}"; do
    for g in "${gs[@]}"; do
        for c in "${cs[@]}"; do
            for fp in "${fps[@]}"; do
                for fn in "${fns[@]}"; do
                    # Sanitize the c value for valid filenames by replacing special characters with underscores
                    c_sanitized=$(echo "$c" | tr '-' '_')

                    # Define output directories and create them if they don't exist
                    output_dir="./motif_alt_result/k_${k}_g${g}_c${c_sanitized}_fp${fp}_fn${fn}"
                    mkdir -p "$output_dir"

                    # Define output file names based on parameter combinations
                    output_file="${output_dir}/neg_k_${k}C${c_sanitized}_g${g}_fp${fp}_fn${fn}.txt"
                    locator_output="${output_dir}/locator_neg_k_${k}C${c_sanitized}_g${g}_fp${fp}_fn${fn}"

                    # Run the MERCI.pl script with current parameter values
                    echo "Running MERCI.pl with k=${k}, g=${g}, c=${c}, fp=${fp}, fn=${fn}"
                    perl MERCI.pl -p /Users/anandr/Downloads/Neurotoxic_peptide_prediction/Data/pos_train_alt.fasta \
                        -n /Users/anandr/Downloads/Neurotoxic_peptide_prediction/Data/neg_train_alt.fasta \
                        -k "$k" -g "$g" -c "$c" -fp 10 -fn 0 -o "$output_file"

                    # Check if the MERCI.pl command was successful
                    if [ $? -eq 0 ]; then
                        echo "MERCI.pl script completed successfully for k=${k}, g=${g}, c=${c}, fp=${fp}, fn=${fn}."

                        # Run the MERCI_motif_locator.pl script with the output from MERCI.pl
                        echo "Running MERCI_motif_locator.pl with input=${output_file}"
                        perl MERCI_motif_locator.pl -i "$output_file" \
                            -p /Users/anandr/Downloads/Neurotoxic_peptide_prediction/Data/test_alt.fasta \
                            -o "$locator_output"

                        # Check if the MERCI_motif_locator.pl command was successful
                        if [ $? -eq 0 ]; then
                            echo "MERCI_motif_locator.pl script completed successfully for k=${k}, g=${g}, c=${c}, fp=${fp}, fn=${fn}."
                        else
                            echo "Error running MERCI_motif_locator.pl script for k=${k}, g=${g}, c=${c}, fp=${fp}, fn=${fn}."
                        fi

                    else
                        echo "Error running MERCI.pl script for k=${k}, g=${g}, c=${c}, fp=${fp}, fn=${fn}."
                    fi
                done
            done
        done
    done
done

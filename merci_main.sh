#!/bin/bash

# Array of k values for top motifs
top_motif=(50 )

# Array of fp values
fp_values=(10)

# Array of classification types
classifications=("NONE" "KOOLMAN-ROHM")

# Iterate over each classification type
for classification in "${classifications[@]}"
do
  # Set base directory based on the classification type
  base_directory="$classification"

  # Iterate over each motif size
  for k in "${top_motif[@]}"
  do
    # Iterate over each fp value
    for fp in "${fp_values[@]}"
    do
      echo "Processing motifs for classification=$classification, k=$k, fp=$fp"

      # Create a folder for the current classification type and fp value
      folder_name="${base_directory}/fp${fp}_results"
      mkdir -p "$folder_name"

      # Run the first command for the positive motifs with classification type
      echo "Running MERCI.pl with -k $k -fp $fp -c $classification -o $folder_name/motifs_${k}_fp${fp}_${classification}"
      perl MERCI.pl -p /Users/anandr/Downloads/Neurotoxic_peptide_prediction/Data/pos_train_alt.fasta -n /Users/anandr/Downloads/Neurotoxic_peptide_prediction/Data/neg_train_alt.fasta -k $k -fp $fp -c $classification -o "$folder_name/motifs_${k}_fp${fp}_${classification}" &
      wait

      # Check if the motifs file exists before proceeding
      if [ ! -f "$folder_name/motifs_${k}_fp${fp}_${classification}" ]; then
        echo "Motifs file does not exist: $folder_name/motifs_${k}_fp${fp}_${classification}"
        continue
      fi

      # Locate the motifs for the test sequences (positive)
      echo "Running MERCI_motif_locator.pl with -i $folder_name/motifs_${k}_fp${fp}_${classification} -c $classification -o $folder_name/locator_${k}_fp${fp}_${classification}_npp"
      perl MERCI_motif_locator.pl -p /Users/anandr/Downloads/Neurotoxic_peptide_prediction/Data/test_alt.fasta -i "$folder_name/motifs_${k}_fp${fp}_${classification}" -c $classification -o "$folder_name/locator_${k}_fp${fp}_${classification}_npp" &
      wait

      # Run the second command for the negative motifs with classification type
      echo "Running MERCI.pl for negative motifs with -k $k -fp $fp -c $classification -o $folder_name/motifs_${k}_fp${fp}_${classification}_npn"
      perl MERCI.pl -p /Users/anandr/Downloads/Neurotoxic_peptide_prediction/Data/neg_train_alt.fasta -n /Users/anandr/Downloads/Neurotoxic_peptide_prediction/Data/pos_train_alt.fasta -k $k -fp $fp -c $classification -o "$folder_name/motifs_${k}_fp${fp}_${classification}_npn" &
      wait

      # Check if the negative motifs file exists before proceeding
      if [ ! -f "$folder_name/motifs_${k}_fp${fp}_${classification}_npn" ]; then
        echo "Negative motifs file does not exist: $folder_name/motifs_${k}_fp${fp}_${classification}_npn"
        continue
      fi

      # Locate the motifs for the test sequences (negative)
      echo "Running MERCI_motif_locator.pl for negative motifs with -i $folder_name/motifs_${k}_fp${fp}_${classification}_npn -c $classification -o $folder_name/locator_${k}_fp${fp}_${classification}_npn"
      perl MERCI_motif_locator.pl -p /Users/anandr/Downloads/Neurotoxic_peptide_prediction/Data/test_alt.fasta -i "$folder_name/motifs_${k}_fp${fp}_${classification}_npn" -c $classification -o "$folder_name/locator_${k}_fp${fp}_${classification}_npn" &
      wait

      echo "Finished processing motifs for classification=$classification, k=$k, fp=$fp"
    done
  done
done

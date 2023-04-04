#!/bin/bash

# Filenames used for input and output
INPUT_FILE=$(gum input \
    --header="Input file name (within ./data)" \
    --value="30S_20220101-20230101.tif"
)

OUTPUT_FILE=$(gum input \
    --header="Output file name (within ./data)" \
    --value="30S_20220101-20230101_quadbin.tif"
)

INPUT_PATH="./data/$INPUT_FILE"
OUTPUT_PATH="./data/$OUTPUT_FILE"

# Google Cloud variables
GCP_PROJECT=$(gum input \
    --header="Google Cloud Platform project to upload the data" \
    --value="cartodb-on-gcp-datascience"
)

GCP_DATASET=$(gum input \
    --header="Google Cloud Platform dataset to upload the data" \
    --value="environmental_scoring"
)

GCP_TABLE=$(gum input \
    --header="Google Cloud Platform table to upload the data" \
    --value="30S_20220101-20230101_quadbin"
)

echo "Input file: $INPUT_PATH"
echo "Output file: $OUTPUT_PATH"

# # Loading process
# gdalwarp "$INPUT_PATH" \
#     -of COG \
#     -co COMPRESS=DEFLATE \
#     -co TILING_SCHEME=GoogleMapsCompatible \
#     -tr 1000 1000 \
#     "$OUTPUT_PATH" 

carto bigquery upload \
    --file_path "$OUTPUT_PATH" \
    --project "$GCP_PROJECT" \
    --dataset "$GCP_DATASET" \
    --table "$GCP_TABLE" \
    --output_quadbin

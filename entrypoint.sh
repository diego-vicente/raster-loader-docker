#!/bin/bash

# Filenames used for input and output
INPUT_FILE=$(gum input \
    --header="Input file name (within ./data)" \
    --value="land_cover_urls.txt"
)

INPUT_PATH="./data/$INPUT_FILE"

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
    --value="land_cover_raster"
)

# Loop the URL text file and download each file
while read -r url; do
    echo "Downloading from $url..."

    # TODO: no reason to assume it will be tif
    curl -o "./data/tmp_file.tif" "$url"

    # Reproject the file
    gdalwarp "./data/tmp_file.tif" \
        -of COG \
        -co COMPRESS=DEFLATE \
        -co TILING_SCHEME=GoogleMapsCompatible \
        -tr 1000 1000 \
        -r mode \
        ./data/tmp_file_reprojected.tif


    # Upload the file to BigQuery - we say yes to append
    echo "yes" | carto bigquery upload \
        --file_path ./data/tmp_file_reprojected.tif \
        --project "$GCP_PROJECT" \
        --dataset "$GCP_DATASET" \
        --table "$GCP_TABLE" \
        --output_quadbin

    # Remove the file
    rm ./data/tmp_file.tif ./data/tmp_file_reprojected.tif
        
    echo "Done with $url"

done <"$INPUT_PATH"

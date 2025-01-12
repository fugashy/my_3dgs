#!/bin/bash
# argument
readonly input_video_path=$1

# Constants for quality
readonly image_width=1920
readonly fps=5
readonly iteration=3000

# init workspace
readonly output_path=/tmp/out
rm -rf ${output_path}

# extract images from input video file
readonly images_path=${output_path}/images
mkdir -p ${images_path}
ffmpeg \
  -i ${input_video_path} \
  -vf fps=${fps},scale=${image_width}:-1 \
  ${images_path}/image_%04d.png

# extract features in each images
readonly colmap_path=${output_path}/colmap
readonly distored_path=${output_path}/colmap/distorted
mkdir -p ${colmap_path}/distorted
colmap feature_extractor \
  --image_path ${images_path} \
  --database_path ${distored_path}/database.db \
  --ImageReader.single_camera 1 \
  --ImageReader.camera_model PINHOLE

# match feature points for build graph
colmap exhaustive_matcher \
  --database_path ${distored_path}/database.db

# build map
readonly sparse_path=${distored_path}/sparse
mkdir -p ${sparse_path}
colmap mapper \
  --image_path ${images_path}/ \
  --database_path ${distored_path}/database.db \
  --output_path ${sparse_path} \
  --Mapper.ba_global_function_tolerance=0.000001

# undistort image
readonly undistorted_path=${colmap_path}/undistorted
mkdir -p ${undistorted_path}
colmap image_undistorter \
  --image_path ${images_path} \
  --input_path ${sparse_path}/0 \
  --output_path ${undistorted_path} \
  --output_type COLMAP

# create 3D gaussian then output it as a ply file
cd ${sparse_path}/0
ln -s ${undistorted_path}/images .
cd -
cd OpenSplat/build && ./opensplat ${sparse_path}/0 -n ${iteration}
cd -

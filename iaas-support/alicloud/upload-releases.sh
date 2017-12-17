#!/usr/bin/env bash

#============ get the file name ===========
Folder_A=$1

# upload cf release
for file_a in ${Folder_A}/*; do
    temp_file=`basename $file_a`
    if [[ $temp_file == *.tgz ]]; then
        bosh -e my-bosh upload-release $1/$temp_file
    fi
done

# update cf buildpack
BUILDPACK_OSS=http://cf-buildpacks.oss-cn-hangzhou.aliyuncs.com

cf update-buildpack staticfile_buildpack -p $BUILDPACK_OSS/staticfile_buildpack-cached-v1.4.18.zip -i 1
cf update-buildpack java_buildpack -p $BUILDPACK_OSS/java-buildpack-offline-dad1000.zip -i 2
cf update-buildpack ruby_buildpack -p $BUILDPACK_OSS/ruby_buildpack-cached-v1.7.5.zip -i 3
cf update-buildpack dotnet_core_buildpack -p $BUILDPACK_OSS/dotnet-core_buildpack-cached-v1.0.31.zip -i 4
cf update-buildpack nodejs_buildpack -p $BUILDPACK_OSS/nodejs_buildpack-cached-v1.6.11.zip -i 5
cf update-buildpack go_buildpack -p $BUILDPACK_OSS/go_buildpack-cached-v1.8.13.zip -i 6
cf update-buildpack python_buildpack -p $BUILDPACK_OSS/python_buildpack-cached-v1.6.2.zip -i 7
cf update-buildpack php_buildpack -p $BUILDPACK_OSS/php_buildpack-cached-v4.3.44.zip -i 8
cf update-buildpack binary_buildpack -p $BUILDPACK_OSS/binary_buildpack-cached-v1.0.15.zip -i 9
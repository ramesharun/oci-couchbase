#!/usr/bin/env bash

# Builds mkpl .zip for ORM. Uses local copy of existing TF.
# Replaces: image_variables.tf
# Adds: schema_paid.yaml
# Output: $out_file

out_file="mkpl_paid.zip"
schema="schema_paid.yaml"
variables="image-variables-paid.tf"

echo "TEST cleanup"
rm -rf ./tmp_package
rm -f $out_file

# set after cleanup, since failure of that rm is ok
set -euo

echo "Creating tmp dir...."
mkdir ./tmp_package

echo "Copying .tf files to tmp dir...."
cp -v ../simple/*.tf ./tmp_package
echo "Copying script directory to tmp dir...."
cp -rv ../scripts ./tmp_package

echo "Removing provider.tf...."
rm ./tmp_package/provider.tf
echo "Removing image_variables.tf...."
rm ./tmp_package/image_variables.tf

echo "Adding $schema..."
cp $schema ./tmp_package
echo "Adding $variables..."
cp $variables ./tmp_package

# Required path change since schema.yaml forces working directory to be
# root of .zip
sed -i '' "s:file(\"../scripts/server.sh\"):file(\"./scripts/server.sh\"):g" ./tmp_package/server.tf
sed -i '' "s:file(\"../scripts/disks.sh\"):file(\"./scripts/disks.sh\"):g" ./tmp_package/server.tf
sed -i '' "s:file(\"../scripts/syncgateway.sh\"):file(\"./scripts/syncgateway.sh\"):g" ./tmp_package/syncgateway.tf

# Add latest git log entry
git log -n 1 > tmp_package/git.log

echo "Creating $out_file ...."
cd tmp_package
zip -r $out_file *
cd ..
mv tmp_package/$out_file ./

echo "Deleting tmp dir...."
rm -rf ./tmp_package

#!/bin/bash

echo "Building TAR"
mkdir -p villages_is_villages
cp *.nut villages_is_villages
cp readme.txt villages_is_villages
cp changelog.txt villages_is_villages
cp -r lang villages_is_villages
tar -c villages_is_villages > villages_is_villages.tar

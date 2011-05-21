#!/bin/sh

# helper script to copy over all the resources

if [ $# -ne 1 ]
then
  echo "Usage: `basename $0` ANDROID_RES_DIR"
  exit 1
fi

TO_DIR=$1

for dir in generated/*;
do
  if [ -d $dir ];
  then
    name=${dir:10}
    DEST_DIR=${TO_DIR}/$name
    # check if this dest dir exists
    if [ ! -e ${DEST_DIR} ];
    then
      echo "Creating resource directory ${DEST_DIR}"
      mkdir ${DEST_DIR}
    fi
    
    echo "Copying contets of ${name}"
    cp ${dir}/* ${DEST_DIR}
  fi
done

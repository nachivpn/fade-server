#!/bin/bash

#5 args:
#tar name
#python file name
#python file name

#untar
#call pip on package name
#python on the python file

### validation
if [ $# -ne 5 ]; then
    echo "Script requires 5 args:"
    echo "example: bash $0 fade-1.0.tar main.py module_name in.ser out.ser"
    exit
fi

TAR_NAME=$1
echo $TAR_NAME
PY_FILE_TO_EXEC=$2

### untar
PY_PACKAGE_NAME=`echo $TAR_NAME | sed "s/-[0-9]\+.[0-9]\+.tar//g"`_dir
echo $PY_PACKAGE_NAME

# Extract "something-1.0.tar" into "something" (without 1.0...)
rm -rf $PY_PACKAGE_NAME
mkdir $PY_PACKAGE_NAME
tar -xvf $TAR_NAME -C ./$PY_PACKAGE_NAME
#tar xf $TAR_NAME

### deps
#source ./venv/bin/activate
#python3 -m pip install -e "./$PY_PACKAGE_NAME"

### run the job!
# Get rid of first three arguments of this script to pass all of the remaining to main.py
shift
shift
python3 "./$PY_PACKAGE_NAME/$PY_FILE_TO_EXEC" $@


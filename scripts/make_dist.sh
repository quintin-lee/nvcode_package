#!/bin/bash
PACKAGE_NAME="nvcode_$(date +'%Y%m%d-%H%M').run"
TAR_NAME=nvcode_$(date +'%Y%m%d-%H%M').tar.gz
SCRIPT_PATH=$(readlink -f $0)
SCRIPT_DIR=$(dirname $SCRIPT_PATH)

file_list="bin/* config/* fonts/* share/* state/* README.md"

pushd ${SCRIPT_DIR}/..
tar zcvf nvcode.tar.gz ${file_list}
tar zcvf ${TAR_NAME} nvcode.tar.gz scripts/install.sh scripts/install_fonts.sh
popd

pushd ${SCRIPT_DIR}
cp setup.sh ${PACKAGE_NAME}
popd

cat ${SCRIPT_DIR}/../${TAR_NAME} >> ${SCRIPT_DIR}/${PACKAGE_NAME}

rm -f ${SCRIPT_DIR}/../${TAR_NAME}
rm -f ${SCRIPT_DIR}/../nvcode.tar.gz

chmod +x ${SCRIPT_DIR}/${PACKAGE_NAME}



#!/bin/bash

function check_file {
    file="$1"
    if [[ ! -f $file ]]; then
        echo "Error: File not found"
    fi
}

if [[ $# -lt 1 ]]; then
    echo "Error: Must give ONE argument, the directory containing the release files that were uploaded"
    exit 1
fi

filedir="$1"

if [[ ! -d "${filedir}" ]]; then
    echo "Error: ${filedir} is not a directory"
    exit 1
fi

BASE_DOWNLOAD_URL=https://github.com/Hopsan/hopsan/releases/download

pushd "$filedir"

VERSION=$(ls ./*.deb | head -n1 | cut -d_ -f2)
if [[ "$VERSION" == "" ]]; then
    echo "Error: Could not parse version info from a deb file"
    exit 1
fi

TAG=v$(echo ${VERSION} | cut -d. -f1,2,3)

URL=https://github.com/Hopsan/hopsan/releases/tag/${TAG}

win32_inst=$(ls Hopsan-*-win32-installer*)
win32_inst_comp=$(ls Hopsan-*-win32-with_compiler-installer*)
win64_inst=$(ls Hopsan-*-win64-installer*)
win64_inst_comp=$(ls Hopsan-*-win64-with_compiler-installer*)

check_file ${win32_inst}
check_file ${win32_inst_comp}
check_file ${win64_inst}
check_file ${win64_inst_comp}

WIN32_INST_URL=${BASE_DOWNLOAD_URL}/${TAG}/${win32_inst}
WIN32_INST_SHA=$(sha256sum ${win32_inst} | cut -d' ' -f1)

WIN64_INST_URL=${BASE_DOWNLOAD_URL}/${TAG}/${win64_inst}
WIN64_INST_SHA=$(sha256sum ${win64_inst} | cut -d' ' -f1)

WIN32_INST_COMP_URL=${BASE_DOWNLOAD_URL}/${TAG}/${win32_inst_comp}
WIN32_INST_COMP_SHA=$(sha256sum ${win32_inst_comp} | cut -d' ' -f1)

WIN64_INST_COMP_URL=${BASE_DOWNLOAD_URL}/${TAG}/${win64_inst_comp}
WIN64_INST_COMP_SHA=$(sha256sum ${win64_inst_comp} | cut -d' ' -f1)

popd

sed -e "/<\!--NEW_RELEASE_PLACEHOLDER-->/a \\
    \<release\>\\
      \<version\>${VERSION}\</version>\\
      \<url\>${URL}\</url\>\\
      \<win64_installer_with_compiler sha256=\"${WIN64_INST_COMP_SHA}\"\>${WIN64_INST_COMP_URL}\</win64_installer_with_compiler\>\\
      \<win64_installer_wo_compiler sha256=\"${WIN64_INST_SHA}\"\>${WIN64_INST_URL}\</win64_installer_wo_compiler\>\\
      \<win32_installer_with_compiler sha256=\"${WIN32_INST_COMP_SHA}\"\>${WIN32_INST_COMP_URL}\</win32_installer_with_compiler\>\\
      \<win32_installer_wo_compiler sha256=\"${WIN32_INST_SHA}\"\>${WIN32_INST_URL}\</win32_installer_wo_compiler\>\\
    \</release\>" -i hopsan_releases.xml

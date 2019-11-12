#!/bin/bash

export CMAKE="cmake"
export SUDO="sudo"
export InstallCommand=""
export OsName=""

function ubuntu_ccls()
{
    git clone  --recursive https://github.com/MaskRay/ccls
    cd ccls && git checkout 2b552f6
    CURR_DIR=`pwd`
    wget -c http://releases.llvm.org/9.0.0/clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz
    tar xf clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz
    ${CMAKE} -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_PREFIX_PATH=${CURR_DIR}/clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04
    cd Release
    make -j`nproc` 
    ln -sf `pwd`/ccls $HOME/bin/ccls
}

function centos_ccls()
{
    ${SUDO} yum whatprovides *bin/which
    ${InstallCommand} epel-release 
    ${InstallCommand} centos-release-scl
    ${InstallCommand} devtoolset-8
 
    source /opt/rh/devtoolset-8/enable
    CURR_DIR=`pwd`
    LLVM_INSTALL_DIR="/usr/local/llvm"

    ${InstallCommand} cmake3
    GCC_DIR=`which gcc`
    G_DIR=`which g++`

    git clone  --depth=1 https://git.llvm.org/git/llvm.git ${CURR_DIR}/llvm
    git clone  --depth=1 https://git.llvm.org/git/clang.git ${CURR_DIR}/llvm/tools/clang

    cd ${CURR_DIR}/llvm
     
    ${CMAKE} -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DLLVM_TARGETS_TO_BUILD=X86 -DCMAKE_CXX_COMPILER=${G_DIR} -DCMAKE_C_COMPILER=${GCC_DIR} -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_DIR} -DLLVM_ENABLE_RTTI=ON
     
    cd Release

    make -j`nproc` 

    cd ${CURR_DIR}

    git clone --depth=1 --recursive https://github.com/MaskRay/ccls ${CURR_DIR}/ccls
    cd ccls
    ${CMAKE} -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_RTTI=ON -DCMAKE_CXX_COMPILER=${G_DIR} -DSYSTEM_CLANG=ON -DCMAKE_PREFIX_PATH="${CURR_DIR}/llvm/Release;${CURR_DIR}/llvm/Release/tools/clang;${CURR_DIR}/llvm;${CURR_DIR}/llvm/tools/clang"

    cd Release

    make -j`cat /proc/cpuinfo |grep "processor"|wc -l` 

    ln -sf `pwd`/ccls $HOME/bin/ccls
    cd ${CURR_DIR}
    exit
}


function main()
{
    if [ ${OsName} == "centos" ]; then
        echo ""
        centos_ccls
    elif [ ${OsName} == "ubuntu" ];then
        echo ""
        ubuntu_ccls
    else
        echo "not support platform OsName: "${OsName}
    fi
}

. help.sh
main


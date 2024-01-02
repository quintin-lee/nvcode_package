#!/bin/bash

main()
{
    #创建一个临时目录，用于存放解压文件
    export TMPDIR=`mktemp -d /tmp/tmp.XXXX.$$`
    
    #获取__ARCHIVE_BELOW__的下一行的行数放在ARCHIVE变量上，即install.tar.gz数据的开始行
    ARCHIVE=$(awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0;}' $0)
    
    #定位到行尾，即install.tar.gz数据的开始行到行尾的完整数据，然后通过管道传给tar进行解压到临时目录
    tail -n+$ARCHIVE $0 | tar xz -C $TMPDIR
    
    #保存当前目录
    CDIR=`pwd`
    
    #进入到临时目录并执行压缩包内的可执行程序
    cd $TMPDIR
    bash scripts/install.sh $@
    
    #跳回先前目录，删除临时目录
    cd $CDIR && rm -rf $TMPDIR

    exit 0
}
main $@

# This line must be the last line of the file
__ARCHIVE_BELOW__

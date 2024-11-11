#!/bin/bash
PRGDIR=`dirname "$0"`
export MICDN_HOME=`cd "$PRGDIR" >/dev/null; pwd`
version=`grep "version " -R dub.sdl |awk 'NR==1{gsub(/"/,"");print $2}'`

mk_artifact(){
  cd $1
  arch=`arch`
  targetName=`grep "targetName " -R dub.sdl |awk 'NR==1{gsub(/"/,"");print $2}'`
  rm -rf target/$targetName-$version-$arch.bin
  mv target/$targetName target/$targetName-$version-$arch.bin
  sha1sum target/$targetName-$version-$arch.bin|awk 'NR==1{gsub(/"/,"");print $1}'>> target/$targetName-$version-$arch.bin.sha1
  mkdir -p ~/.m2/repository/org/beangle/task/$targetName/$version/
  rm -rf ~/.m2/repository/org/beangle/task/$targetName/$version/$targetName-$version-$arch.bin
  cp target/$targetName-$version-$arch.bin ~/.m2/repository/org/beangle/task/$targetName/$version/$targetName-$version-$arch.bin
  cp target/$targetName-$version-$arch.bin.sha1 ~/.m2/repository/org/beangle/task/$targetName/$version/$targetName-$version-$arch.bin.sha1
  cd ..
}

dub clean
dub build --build=release-nobounds --compiler=ldc2
mk_artifact "agent"
mk_artifact "server"

cd $MICDN_HOME
rm -rf target
mkdir -p target

cd ~/.m2/repository
zip  $MICDN_HOME/target/beangle-task-$version.$arch.zip org/beangle/task/beangle-task-agent/$version/beangle-task-agent-$version-$arch.bin \
org/beangle/task/beangle-task-agent/$version/beangle-task-agent-$version-$arch.bin.sha1 \
org/beangle/task/beangle-task-server/$version/beangle-task-server-$version-$arch.bin \
org/beangle/task/beangle-task-server/$version/beangle-task-server-$version-$arch.bin.sha1

gpg -ab $MICDN_HOME/target/beangle-task-$version.$arch.zip

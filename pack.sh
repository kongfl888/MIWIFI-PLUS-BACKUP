#!/bin/sh

for i in arm1 arm2 mipsel1 mipsel2
do
	echo "开始打包$i..."
	cd "$i"/
	[ -f yuneon.tar.gz ] && mv -f yuneon.tar.gz yuneon.tar.gz.bak
	tar cvf yuneon.tar.gz yuneon/
	cd ..
done

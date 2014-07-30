#!/bin/sh

# Script to create a minimal Cydia Repository for Mac OS X
# https://github.com/bitst0rm/RepoMaker
# Copyright (c) 2014 bitst0rm <bitst0rm@users.noreply.github.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

TOP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMP_DIR=${TOP_DIR}/DEBIAN
REL_DIR=${TOP_DIR}/UPLOAD
DEB_DIR=${REL_DIR}/debs
prefix="cydia."

mkdir -p "$TMP_DIR"
mkdir -p "$DEB_DIR"
cd "$TOP_DIR"

# Edit the control file of deb packages
echo "Editing the control file..."
for i in *.deb
do
	for FILE in $(ar -t "$i")
	do
		case "$FILE" in
			control.tar) TYPE="control.tar";;
			control.tar.gz) TYPE="control.tar.gz";;
			control.tar.bz2) TYPE="control.tar.bz2";;
			control.tar.xz) TYPE="control.tar.xz";;
			control.tar.lzma) TYPE="control.tar.lzma";;
		esac
	done

# decompress the control archive
ar -p "$i" $TYPE | tar -zxf - -C "$TMP_DIR"
cd "$TMP_DIR"

$(grep -q "Package: $prefix" control)
if [ $? -eq 1 ]; then
	# edit the control file
	sed -i '' "s/Package: /Package: $prefix/" control
	# compress the control file
	find . -name ".DS_Store" -delete
	tar -zcf $TYPE *
	# replace the control archive in the deb with a new one:
	cp "$TOP_DIR/$i" "$DEB_DIR/$i"
	ar -r "$DEB_DIR/$i" $TYPE
else
	cp "$TOP_DIR/$i" "$DEB_DIR/$i"
fi

# clean up
rm -rf *
cd "$TOP_DIR"
done
rmdir "$TMP_DIR"
cd "$REL_DIR"

# Get dpkg-deb for Mac OS X
echo "Checking for dpkg-deb..."
if [ -z "$(type -P dpkg-deb)" ]; then
	echo "Downloading dpkg-deb..."
	curl -O http://test.saurik.com/francis/dpkg-deb-fat
	chmod a+x dpkg-deb-fat
	echo ""
	echo "Installing dpkg-deb..."
	sudo mkdir -p /usr/local/bin
	sudo mv dpkg-deb-fat /usr/local/bin/dpkg-deb
	if [ -z "$(type -P dpkg-deb)" ]; then
		echo "Fatal: Could not install dpkg-deb."
		exit 1;
	fi
fi

echo "Creating packages lists..."
$TOP_DIR/dpkg-scanpackages debs . | gzip -c9 > Packages.gz 2>/dev/null
$TOP_DIR/dpkg-scanpackages debs . | bzip2 -c9 > Packages.bz2 2>/dev/null
cp -f $TOP_DIR/Release Release
cp -f $TOP_DIR/CydiaIcon.png CydiaIcon.png
echo "Done."

exit 0;

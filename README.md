# RepoMaker
This script will modify the control file of your _already_ existing deb packages to create a minimal Cydia Repository for Mac OS X. It does not create package signatures nor make deb packages from scratch for you.

Build
-----
```Bash
git clone --recursive https://github.com/bitst0rm/RepoMaker.git
cd RepoMaker
# Place all your deb packages here.
sh build.sh
```

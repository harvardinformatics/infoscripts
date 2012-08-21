#!/bin/sh

# --------------------------------------------------------
#
# File:         HighRoller Build Script
# Author:       jmaclabs
# Date:         9/21/11
# Version:      1.0.0
# Description:  build script for creating HighRoller
#               download package
#
# Licensed to Gravity.com under one or more contributor license agreements.
# See the NOTICE file distributed with this work for additional information
# regarding copyright ownership.  Gravity.com licenses this file to you use
# under the Apache License, Version 2.0 (the License); you may not this
# file except in compliance with the License.  You may obtain a copy of the
# License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an AS IS BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# --------------------------------------------------------

# ---- TEST FOR USER PROVIDED VERSION

if test "$1" == ""
then
  echo
  echo "\tHighRoller build.sh - You must provide a build number (i.e. 1.0.0) as a command-line argument"
  echo
  exit
else
  echo
  echo "\tHighRoller Packager...building..."
  echo
fi

# ---- CLEAN UP & SETUP

VERSION=$1
DATE=`date`
CR=`date "+%Y"`

rm -fdr ../build/HighRoller_$VERSION
rm -fdr ../releases/HighRoller_$VERSION.zip
mkdir ../build/HighRoller_$VERSION

# ---- CREATE NEW HIGHROLLER PACKAGE

echo "\tCreating package..."
echo
echo "<?php" > ../build/HighRoller_$VERSION/HighRoller.php
echo " /*" >> ../build/HighRoller_$VERSION/HighRoller.php
echo " * HighRoller -- PHP wrapper for the popular JS charting library Highcharts" >> ../build/HighRoller_$VERSION/HighRoller.php
echo " * Author:       jmaclabs@gmail.com" >> ../build/HighRoller_$VERSION/HighRoller.php
echo " * File:         HighRoller.php" >> ../build/HighRoller_$VERSION/HighRoller.php
echo " * Date:         $DATE" >> ../build/HighRoller_$VERSION/HighRoller.php
echo " * Version:      $VERSION" >> ../build/HighRoller_$VERSION/HighRoller.php
echo " *" >> ../build/HighRoller_$VERSION/HighRoller.php
echo " * Licensed to Gravity.com under one or more contributor license agreements." >> ../build/HighRoller_$VERSION/HighRoller.php
echo " * See the NOTICE file distributed with this work for additional information" >> ../build/HighRoller_$VERSION/HighRoller.php
echo " * regarding copyright ownership.  Gravity.com licenses this file to you use" >> ../build/HighRoller_$VERSION/HighRoller.php
echo " * under the Apache License, Version 2.0 (the "License"); you may not this" >> ../build/HighRoller_$VERSION/HighRoller.php
echo " * file except in compliance with the License.  You may obtain a copy of the" >> ../build/HighRoller_$VERSION/HighRoller.php
echo " * License at " >> ../build/HighRoller_$VERSION/HighRoller.php
echo " *" >> ../build/HighRoller_$VERSION/HighRoller.php
echo " *    http://www.apache.org/licenses/LICENSE-2.0" >> ../build/HighRoller_$VERSION/HighRoller.php
echo " *" >> ../build/HighRoller_$VERSION/HighRoller.php
echo " * Unless required by applicable law or agreed to in writing, software" >> ../build/HighRoller_$VERSION/HighRoller.php
echo " * distributed under the License is distributed on an "AS IS" BASIS," >> ../build/HighRoller_$VERSION/HighRoller.php
echo " * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied." >> ../build/HighRoller_$VERSION/HighRoller.php
echo " * See the License for the specific language governing permissions and" >> ../build/HighRoller_$VERSION/HighRoller.php
echo " * limitations under the License." >> ../build/HighRoller_$VERSION/HighRoller.php
echo " *" >> ../build/HighRoller_$VERSION/HighRoller.php
echo " */" >> ../build/HighRoller_$VERSION/HighRoller.php
echo "?>" >> ../build/HighRoller_$VERSION/HighRoller.php

# ---- APPEND PHP SRC

echo "\tAppending source..."
echo
cat ../src/lib/* >> ../build/HighRoller_$VERSION/HighRoller.php

# ---- ADD CHART TYPE SUBCLASSES

echo "\tIncluding subclasses..."
echo
cp ../src/*.php ../build/HighRoller_$VERSION/.

# ---- COMPRESS PACKAGE

echo "\tCompressing..."
echo
cd ../build
zip -r ../releases/HighRoller_$VERSION.zip HighRoller_$VERSION/
cp -r HighRoller_$VERSION/ ../test/_assets/HighRoller/

# ---- DUNZO
DATE=`date`
echo
echo "\t...Done!"
echo
echo "\tHighRoller $VERSION build completed on $DATE"
echo


echo
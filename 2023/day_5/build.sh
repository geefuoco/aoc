#!/usr/bin/sh

set -xe

kotlinc main2.kt -include-runtime -d main2.jar

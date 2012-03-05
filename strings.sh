#!/bin/bash

for file in tottepost/*.lproj/Localizable.strings; do
  twine generate-string-file strings.txt $file --tags=common --encoding utf-16
done

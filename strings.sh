#!/bin/bash

for file in tottepost/Resources/Localizations/*.lproj/Localizable.strings; do
  twine generate-string-file tottepost/Resources/Localizations/strings.txt $file --tags=common --encoding utf-16
done

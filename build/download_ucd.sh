#!/bin/sh

CURL=curl
for FILE in $*
do
	UCD_FILE=$(echo _${FILE} | sed -e 's/\(_\([a-zA-Z]\)\)/\U\2/g')
	UCD_URL=http://www.unicode.org/Public/UCD/latest/ucd/${UCD_FILE}
	echo Downloading ${UCD_URL}
	${CURL} --silent -z ${FILE} -o ${FILE} ${UCD_URL}
done

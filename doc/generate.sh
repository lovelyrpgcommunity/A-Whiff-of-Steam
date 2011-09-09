#!/bin/bash

# generate revision number
echo "<?xml version='1.0' encoding='UTF-8'?>" > revision.data
git log -1 --pretty=format:"<pubsnumber>Rev: %h</pubsnumber>" >> revision.data

# generate history data
echo "<?xml version='1.0' encoding='UTF-8'?>" > history.data
echo "<revhistory>" >> history.data
git log --reverse --pretty=format:"<revision><revnumber>%h</revnumber><date>%ai</date><authorinitials>%cN</authorinitials><revdescription><para>%s</para></revdescription></revision>" | \
  sed "s/<authorinitials>bartbes<\/authorinitials>/<authorinitials>Bart van Strien<\/authorinitials>/g" | \
  sed "s/<authorinitials>root<\/authorinitials>/<authorinitials>William Bowers<\/authorinitials>/g" | \
  sed "s/&/&amp;/g"  >> history.data
echo "</revhistory>" >> history.data


#!/bin/bash

#cat community_operator_index.json |jq ' select( .schema == "olm.bundle" ) | { "name": .name, "obj": .properties[] } | select( .obj.type == "olm.bundle.object" ) | { name: .name, obj: .obj.value.data } ' | tr -d '{}'  | while read line; do if $(echo $line | grep obj >/dev/null 2>/dev/null ); then echo $line | sed 's/.* //' | tr -d '"' | base64 -d - | jq ' select( .kind == "ClusterServiceVersion") | { modes: .spec.installModes[] } | select( .modes.type == "AllNamespaces" ) | select( .modes.supported == true )'; else echo $line; fi ; done | grep "AllNamespaces" -B 4 -A 2

# filter all bundle versions supporting AllNamespaces from a rendered json file containing community operator index contents
cat community_operator_index.json |jq ' select( .schema == "olm.bundle" ) | { "obj": .properties[] } | select( .obj.type == "olm.bundle.object" ) | { obj: .obj.value.data } ' | tr -d '{}'  | while read line; do if $(echo $line | grep obj >/dev/null 2>/dev/null ); then echo $line | sed 's/.* //' | tr -d '"' | base64 -d - | jq ' select( .kind == "ClusterServiceVersion") | { name: .metadata.name, modes: .spec.installModes[] } | select( .modes.type == "AllNamespaces" ) | select( .modes.supported == true ) | { name: .name }' | tr -d '{}' ;  fi ; done


# query to also list all dependencies for bundles supporting AllNamespaces
cat community_operator_index.json |jq ' select( .schema == "olm.bundle" ) | { "obj": .properties[] } | select( .obj.type == "olm.bundle.object" ) | { obj: .obj.value.data } ' | tr -d '{}'  | while read line; do if $(echo $line | grep obj >/dev/null 2>/dev/null ); then echo $line | sed 's/.* //' | tr -d '"' | base64 -d - | jq ' select( .kind == "ClusterServiceVersion") | { name: .metadata.name, modes: .spec.installModes[], apideps: .spec.apiservicedefinitions.required, crddeps: .spec.customresourcedefinitions.required } | select( .modes.type == "AllNamespaces" ) | select( .modes.supported == true )'  ;  fi ; done 


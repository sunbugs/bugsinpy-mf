#!/bin/bash
projects="$(cat projects.txt)"
v=1
b=0
while getopts ":p:v:b" opt; do
  case ${opt} in
    p )
      projects="$OPTARG"
      ;;
    v )
      v="$OPTARG"
      version=1
      ;;
    b )
      b=1
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))
for project in $projects; do
  num_bugs="$(bugsinpy-info -p "$project" | grep "Number of bugs" | cut -d ':' -f 2 | xargs)"
  if [ "$version" ] && [ "$v" -gt "$num_bugs" ]; then
    echo "Invalid version $v. $project has only $num_bugs versions." 1>&2
    exit 1
  fi
  if [ "$version" ]; then
    num_bugs="$v"
  fi
  if [ "$project" != "$projects" ]; then
    echo "$project,$num_bugs"
  fi
  for ((i=$v; i<=$num_bugs; i++)); do
    if [ $b -eq 0 ]; then
      sha="$(bugsinpy-info -p "$project" -i "$i" | awk '/Revision id/{getline; print}' | xargs)"
    else
      sha="$(bugsinpy-info -p "$project" -i "$i" | awk '/Buggy id/{getline; print}' | xargs)"
    fi
    echo "$sha"
  done
done

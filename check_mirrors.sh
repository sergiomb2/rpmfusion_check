#!/bin/bash

release="rawhide"
rawhide_number=46
#release="46"
#main="skip"
BASE="https://mirrors.rpmfusion.org"

sections=(
  "free"
  "nonfree"
)
archs_all=(
  "x86_64"
  "aarch64"
  "ppc64le"
)
streams=(
  "fedora"
  "fedora-updates-released"
  "fedora-updates-testing"
  "fedora-tainted"
)
streams_rawhide=(
  "fedora-rawhide"
  "fedora-tainted"
)
variants=(
  ""
  "source"
  "debug"
)

check() {
  local repo="$1"
  local arch="$2"

  echo "#######################################################"
  echo "# Repo: $repo&arch=$arch"
  echo "# metalink ${BASE}/metalink?repo=${repo}&arch=${arch}"
  curl -s "${BASE}/metalink?repo=${repo}&arch=${arch}" \
        | grep protocol | sed 's/<[^>]*>//g'  | head -n3
  echo "# mirrorlist ${BASE}/mirrorlist?repo=${repo}&arch=${arch}"
  curl -s "${BASE}/mirrorlist?repo=${repo}&arch=${arch}" \
        | grep http | head -n3
  echo "#######################################################"
  echo " "
}

if [ "$main" = "skip" ]; then
    echo skip
elif [ "$release" = "rawhide" ]; then
  # ----- RAWHIDE -----
  for var in "${variants[@]}"; do
  if [[ "$var" == "source" ]]; then
    archs=("source")
  else
    archs=("${archs_all[@]}")
  fi
  echo "###################"
  echo "# variant: $var"
  echo "###################"
  for arch in "${archs[@]}"; do
    echo "#############"
    echo "# arch: $arch"
    echo "#############"
    for stream in "${streams_rawhide[@]}"; do
      for section in "${sections[@]}"; do

        if [ -z "$var" ]; then
          repo="${section}-${stream}"
        else
          repo="${section}-${stream}-${var}"
        fi

        if [[ "$stream" == "fedora-tainted" ]]; then
            check "$repo-$rawhide_number" "$arch"
        else
            check "$repo" "$arch"
        fi

      done
    done
  done
  done
else
  # ----- FREE + NONFREE -----
  for var in "${variants[@]}"; do
  if [[ "$var" == "source" ]]; then
    archs=("source")
  else
    archs=("${archs_all[@]}")
  fi
  echo "###################"
  echo "# variant: $var"
  echo "###################"
  for arch in "${archs[@]}"; do
    echo "#############"
    echo "# arch: $arch"
    echo "#############"
    for stream in "${streams[@]}"; do
      for section in "${sections[@]}"; do

        if [ -z "$var" ]; then
          repo="${section}-${stream}-${release}"
        else
          repo="${section}-${stream}-${var}-${release}"
        fi

        check "$repo" "$arch"

      done
    done
  done
  done
fi

if [ "$release" = "rawhide" ]; then
  release=$rawhide_number
fi
  # ----- NVIDIA DRIVER -----
  echo "###################"
  echo "# NVIDIA DRIVER"
  echo "###################"
  base="nonfree-fedora-nvidia-driver"
  archs_nvidia=(
    "x86_64"
    "aarch64"
  )
  for var in "${variants[@]}"; do
    if [[ "$var" == "source" ]]; then
      archs=("source")
    else
      archs=("${archs_nvidia[@]}")
    fi
    for arch in "${archs[@]}"; do

      if [ -z "$var" ]; then
        repo="${base}-${release}"
      else
        repo="${base}-${var}-${release}"
      fi

      check "$repo" "$arch"

    done
  done

  # ----- STEAM (x86_64 only) -----
  echo "###################"
  echo "# STEAM "
  echo "###################"
  base="nonfree-fedora-steam"
  archs_steam=(
    "x86_64"
  )
  for var in "${variants[@]}"; do
    if [[ "$var" == "source" ]]; then
      archs=("source")
    else
      archs=("${archs_steam[@]}")
    fi
    for arch in "${archs[@]}"; do

      if [ -z "$var" ]; then
        repo="${base}-${release}"
      else
        repo="${base}-${var}-${release}"
      fi

        check "$repo" "$arch"

    done
  done

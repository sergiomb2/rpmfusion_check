#!/bin/bash

release="44"
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

archs_steam=(
  "x86_64"
)

streams=(
  "fedora"
  "fedora-updates-released"
  "fedora-updates-testing"
  "fedora-tainted"
)

variants=(
  ""
  "debug"
  "source"
)

check() {
  local repo="$1"
  local arch="$2"

  echo "# repo=$repo&arch=$arch"

  for type in mirrorlist metalink; do
    echo "-- $type -- ${BASE}/${type}?repo=${repo}&arch=${arch}"
    if [ "$type" = "metalink" ]; then
      curl -s "${BASE}/${type}?repo=${repo}&arch=${arch}" \
        | grep protocol | head -n3
    else
      curl -s "${BASE}/${type}?repo=${repo}&arch=${arch}" \
        | grep http | head -n3
    fi
  done
}

# ----- FREE + NONFREE -----
for section in "${sections[@]}"; do
  for stream in "${streams[@]}"; do
    for var in "${variants[@]}"; do

      if [ -z "$var" ]; then
        repo="${section}-${stream}-${release}"
      else
        repo="${section}-${stream}-${var}-${release}"
      fi

      if [ "$var" = "source" ]; then
        check "$repo" "source"
      else
        for arch in "${archs_all[@]}"; do
          check "$repo" "$arch"
        done
      fi

    done
  done
done

# ----- NVIDIA DRIVER -----
base="nonfree-fedora-nvidia-driver"
for var in "${variants[@]}"; do

  if [ -z "$var" ]; then
    repo="${base}-${release}"
  else
    repo="${base}-${var}-${release}"
  fi

  if [ "$var" = "source" ]; then
    check "$repo" "source"
  else
    for arch in "${archs_all[@]}"; do
      check "$repo" "$arch"
    done
  fi

done

# ----- STEAM (apenas x86_64) -----
base="nonfree-fedora-steam"
for var in "${variants[@]}"; do

  if [ -z "$var" ]; then
    repo="${base}-${release}"
  else
    repo="${base}-${var}-${release}"
  fi

  if [ "$var" = "source" ]; then
    check "$repo" "source"
  else
    for arch in "${archs_steam[@]}"; do
      check "$repo" "$arch"
    done
  fi

done


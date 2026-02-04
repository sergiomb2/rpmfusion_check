#!/bin/bash

release="rawhide"
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
streams_rawhide=(
  "fedora-rawhide"
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
  curl -s "${BASE}/metalink?repo=${repo}&arch=${arch}" \
        | grep protocol | sed 's/<[^>]*>//g'  | head -n3
  curl -s "${BASE}/mirrorlist?repo=${repo}&arch=${arch}" \
        | grep http | head -n3
  echo "# "
  echo " "
}

# ----- RAWHIDE -----
if [ "$release" = "rawhide" ]; then
  for section in "${sections[@]}"; do
    for stream in "${streams_rawhide[@]}"; do
      for var in "${variants[@]}"; do

        if [ -z "$var" ]; then
          repo="${section}-${stream}"
        else
          repo="${section}-${stream}-${var}"
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
else

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

  # ----- STEAM (x86_64 only) -----
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
fi

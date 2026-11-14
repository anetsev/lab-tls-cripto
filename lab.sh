#!/usr/bin/env bash
# Roda os laboratórios de terminal em sequência: A, B, C e D.
D="$(dirname "$0")"
for L in A B C D; do
  bash "$D/LAB_$L.sh"
  [ "$L" != D ] && { echo; read -r -p "Enter para o próximo laboratório... " _; }
done

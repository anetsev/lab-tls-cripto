#!/usr/bin/env bash
# Lab B e Lab C do Material 15 (TLS na prática), em versão de terminal.
# Uso: bash lab.sh            (usa www.google.com)
#      bash lab.sh www.gov.br (outro site)
SITE="${1:-www.google.com}"
linha() { printf '\n==================== %s ====================\n' "$1"; }

linha "Versão do OpenSSL deste ambiente"
openssl version

linha "Passo 1 · conexão normal com $SITE"
openssl s_client -connect "$SITE:443" -servername "$SITE" -brief < /dev/null 2>&1 | head -20

linha "Passo 2 · forçando TLS 1.2 com $SITE"
openssl s_client -connect "$SITE:443" -servername "$SITE" -tls1_2 -brief < /dev/null 2>&1 | head -20

linha "Passo 3 · tentando TLS 1.0 num servidor de teste (deve falhar)"
openssl s_client -connect tls-v1-0.badssl.com:1010 -servername tls-v1-0.badssl.com -tls1 < /dev/null 2>&1 | tail -5

linha "Lab D · certificados com problema (o que o OpenSSL diz)"
for h in expired.badssl.com wrong.host.badssl.com self-signed.badssl.com untrusted-root.badssl.com; do
  printf '%-28s ' "$h"
  openssl s_client -connect "$h:443" -servername "$h" -verify_hostname "$h" -verify_return_error < /dev/null 2>&1 \
    | grep -m1 -E "verify error|Verification error|Verify return code" || echo "(sem erro de verificação)"
done

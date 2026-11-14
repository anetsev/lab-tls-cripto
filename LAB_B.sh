#!/usr/bin/env bash
# LAB B (slide 36) · o handshake no terminal com OpenSSL
# Uso: bash LAB_B.sh            (usa www.google.com)
#      bash LAB_B.sh www.gov.br
SITE="${1:-www.google.com}"
linha() { printf '\n==================== %s ====================\n' "$1"; }

linha "Versão do OpenSSL deste ambiente"
openssl version

linha "Passo 1 · conexão normal com $SITE"
openssl s_client -connect "$SITE:443" -servername "$SITE" -brief < /dev/null 2>&1 | head -20

linha "Passo 2 · forçando TLS 1.2 com $SITE (compare o nome da cifra)"
openssl s_client -connect "$SITE:443" -servername "$SITE" -tls1_2 -brief < /dev/null 2>&1 | head -20

linha "Passo 3 · tentando TLS 1.0 num servidor de teste (deve falhar)"
openssl s_client -connect tls-v1-0.badssl.com:1010 -servername tls-v1-0.badssl.com -tls1 < /dev/null 2>&1 | tail -5

echo
echo "Ache no resultado: Protocol version, Ciphersuite, Negotiated TLS1.3 group e Verification."
echo "No passo 3: quem recusou o TLS 1.0, o cliente ou o servidor?"

#!/usr/bin/env bash
# LAB A (slide 35) · o que o cadeado do navegador mostra, visto pelo terminal
# O lab A é feito no navegador (F12 ou cadeado). Este script mostra as mesmas informações
# para quem quiser conferir ou não conseguir achar a aba no navegador.
# Uso: bash LAB_A.sh            (usa www.gov.br)
#      bash LAB_A.sh www.google.com
SITE="${1:-www.gov.br}"
SAIDA=$(openssl s_client -connect "$SITE:443" -servername "$SITE" -brief < /dev/null 2>&1)
printf '\nSite: https://%s\n\n' "$SITE"
printf '%-26s %s\n' "Versão do TLS"            "$(echo "$SAIDA" | awk -F': ' '/Protocol version/ {print $2; exit}')"
printf '%-26s %s\n' "Troca de chave (grupo)"   "$(echo "$SAIDA" | awk -F': ' '/Negotiated TLS1.3 group|Server Temp Key/ {print $2; exit}')"
printf '%-26s %s\n' "Cifra"                    "$(echo "$SAIDA" | awk -F': ' '/Ciphersuite/ {print $2; exit}')"
CERT=$(openssl s_client -connect "$SITE:443" -servername "$SITE" < /dev/null 2>/dev/null | openssl x509 -noout -issuer -enddate 2>/dev/null)
printf '%-26s %s\n' "Emissor do certificado"   "$(echo "$CERT" | sed -n 's/^issuer=//p')"
printf '%-26s %s\n' "Válido até"               "$(echo "$CERT" | sed -n 's/^notAfter=//p')"
echo
echo "Compare com o que o seu navegador mostrou. Se o emissor for diferente, alguém pode estar no meio (slide 29)."

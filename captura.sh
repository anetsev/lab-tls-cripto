#!/usr/bin/env bash
# Lab C em versão de terminal: captura o handshake com o tshark (o Wireshark de linha de comando).
# Uso: bash captura.sh                (usa www.gov.br)
#      bash captura.sh www.google.com
SITE="${1:-www.gov.br}"
IFACE="$(ip route | awk '/default/ {print $5; exit}')"
echo "Capturando na interface $IFACE enquanto acessamos https://$SITE ..."
tshark -i "$IFACE" -f "tcp port 443" -w captura.pcapng -a duration:8 >/dev/null 2>&1 &
sleep 2
curl -s -o /dev/null "https://$SITE"
wait
echo
echo "ClientHello e ServerHello capturados (só a parte TLS):"
tshark -r captura.pcapng -Y "tls.handshake.type == 1 || tls.handshake.type == 2" -O tls 2>/dev/null \
  | grep -E "Handshake Type|Server Name:|Cipher Suite:|Supported Version:|Group:|Version: TLS" | head -60
echo
echo "Arquivo salvo: captura.pcapng (baixe pelo menu do Codespaces e abra no Wireshark, se tiver)."

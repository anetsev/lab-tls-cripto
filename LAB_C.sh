#!/usr/bin/env bash
# LAB C (slides 37 e 38) · capturando o handshake com o tshark (o Wireshark do terminal)
# Uso: bash LAB_C.sh                (usa www.gov.br)
#      bash LAB_C.sh www.google.com
SITE="${1:-www.gov.br}"
ARQ="captura_${SITE//./_}.pcapng"
IFACE="$(ip route 2>/dev/null | awk '/default/ {print $5; exit}')"; IFACE="${IFACE:-eth0}"

echo "1) Capturando na interface $IFACE enquanto acessamos https://$SITE ..."
tshark -i "$IFACE" -f "tcp port 443" -w "$ARQ" -a duration:8 >/dev/null 2>&1 &
sleep 2
curl -s -o /dev/null --http1.1 "https://$SITE"
wait
if [ ! -s "$ARQ" ]; then
  echo "A captura não funcionou neste ambiente (falta permissão de rede)."
  echo "Faça o lab C no Wireshark do seu computador ou acompanhe na tela do professor."
  exit 1
fi

campo() {  # campo <filtro> <campo do tshark>
  tshark -r "$ARQ" -Y "$1" -T fields -e "$2" 2>/dev/null | head -1 | tr ',' '\n' | sort -u | paste -sd ',' -
}
CH="tls.handshake.type == 1"; SH="tls.handshake.type == 2"

echo
echo "2) A tabela do slide 38, preenchida com a sua captura:"
printf '%-42s %s\n' "SNI (nome do site, em claro)"            "$(campo "$CH" tls.handshake.extensions_server_name)"
printf '%-42s %s\n' "Quantas suítes o cliente ofereceu"       "$(tshark -r "$ARQ" -Y "$CH" -T fields -e tls.handshake.ciphersuite 2>/dev/null | head -1 | tr ',' '\n' | grep -c .)"
printf '%-42s %s\n' "Grupos oferecidos (supported_groups)"    "$(campo "$CH" tls.handshake.extensions_supported_group)"
printf '%-42s %s\n' "Grupos na key_share do cliente"          "$(campo "$CH" tls.handshake.extensions_key_share_group)"
printf '%-42s %s\n' "Suíte escolhida pelo servidor"           "$(campo "$SH" tls.handshake.ciphersuite)"
printf '%-42s %s\n' "Versão real (supported_versions)"        "$(campo "$SH" tls.handshake.extensions.supported_version)"
printf '%-42s %s\n' "Grupo escolhido pelo servidor"           "$(campo "$SH" tls.handshake.extensions_key_share_group)"
printf '%-42s %s\n' "Versão no cabeçalho do registro"         "$(campo "$CH" tls.record.version) (a pegadinha do slide 38)"
CERTS=$(tshark -r "$ARQ" -Y "tls.handshake.type == 11" 2>/dev/null | wc -l)
printf '%-42s %s\n' "Certificado visível na captura?"         "$([ "$CERTS" -gt 0 ] && echo "sim ($CERTS pacote(s)): conexão TLS 1.2" || echo "não: no TLS 1.3 ele vai cifrado")"
echo
echo "(Os números são os códigos oficiais: 0x11ec = X25519MLKEM768, 0x001d = x25519, 0x0304 = TLS 1.3, 0x1301 = TLS_AES_128_GCM_SHA256.)"
echo
echo "3) Detalhes completos do ClientHello e do ServerHello:  tshark -r $ARQ -Y \"$CH || $SH\" -O tls | less"
echo "   O arquivo $ARQ pode ser baixado (botão direito → Download) e aberto no Wireshark."

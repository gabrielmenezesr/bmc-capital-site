#!/usr/bin/env bash
# Atualiza o sufixo ?v= do CSS e do JS em todas as páginas.
# A versão é a impressão digital (SHA-256, 8 caracteres) do próprio arquivo:
# mudou o arquivo, muda a versão, e o navegador do visitante baixa o novo.
# Rode depois de alterar styles.css ou main.js:
#   bash scripts/atualizar-versao.sh
set -eu
cd "$(dirname "$0")/.."

v_css=$(sha256sum public/assets/css/styles.css | cut -c1-8)
v_js=$(sha256sum public/assets/js/main.js | cut -c1-8)

for arq in public/*.html; do
  sed -i -E \
    -e "s#(/assets/css/styles\.css)\?v=[0-9A-Za-z]+#\1?v=$v_css#g" \
    -e "s#(/assets/js/main\.js)\?v=[0-9A-Za-z]+#\1?v=$v_js#g" \
    "$arq"
done

echo "styles.css?v=$v_css"
echo "main.js?v=$v_js"

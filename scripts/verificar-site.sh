#!/usr/bin/env bash
# Verificação do site antes de publicar.
# Roda como "comando de build" no Workers Builds: se algum item falhar,
# o script sai com erro e a Cloudflare NÃO publica a versão.
# Uso local: bash scripts/verificar-site.sh   (a partir da raiz do repositório)
set -u
cd "$(dirname "$0")/.." || exit 1

PUB="public"
ERROS=0
falha() { echo "ERRO: $*"; ERROS=$((ERROS + 1)); }

PAGINAS="index.html antecipacao-de-recebiveis.html corretora-seguros.html quem-somos.html 404.html"

# 1. Arquivos obrigatórios
for f in $PAGINAS robots.txt sitemap.xml _redirects _headers \
         assets/css/styles.css assets/js/main.js assets/images/favicon/site.webmanifest; do
  [ -f "$PUB/$f" ] || falha "arquivo obrigatório ausente: $PUB/$f"
done

# 2. Configuração de publicação
grep -q '"name": "billowing-term-57ef"' wrangler.jsonc || falha "wrangler.jsonc: nome do Worker diferente de billowing-term-57ef"
grep -q '"directory": "./public"' wrangler.jsonc || falha "wrangler.jsonc: assets.directory deve ser ./public"
grep -q '"not_found_handling": "404-page"' wrangler.jsonc || falha "wrangler.jsonc: not_found_handling deve ser 404-page"

# 3. Nada interno dentro de public/
proibidos=$(find "$PUB" \( -name '*.md' -o -name '.env*' -o -name 'wrangler*' -o -name '*.sh' -o -name '*.ps1' -o -name '.git' \) -print)
[ -z "$proibidos" ] || falha "arquivo interno dentro de public/: $proibidos"

# 4. Estrutura de cada página
for p in $PAGINAS; do
  arq="$PUB/$p"
  [ -f "$arq" ] || continue
  n=$(grep -o '<h1[ >]' "$arq" | wc -l)
  [ "$n" -eq 1 ] || falha "$p: deve ter exatamente 1 <h1> (tem $n)"
  grep -q '<html[^>]*lang="pt-BR"' "$arq" || falha "$p: falta lang=\"pt-BR\""
  grep -q '<title>[^<]' "$arq" || falha "$p: falta <title>"
  grep -q '<meta name="description" content="[^"]' "$arq" || falha "$p: falta meta description"
  if grep -qE '(href|src)="http://' "$arq"; then falha "$p: link inseguro http://"; fi
  sem_rel=$(grep -oE '<a [^>]*target="_blank"[^>]*>' "$arq" | grep -v 'rel="[^"]*noopener' | wc -l)
  [ "$sem_rel" -eq 0 ] || falha "$p: $sem_rel link(s) em nova aba sem rel=noopener"
done

# 5. Todo link e ativo interno aponta para um arquivo que existe
resolve() {
  local u="${1%%[?#]*}"
  [ "$u" = "/" ] && u="/index.html"
  [ -f "$PUB$u" ] || [ -f "$PUB$u.html" ]
}
for p in $PAGINAS; do
  arq="$PUB/$p"
  [ -f "$arq" ] || continue
  refs=$( { grep -oE '(href|src)="/[^/"][^"]*"' "$arq" | sed -E 's/^[a-z]+="//; s/"$//'
            grep -oE '(href|src)="/"' "$arq" | sed -E 's/^[a-z]+="//; s/"$//'
            grep -oE 'srcset="[^"]*"' "$arq" | sed -E 's/^srcset="//; s/"$//' | tr ',' '\n' | awk '{print $1}' | grep '^/'
          } | sort -u )
  for u in $refs; do
    resolve "$u" || falha "$p: link interno quebrado: $u"
  done
done

# 6. Blocos repetidos iguais em todas as páginas
#    O site não tem etapa de montagem: cabeçalho, rodapé e botão de WhatsApp
#    são copiados em cada página. Uma cópia diferente das outras bloqueia a
#    publicação. Diferenças só de espaço e a marcação da página ativa
#    (aria-current) são ignoradas.
normaliza() { tr '\n' ' ' | sed -E 's/ aria-current="page"//g; s/[[:space:]]+/ /g; s/> </></g'; }
for bloco in header footer zap; do
  assinaturas=""
  for p in $PAGINAS; do
    arq="$PUB/$p"
    [ -f "$arq" ] || continue
    case "$bloco" in
      header) trecho=$(tr '\n' ' ' < "$arq" | grep -oE '<header.*</header>') ;;
      footer) trecho=$(tr '\n' ' ' < "$arq" | grep -oE '<footer.*</footer>') ;;
      zap)    trecho=$(tr '\n' ' ' < "$arq" | grep -oE '<a class="bmc-zap".*</a>') ;;
    esac
    [ -n "$trecho" ] || { falha "$p: bloco $bloco não encontrado"; continue; }
    assinaturas="$assinaturas$(printf '%s' "$trecho" | normaliza | md5sum | cut -c1-8) $p"$'\n'
  done
  diferentes=$(printf '%s' "$assinaturas" | awk 'NF{print $1}' | sort -u | wc -l)
  if [ "$diferentes" -gt 1 ]; then
    falha "bloco $bloco difere entre páginas:"$'\n'"$assinaturas"
  fi
done

# 7. Um único telefone, e-mail e link da Área do Cliente em todo o site
numeros=$(grep -ohE 'wa\.me/[0-9]+' $PUB/*.html | sort -u)
[ "$numeros" = "wa.me/5531983276361" ] || falha "número de WhatsApp diferente do oficial: $(echo $numeros)"
sem_marca=$(grep -ohE 'https://wa\.me/[^"]+' $PUB/*.html | grep -vc 'BMC%20Capital%20Partners')
[ "$sem_marca" -eq 0 ] || falha "$sem_marca link(s) de WhatsApp sem 'BMC Capital Partners' na mensagem"
exibidos=$(grep -ohE '\+55 31 [0-9]{4,5}-[0-9]{4}' $PUB/*.html | sort -u)
[ "$exibidos" = "+55 31 98327-6361" ] || falha "telefone exibido diferente do oficial: $(echo $exibidos)"
emails=$(grep -ohE 'mailto:[^"]+' $PUB/*.html | sort -u | wc -l)
[ "$emails" -eq 1 ] || falha "mais de um e-mail de contato: $(grep -ohE 'mailto:[^"]+' $PUB/*.html | sort -u | tr '\n' ' ')"
portais=$(grep -ohE 'https://www\.difactweb\.com\.br/[^"]+' $PUB/*.html | sort -u | wc -l)
[ "$portais" -eq 1 ] || falha "mais de um endereço da Área do Cliente (DiFactWeb)"

# 8. Versão do CSS e do JS igual à impressão digital do arquivo
#    Se o arquivo mudou e o ?v= não, o visitante continuaria com a cópia
#    antiga no cache. Corrija com: bash scripts/atualizar-versao.sh
for par in "assets/css/styles.css" "assets/js/main.js"; do
  esperado=$(sha256sum "$PUB/$par" | cut -c1-8)
  nome=$(basename "$par")
  for p in $PAGINAS; do
    arq="$PUB/$p"
    [ -f "$arq" ] || continue
    achados=$(grep -oE "/$par\?v=[0-9A-Za-z]+" "$arq" | sed -E 's/.*\?v=//' | sort -u)
    if [ -z "$achados" ]; then
      falha "$p: não carrega /$par com ?v="
    elif [ "$achados" != "$esperado" ]; then
      falha "$p: $nome?v=$(echo $achados) desatualizado (esperado $esperado). Rode: bash scripts/atualizar-versao.sh"
    fi
  done
done

# 9. Manifesto (nome e cor ao salvar o site na tela inicial)
MANIFESTO="$PUB/assets/images/favicon/site.webmanifest"
grep -q '"name": "BMC Capital Partners"' "$MANIFESTO" || falha "manifesto: name deve ser \"BMC Capital Partners\""
cor_paginas=$(grep -ohE '<meta name="theme-color" content="#[0-9A-Fa-f]{6}"' $PUB/*.html | grep -oE '#[0-9A-Fa-f]{6}' | sort -u)
cor_manifesto=$(grep -oE '"theme_color": "#[0-9A-Fa-f]{6}"' "$MANIFESTO" | grep -oE '#[0-9A-Fa-f]{6}')
[ "$(echo "$cor_paginas" | wc -l)" -eq 1 ] || falha "theme-color diferente entre páginas: $(echo $cor_paginas)"
[ "$cor_paginas" = "$cor_manifesto" ] || falha "theme_color do manifesto ($cor_manifesto) diferente do das páginas ($cor_paginas)"

if [ "$ERROS" -gt 0 ]; then
  echo "VERIFICAÇÃO REPROVADA: $ERROS erro(s). Nada foi publicado."
  exit 1
fi
echo "VERIFICAÇÃO APROVADA: site pronto para publicar."

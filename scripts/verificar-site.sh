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

if [ "$ERROS" -gt 0 ]; then
  echo "VERIFICAÇÃO REPROVADA: $ERROS erro(s). Nada foi publicado."
  exit 1
fi
echo "VERIFICAÇÃO APROVADA: site pronto para publicar."

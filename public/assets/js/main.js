/* ============================================================
   BMC Capital Partners — Site institucional V2
   main.js — menu móvel, ano do rodapé, revelação moderada,
   carrossel manual e progresso do processo.
   JavaScript puro, sem dependências.

   Regra de movimento: nada essencial depende de animação.
   Sem JS, ou com prefers-reduced-motion, todo o conteúdo
   nasce visível e todos os controles continuam funcionais.
   ============================================================ */
(function () {
  "use strict";

  var movimentoReduzido = window.matchMedia("(prefers-reduced-motion: reduce)");

  // A classe "js" é o que autoriza o estado inicial invisível dos elementos
  // animados. Ela só é aplicada mais abaixo, depois que o observador de
  // rolagem existe de fato — assim, qualquer falha antes disso deixa o
  // conteúdo visível em vez de escondê-lo para sempre.

  /* ---------- Menu móvel ---------- */
  var botaoMenu = document.querySelector(".bmc-menu-toggle");
  var painelMenu = document.getElementById("menu-principal");

  function fecharMenu() {
    if (!botaoMenu || !painelMenu) return;
    botaoMenu.setAttribute("aria-expanded", "false");
    painelMenu.classList.remove("aberta");
  }

  if (botaoMenu && painelMenu) {
    botaoMenu.addEventListener("click", function () {
      var aberto = botaoMenu.getAttribute("aria-expanded") === "true";
      botaoMenu.setAttribute("aria-expanded", String(!aberto));
      painelMenu.classList.toggle("aberta", !aberto);
    });

    document.addEventListener("keydown", function (evento) {
      if (evento.key === "Escape" && painelMenu.classList.contains("aberta")) {
        fecharMenu();
        botaoMenu.focus();
      }
    });

    document.addEventListener("click", function (evento) {
      if (
        painelMenu.classList.contains("aberta") &&
        !painelMenu.contains(evento.target) &&
        !botaoMenu.contains(evento.target)
      ) {
        fecharMenu();
      }
    });

    painelMenu.addEventListener("click", function (evento) {
      if (evento.target.closest("a")) fecharMenu();
    });

    window.addEventListener("resize", function () {
      if (window.innerWidth > 800) fecharMenu();
    });
  }

  /* ---------- Ano dinâmico no rodapé ---------- */
  var anoAtual = String(new Date().getFullYear());
  document.querySelectorAll("[data-ano]").forEach(function (el) {
    el.textContent = anoAtual;
  });

  /* ---------- Progresso do processo conforme a rolagem ----------
     Melhoria opcional. O trilho já nasce cheio pelo CSS e as etapas são
     legíveis sem JavaScript: nada aqui decide se o conteúdo aparece.
     A entrada suave dos blocos é feita só com animação CSS, sem depender
     de rolagem — em aba de segundo plano o navegador não entrega scroll,
     rAF nem IntersectionObserver, e conteúdo não pode depender disso. */
  var processos = [].slice.call(document.querySelectorAll("[data-processo]"));

  if (processos.length && !movimentoReduzido.matches) {
    var pendente = false;

    var atualizar = function () {
      pendente = false;
      var alvo = window.innerHeight * 0.55;
      processos.forEach(function (processo) {
        var c = processo.getBoundingClientRect();
        var percorrido = Math.max(0, Math.min(1, (alvo - c.top) / c.height));
        processo.style.setProperty("--progresso", (percorrido * 100).toFixed(1) + "%");
        processo.querySelectorAll(".bmc-etapa").forEach(function (etapa) {
          etapa.classList.toggle("ativa", etapa.getBoundingClientRect().top < alvo);
        });
      });
    };

    var agendar = function () {
      if (pendente) return;
      pendente = true;
      window.requestAnimationFrame(atualizar);
    };

    window.addEventListener("scroll", agendar, { passive: true });
    window.addEventListener("resize", agendar);
    atualizar();
  }

  /* ---------- Carrossel manual ----------
     Rolagem por scroll-snap. Os botões são um atalho: arrastar,
     rolar na horizontal e navegar por teclado continuam funcionando. */
  document.querySelectorAll("[data-carrossel]").forEach(function (carrossel) {
    var trilho = carrossel.querySelector(".bmc-carrossel__trilho");
    var anterior = carrossel.querySelector("[data-carrossel-anterior]");
    var proximo = carrossel.querySelector("[data-carrossel-proximo]");
    if (!trilho) return;

    function passo() {
      var item = trilho.firstElementChild;
      if (!item) return trilho.clientWidth;
      var estilo = window.getComputedStyle(trilho);
      var gap = parseFloat(estilo.columnGap || estilo.gap || "0") || 0;
      return item.getBoundingClientRect().width + gap;
    }

    function atualizarBotoes() {
      if (!anterior || !proximo) return;
      var max = trilho.scrollWidth - trilho.clientWidth - 1;
      anterior.disabled = trilho.scrollLeft <= 0;
      proximo.disabled = trilho.scrollLeft >= max;
    }

    function avancar(direcao) {
      var suave = !movimentoReduzido.matches && document.visibilityState === "visible";
      trilho.scrollBy({ left: direcao * passo(), behavior: suave ? "smooth" : "auto" });
      // O estado dos botões não depende só do evento de rolagem chegar.
      window.setTimeout(atualizarBotoes, suave ? 420 : 0);
    }

    if (anterior) {
      anterior.addEventListener("click", function () { avancar(-1); });
    }
    if (proximo) {
      proximo.addEventListener("click", function () { avancar(1); });
    }

    trilho.addEventListener("scroll", atualizarBotoes, { passive: true });
    window.addEventListener("resize", atualizarBotoes);
    atualizarBotoes();
  });

})();

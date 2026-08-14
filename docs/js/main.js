/* ==========================================================================
   Remove AI Watermarks — Context Menus · Site
   Interações: copiar código, menu mobile, reveal on scroll, ano do rodapé
   ========================================================================== */

(function () {
  'use strict';

  // ---------- Ano no rodapé ----------
  function setYear() {
    var el = document.getElementById('year');
    if (el) el.textContent = new Date().getFullYear();
  }

  // ---------- i18n ----------
  function initI18n() {
    if (!window.RAIW_I18N) return;
    RAIW_I18N.applyLang(RAIW_I18N.detectLang());
    setYear();

    document.querySelectorAll('.lang-btn').forEach(function (btn) {
      btn.addEventListener('click', function () {
        RAIW_I18N.applyLang(btn.getAttribute('data-lang'));
        setYear();
      });
    });
  }

  // ---------- Botões de copiar ----------
  document.querySelectorAll('.copy-btn').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var text = btn.getAttribute('data-copy') || '';
      var done = function () {
        var original = btn.getAttribute('data-copy-label') || 'Copy';
        btn.textContent = btn.getAttribute('data-copy-done') || 'Copied ✓';
        btn.classList.add('copied');
        setTimeout(function () {
          btn.textContent = original;
          btn.classList.remove('copied');
        }, 1800);
      };

      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(done).catch(function () {
          fallbackCopy(text, btn, done);
        });
      } else {
        fallbackCopy(text, btn, done);
      }
    });
  });

  function fallbackCopy(text, btn, done) {
    var ta = document.createElement('textarea');
    ta.value = text;
    ta.style.position = 'fixed';
    ta.style.opacity = '0';
    document.body.appendChild(ta);
    ta.select();
    try {
      document.execCommand('copy');
      done();
    } catch (e) {
      btn.textContent = btn.getAttribute('data-copy-error') || 'Error';
    }
    document.body.removeChild(ta);
  }

  // ---------- Menu mobile ----------
  var navToggle = document.getElementById('navToggle');
  var navLinks = document.getElementById('navLinks');

  navToggle.addEventListener('click', function () {
    var open = navLinks.classList.toggle('open');
    navToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
  });

  // Fecha o menu ao clicar em um link
  navLinks.querySelectorAll('a').forEach(function (link) {
    link.addEventListener('click', function () {
      navLinks.classList.remove('open');
      navToggle.setAttribute('aria-expanded', 'false');
    });
  });

  // ---------- Reveal on scroll ----------
  var revealEls = document.querySelectorAll('.feature-card, .manager-card, .usage-card, .step');
  if ('IntersectionObserver' in window) {
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12 });
    revealEls.forEach(function (el) { el.classList.add('reveal'); observer.observe(el); });
  } else {
    revealEls.forEach(function (el) { el.classList.add('visible'); });
  }

  // ---------- Navbar com sombra ao rolar ----------
  var nav = document.querySelector('.nav');
  window.addEventListener('scroll', function () {
    if (window.scrollY > 10) {
      nav.style.boxShadow = '0 4px 30px rgba(0, 0, 0, 0.4)';
    } else {
      nav.style.boxShadow = 'none';
    }
  }, { passive: true });

  // ---------- Inicializa i18n ----------
  initI18n();
})();
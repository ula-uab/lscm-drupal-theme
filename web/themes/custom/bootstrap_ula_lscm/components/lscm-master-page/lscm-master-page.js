/**
 * lscm-master-page.js
 * Scroll reveal + nav shadow — idéntico al script original del HTML.
 * Drupal SDC lo carga automáticamente cuando el componente está en el DOM.
 */
(function () {
  'use strict';

  // ── Scroll reveal ──────────────────────────────────────────
  const reveals = document.querySelectorAll('.reveal');
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
        }
      });
    },
    { threshold: 0.1, rootMargin: '0px 0px -40px 0px' }
  );
  reveals.forEach((el) => observer.observe(el));

  // ── Nav scroll shadow ──────────────────────────────────────
  const nav = document.querySelector('nav');
  if (nav) {
    window.addEventListener('scroll', () => {
      nav.style.boxShadow =
        window.scrollY > 20 ? '0 2px 24px rgba(0,0,0,0.3)' : 'none';
    });
  }

  // ── Hamburguesa del header (menú de sitio 'home_header') ────
  // Toggle accesible con API nativa: actualiza aria-expanded, muestra/oculta el
  // panel (atributo hidden), y cierra con Escape o clic fuera.
  const burger = document.querySelector('.nav-burger');
  const panel = document.getElementById('site-menu-panel');
  if (burger && panel) {
    const closeMenu = () => {
      burger.setAttribute('aria-expanded', 'false');
      panel.hidden = true;
    };
    const openMenu = () => {
      burger.setAttribute('aria-expanded', 'true');
      panel.hidden = false;
    };
    const toggleMenu = () => {
      const isOpen = burger.getAttribute('aria-expanded') === 'true';
      isOpen ? closeMenu() : openMenu();
    };

    burger.addEventListener('click', (e) => {
      e.stopPropagation();
      toggleMenu();
    });

    // Cerrar con Escape.
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && burger.getAttribute('aria-expanded') === 'true') {
        closeMenu();
        burger.focus();
      }
    });

    // Cerrar al hacer clic fuera del panel.
    document.addEventListener('click', (e) => {
      if (
        burger.getAttribute('aria-expanded') === 'true' &&
        !panel.contains(e.target) &&
        !burger.contains(e.target)
      ) {
        closeMenu();
      }
    });

    // Cerrar al pulsar un enlace del panel (navegación).
    panel.querySelectorAll('a').forEach((link) => {
      link.addEventListener('click', () => closeMenu());
    });
  }

  // ── Modal de las pastillas de universidad (sub-hito 4b) ─────
  // Un <dialog> compartido; cada botón .uni-sem-tag--button vuelca su título y su
  // HTML (data-attributes) al abrirlo. API nativa: showModal() atrapa foco y permite
  // cerrar con Escape; añadimos cierre por botón y por clic en el backdrop.
  const uniModal = document.getElementById('uni-modal');
  if (uniModal) {
    const titleEl = uniModal.querySelector('.uni-modal__title');
    const bodyEl = uniModal.querySelector('.uni-modal__body');

    document.querySelectorAll('.uni-sem-tag--button').forEach((btn) => {
      btn.addEventListener('click', () => {
        titleEl.textContent = btn.getAttribute('data-modal-title') || '';
        // data-modal-html contiene HTML ya saneado (Basic HTML) desde el campo de modal.
        bodyEl.innerHTML = btn.getAttribute('data-modal-html') || '';
        uniModal.showModal();
      });
    });

    // Cerrar con el botón de cierre.
    const closeBtn = uniModal.querySelector('[data-modal-close]');
    if (closeBtn) {
      closeBtn.addEventListener('click', () => uniModal.close());
    }

    // Cerrar al hacer clic en el backdrop (fuera del contenido).
    uniModal.addEventListener('click', (e) => {
      if (e.target === uniModal) {
        uniModal.close();
      }
    });
  }
})();

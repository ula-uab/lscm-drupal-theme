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
})();

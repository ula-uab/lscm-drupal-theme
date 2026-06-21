/**
 * ula_carousel.js — carrusel propio del design system ULA.
 *
 * Vanilla, sin dependencias ni Bootstrap Italia. SDC lo carga automáticamente cuando el componente
 * está en el DOM (igual que lscm-master-page.js). Comportamiento: paginación por GRUPOS de --visible
 * cards; flechas + puntos (los puntos se generan según el nº de grupos); swipe táctil; teclado
 * (flechas izq/der); SIN autoplay. El nº de visibles lo aporta el CSS en la variable --visible y
 * cambia por breakpoint (se recalcula en resize).
 */
(function () {
  'use strict';

  function visibleCount(root) {
    var v = parseInt(getComputedStyle(root).getPropertyValue('--visible'), 10);
    return v && v > 0 ? v : 1;
  }

  function init(root) {
    if (root.dataset.ulaCarouselInit) {
      return;
    }
    root.dataset.ulaCarouselInit = '1';

    var viewport = root.querySelector('.ula-carousel__viewport');
    var track = root.querySelector('.ula-carousel__track');
    var prev = root.querySelector('.ula-carousel__arrow--prev');
    var next = root.querySelector('.ula-carousel__arrow--next');
    var dotsWrap = root.querySelector('.ula-carousel__dots');
    var slides = track ? Array.prototype.slice.call(track.children) : [];
    if (!viewport || !track || slides.length === 0) {
      return;
    }

    var page = 0;

    function pages() {
      return Math.max(1, Math.ceil(slides.length / visibleCount(root)));
    }

    function clamp() {
      var max = pages() - 1;
      if (page > max) { page = max; }
      if (page < 0) { page = 0; }
    }

    function buildDots() {
      if (!dotsWrap) { return; }
      var total = pages();
      dotsWrap.style.display = total <= 1 ? 'none' : '';
      if (dotsWrap.childElementCount !== total) {
        dotsWrap.innerHTML = '';
        for (var i = 0; i < total; i++) {
          var dot = document.createElement('button');
          dot.type = 'button';
          dot.className = 'ula-carousel__dot';
          dot.setAttribute('aria-label', 'Go to group ' + (i + 1));
          (function (idx) {
            dot.addEventListener('click', function () {
              page = idx;
              update();
            });
          })(i);
          dotsWrap.appendChild(dot);
        }
      }
      var dots = dotsWrap.children;
      for (var j = 0; j < dots.length; j++) {
        var active = j === page;
        dots[j].classList.toggle('is-active', active);
        if (active) {
          dots[j].setAttribute('aria-current', 'true');
        } else {
          dots[j].removeAttribute('aria-current');
        }
      }
    }

    function update() {
      clamp();
      var target = slides[Math.min(page * visibleCount(root), slides.length - 1)];
      var maxShift = Math.max(0, track.scrollWidth - viewport.clientWidth);
      var shift = Math.min(target.offsetLeft, maxShift);
      track.style.transform = 'translateX(' + -shift + 'px)';
      if (prev) { prev.disabled = page === 0; }
      if (next) { next.disabled = page >= pages() - 1; }
      buildDots();
    }

    function go(delta) {
      page += delta;
      update();
    }

    if (prev) { prev.addEventListener('click', function () { go(-1); }); }
    if (next) { next.addEventListener('click', function () { go(1); }); }

    root.addEventListener('keydown', function (e) {
      if (e.key === 'ArrowLeft') { go(-1); }
      else if (e.key === 'ArrowRight') { go(1); }
    });

    // Swipe táctil.
    var startX = 0;
    var dragging = false;
    viewport.addEventListener('touchstart', function (e) {
      dragging = true;
      startX = e.touches[0].clientX;
    }, { passive: true });
    viewport.addEventListener('touchend', function (e) {
      if (!dragging) { return; }
      dragging = false;
      var dx = e.changedTouches[0].clientX - startX;
      if (Math.abs(dx) > 40) { go(dx < 0 ? 1 : -1); }
    });

    // Recalcular al cambiar el ancho (cambia --visible y el nº de grupos).
    var raf;
    window.addEventListener('resize', function () {
      window.cancelAnimationFrame(raf);
      raf = window.requestAnimationFrame(update);
    });

    update();
  }

  function initAll() {
    Array.prototype.forEach.call(document.querySelectorAll('.ula-carousel'), init);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAll);
  } else {
    initAll();
  }
})();

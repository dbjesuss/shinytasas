$(document).ready(function () {

  // Reinicializar selectize con dropdownParent:'body'
  // Esto hace que el menu se renderice directo en el body
  // quedando siempre por encima de cualquier elemento
  function patchSelectize(selector) {
    $(selector).each(function () {
      var $el  = $(this);
      var inst = $el[0].selectize;
      if (!inst || inst._patched) return;
      inst._patched = true;

      // Guardar estado actual
      var currentVal = inst.getValue();
      var opts       = inst.options;
      var settings   = $.extend({}, inst.settings, {
        dropdownParent: 'body',
        onDropdownOpen: function($dropdown) {
          // Alinear con el input
          var $ctrl   = inst.$control;
          var offset  = $ctrl.offset();
          var scrollY = $(window).scrollTop();
          var scrollX = $(window).scrollLeft();
          $dropdown.css({
            top   : offset.top  + $ctrl.outerHeight() - scrollY,
            left  : offset.left - scrollX,
            width : $ctrl.outerWidth()
          });
        }
      });

      inst.destroy();
      $el.selectize(settings);
      // Restaurar valor
      if ($el[0].selectize) {
        $el[0].selectize.setValue(currentVal, true);
      }
    });
  }

  // Aplicar a los selects problemáticos después de que Shiny los inicialice
  $(document).on('shiny:idle', function () {
    patchSelectize('#problema-serie1');
    patchSelectize('#problema-serie2');
    patchSelectize('#marco_teorico-serie_acf');
    patchSelectize('#resultados-serie_hist');
    patchSelectize('#resultados-tipo_cor');
  });

  // Re-aplicar si Shiny actualiza la UI
  $(document).on('shiny:value', function () {
    setTimeout(function () {
      patchSelectize('select.shiny-bound-input');
    }, 200);
  });
});

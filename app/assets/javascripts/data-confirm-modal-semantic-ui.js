(function ($) {

  /**
   * Builds the markup for a [SemanticUI modal](http://semantic-ui.com/modules/modal.html)
   * for the given `element`. Uses the following `data-` parameters to
   * customize it:
   *
   *  * `data-confirm`: Contains the modal body text. HTML is allowed.
   *                    Separate multiple paragraphs using \n\n.
   *  * `data-commit`:  The 'confirm' button text. "Confirm" by default.
   *  * `data-cancel`:  The 'cancel' button text. "Cancel" by default.
   *  * `data-verify`:  Adds a text input in which the user has to input
   *                    the text in this attribute value for the 'confirm'
   *                    button to be clickable. Optional.
   *  * `data-verify-text`:  Adds a label for the data-verify input. Optional
   *  * `data-focus`:   Define focused input. Supported values are
   *                    'cancel' or 'commit', 'cancel' is default for
   *                    data-method DELETE, 'commit' for all others.
   *
   * You can set global setting using `dataConfirmModal.setDefaults`, for example:
   *
   *    dataConfirmModal.setDefaults({
   *      title: 'Confirm your action',
   *      commit: 'Continue',
   *      cancel: 'Cancel'
   *    });
   *
   */

  var defaults = {
    title: '提示',
    commit: '<i class="checkmark icon"></i>确定',
    commitClass: 'ui green ok inverted button',
    cancel: '<i class="remove icon"></i>取消',
    cancelClass: 'ui red cancel inverted button',
    verifyClass: 'ui fluid big input',
    elements: ['a[data-confirm]', 'button[data-confirm]', 'input[type=submit][data-confirm]'],
    focus: 'commit',
    zIndex: 1050,
    modalClass: 'small',
    closable: true,
    transition: 'scale',
    duration: 400,
    show: true
  };

  var settings;

  window.dataConfirmModal = {
    setDefaults: function (newSettings) {
      settings = $.extend(settings, newSettings);
    },

    restoreDefaults: function () {
      settings = $.extend({}, defaults);
    },

    confirm: function (options) {
      // Build an ephemeral modal
      //
      var modal = buildModal(options);

      modal.spawn();

      modal.modal({
        onHidden: function () {
          modal.remove();
        }
      });

      modal.find('.commit').on('click', function () {
        if (options.onConfirm && options.onConfirm.call)
          options.onConfirm.call();

        modal.modal('hide');
      });

      modal.find('.cancel').on('click', function () {
        if (options.onCancel && options.onCancel.call)
          options.onCancel.call();

        modal.modal('hide');
      });
    }
  };

  dataConfirmModal.restoreDefaults();

  var buildElementModal = function (element) {
    var options = {
      title:        element.attr('title') || element.data('title'),
      text:         element.data('confirm'),
      focus:        element.data('focus'),
      method:       element.data('method'),
      commit:       element.data('commit'),
      commitClass:  element.data('commit-class'),
      cancel:       element.data('cancel'),
      cancelClass:  element.data('cancel-class'),
      remote:       element.data('remote'),
      verify:       element.data('verify'),
      verifyRegexp: element.data('verify-regexp'),
      verifyLabel:  element.data('verify-text'),
      verifyRegexpCaseInsensitive: element.data('verify-regexp-caseinsensitive'),
      closable:     element.data('closable') || settings.closable,
      transition:   element.data('transition') || settings.transition,
      duration:     element.data('duration') || settings.duration,
      show:         element.data('show')
    };

    var modal = buildModal(options);

    modal.data('confirmed', false);
    modal.find('.commit').on('click', function () {
      modal.data('confirmed', true);
      element.trigger('click');
      modal.modal('hide');
    });

    return modal;
  };

  var buildModal = function (options) {
    var id = 'confirm-modal-' + String(Math.random()).slice(2, -1);
    var optionModalClass = settings.modalClass ? settings.modalClass : '';
    var modalClass = 'ui confirm '+optionModalClass+' modal transition';

    var modal = $(
      '<div id="'+id+'" class="'+modalClass+'">' +

        '<div class="header" id="confirm-modal-header">' +
          '<h4 id="'+id+'Label" class="title"></h4>' +
        '</div>' +
        '<div class="content"></div>' +
        '<div class="actions">' +
          '<button class="ui cancel button"><i class="remove icon"></i></button>' +
          '<button class="ui commit button"><i class="checkmark icon"></i></button>' +
        '</div>'+

      '</div>'
    );

    modal.modal({
      selector: {
        close: '.cancel.button'
      }
    });

    // Make sure it's always the top zindex
    var highest = current = settings.zIndex;
    $('.ui.confirm.modal').not('#'+id).each(function() {
      current = parseInt($(this).css('z-index'), 10);
      if(current > highest) {
        highest = current
      }
    });
    modal.css('z-index', parseInt(highest) + 1);

    modal.find('.title').text(options.title || settings.title);

    var body = modal.find('.content');

    $.each((options.text||'').split(/\n{2}/), function (i, piece) {
      body.append($('<p/>').html(piece));
    });

    var commit = modal.find('.ui.commit.button');
    commit.html(options.commit || settings.commit);
    commit.addClass(options.commitClass || settings.commitClass);

    var cancel = modal.find('.ui.cancel.button');
    cancel.html(options.cancel || settings.cancel);
    cancel.addClass(options.cancelClass || settings.cancelClass);

    if (options.remote) {
      commit.on('click', function() {
        modal.modal('hide');
      });
    }

    if (options.verify || options.verifyRegexp) {
      commit.prop('disabled', true);

      var isMatch;
      if (options.verifyRegexp) {
        var caseInsensitive = options.verifyRegexpCaseInsensitive;
        var regexp = options.verifyRegexp;
        var re = new RegExp(regexp, caseInsensitive ? 'i' : '');

        isMatch = function (input) { return input.match(re) };
      } else {
        isMatch = function (input) { return options.verify == input };
      }
      var form = $('<div/>', {"class": settings.verifyClass});
      var verification = $('<input/>', {"type": 'text'}).on('keyup', function () {
        commit.prop('disabled', !isMatch($(this).val()));
      });

      modal.modal({
        onVisible: function() {
          verification.focus();
        },
        onHidden: function() {
          verification.val('').trigger('keyup');
        }
      });

      if (options.verifyLabel)
        body.append($('<p>', {text: options.verifyLabel}));

      form.append(verification);
      body.append(form);
    }

    var focus_element;
    if (options.focus) {
      focus_element = options.focus;
    } else if (options.method == 'delete') {
      focus_element = 'cancel'
    } else {
      focus_element = settings.focus;
    }
    focus_element = modal.find('.' + focus_element);

    modal.modal({
      onVisible: function() {
        focus_element.focus();
      }
    });

    $('body').append(modal);

    modal.spawn = function() {
      return modal.modal({
          closable: options.closable,
          transition: options.transition,
          duration: options.duration,
          allowMultiple: true
        }).modal('show');
    };

    return modal;
  };

  /**
   * Returns a modal already built for the given element or builds a new one,
   * caching it into the element's `confirm-modal` data attribute.
   */
  var getModal = function (element) {
    var modal = element.data('confirm-modal') || buildElementModal(element);

    if (modal && !element.data('confirm-modal')) {
      element.data('confirm-modal', modal);
    }

    return modal;
  };

  $.fn.confirmModal = function () {
    getModal($(this)).spawn();

    return this;
  };

  if ($.rails) {
    /**
     * Attaches to the Rails' UJS adapter 'confirm' event on links having a
     * `data-confirm` attribute. Temporarily overrides the `$.rails.confirm`
     * function with an anonymous one that returns the 'confirmed' status of
     * the modal.
     *
     * A modal is considered 'confirmed' when an user has successfully clicked
     * the 'confirm' button in it.
     */

    $(document).delegate(settings.elements.join(', '), 'confirm', function() {
      var element = $(this), modal = getModal(element);
      var confirmed = modal.data('confirmed');

      if (!confirmed && !modal.is(':visible')) {
        modal.spawn();

        var confirm = $.rails.confirm;
        $.rails.confirm = function () { return modal.data('confirmed'); };
        
        modal.modal({
          onHidden: function() {
            $.rails.confirm = confirm;
          }
        });
      }

      return confirmed;
    });
  }

})(jQuery);

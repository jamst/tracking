//= require jquery
//= require jquery_ujs
//= require lodash.min
//= require jquery.remotipart
//= require semantic
//= require zUI
//= require moment
//= require data-confirm-modal-semantic-ui
//= require cocoon
//= require ./dashboard
//= require_tree ../semantic
//= require_self

$.fn.dropdown.settings.placeholder = false;
$.fn.search.settings.maxResults = 15;
$.fn.calendar.settings.ampm = false;
$.fn.calendar.settings.text.days = ['日','一','二','三','四','五','六'];
$.fn.calendar.settings.text.months = ['一','二','三','四','五','六','七','八','九','十','十一','十二'];
$.fn.calendar.settings.text.monthsShort = ['一','二','三','四','五','六','七','八','九','十','十一','十二'];
$.fn.calendar.settings.formatter.dayHeader = function (date, settings) {
  var month = date.getMonth() + 1;
  var year = date.getFullYear();
  if (month < 10) { month = '0' + month;}
  return  '' + year + '-' + month;
};
$.fn.calendar.settings.formatter.date = function (date, settings) {
  if (!date) {
    return '';
  }
  var day = date.getDate();
  var month = date.getMonth() + 1;
  var year = date.getFullYear();
  if (month < 10) { month = '0' + month;}
  if (day < 10) { day = '0' + day;}
  return settings.type === 'year' ? year :
    settings.type === 'month' ?  '' + year + '-' + month :
     '' + year + '-' + month + '-' + day;
};
$.fn.calendar.settings.formatter.time = function (date, settings, forCalendar) {
  if (!date) {
    return '';
  }
  var hour = date.getHours();
  var minute = date.getMinutes();
  var ampm = '';
  if (settings.ampm) {
    ampm = ' ' + (hour < 12 ? settings.text.am : settings.text.pm);
    hour = hour === 0 ? 12 : hour > 12 ? hour - 12 : hour;
  }
  if (hour < 10) { hour = '0' + hour;}
  if (minute < 10) { minute = '0' + minute;}
  return '' + hour + ':'  + minute + ':00' + ampm;
};

$.fn.form.settings.rules.number_range = function(value, range) {
  var intRegExp = $.fn.form.settings.regExp.number;
  var min, max, parts;
  if( !range || ['', '..'].indexOf(range) !== -1) {
    // do nothing
  } else if(range.indexOf('..') == -1) {
    if(intRegExp.test(range)) {
      min = max = range - 0;
    };
  } else {
    parts = range.split('..', 2);
    if(intRegExp.test(parts[0])) {
      min = parts[0] - 0;
    };
    if(intRegExp.test(parts[1])) {
      max = parts[1] - 0;
    };
  };
  return (intRegExp.test(value) && (min === undefined || value >= min) && (max === undefined || value <= max));
};

var ajaxBar = function(obj,options){
  options['ov'] = obj.value;
  if(options['ov'] == '--blank--'){
    return ;
  }
  $.get('/admin/ajax_bar',options,function(data){data});
}

var ajaxBarShowModal = function(element){
    $(element).modal('setting', {autofocus: false,allowMultiple: true}).modal('show');
}

var ajaxBarHideModal = function(element){
    $(element).modal('setting', {autofocus: false}).modal('hide');
}


$(function(){
  $('.message .close').on('click', function() {
  $(this).closest('.message').fadeOut();
  });

  $(document).on('click', '.J_close_pop', function(){
    $('.popup').css("cssText","display: none!important");
  });
  //头部菜单
  $('a[data-toggle="popup"]').each(function() {
    $(this).popup({
      popup: $(this).attr('data-content'),
      position: $(this).attr('data-position'),
      on: 'click'
    })
  });
  $('.ui.dropdown.item').dropdown();

  //显示隐藏菜单
  $('#showToggle').hide();
  $('#hideToggle').show();
  $('#hideToggle,#showToggle').click(function() {
    if($('#sideMenu').hasClass('close_menu')){
      $('#hideToggle').hide();
      $('#showToggle').show();
      $('#sideMenu').removeClass('close_menu').addClass('open_menu');
    }else{
      $('#showToggle').hide();
      $('#hideToggle').show();
      $('#verticalMenu .child').hide();
      $('#verticalMenu a').removeClass('active');
      $('#sideMenu').removeClass('open_menu').addClass('close_menu');
    }
  });

  //展开菜单
  $('#verticalMenu a').on('click', function() {
    if ($(this).next('.child').length > 0 && $('#sideMenu').hasClass('open_menu')) {
      if ($(this).hasClass('active')) {
        $('#verticalMenu a').removeClass('active');
        $('#verticalMenu .child').hide();
        $(this).removeClass('active');
        $(this).next('.child').hide();
      } else {
        $('#verticalMenu a').removeClass('active');
        $('#verticalMenu .child').hide();
        $(this).addClass('active');
        $(this).next('.child').show();
      }

    }
  });

  $('.close_menu li').hover(function(){
    $(this).siblings().removeClass('active');
    $(this).addClass('active');
  },function(){
    $(this).removeClass('active');
  });
  $('.popups').popup();
  $('select.dropdown').dropdown({placeholder: false});
  $("#verticalMenu li").each(function(){
      if($(this).find("div a").length < 1){
          $(this).remove();
      }
  });
  $('.button').popup();
  $('.label').popup();
  $('i.icon').popup();
  $('.icon').on('click', function() {
      $('.popup').css("cssText", "display: none!important");
  })

  $('.cas').popup();
  // $('input.checkbox').checkbox()

  $(".button-to-export-search-excel").click(function(){
    $(".button-to-export-search-excel").attr('href', window.location.pathname+'.xls'+window.location.search)
    $(".button-to-export-search-excel").attr('target', 'blank');
  });
  $('.menu .item') .tab() ;
  $('.button.dropdown').dropdown({on: 'hover', action: function(text, value) {}});
  
  //时间插件
  $('.J_calendar_datetime').calendar();

  $("#top_search_form").find(".ui.search").search({
    apiSettings: {
      url: '/admin/autocomplete/top_search?q={query}'
    },
    fields:{
      title: 'valid_name'
    },
    minCharacters : 2,
    onSelect: function(result, response){
      $("#top_search_form").find("input").val(result.valid_name);
      $("#top_search_form").submit();
    }
  });

});

function top_search(){
  $("#top_search_form").submit();
}

var onPaginationSelect = function(e){
  var h = $(e).val();
  if ($(e).data('remote')){
    $('#pagination_href_auto').remove();
    var a = $('<a id="pagination_href_auto" style="display:none" href="'+ h +'" data-remote="true">&nbsp;</a>');
    a.appendTo("body");
    a.trigger('click');
  }else{
    window.location.href = h;
  }
}

// 发货信息的form 动作，物流自提不需要显示快单号 等等
  var module_shipment_form_action = function (){
    // alert('come in module.')
    var ship_js_show_hide_switch = function(ship_method){
      //快递到门
      if (ship_method == 'express_to_door'){
        $('#ship_js_express_id_div').show()
        $('#ship_js_express_no').show()
        $('#ship_js_other_express_name').show()

      }
      //物流自提  送货上门
      if (ship_method == 'self_pick_up' || ship_method == 'deliver_to_door'){
        $('#ship_js_express_id_div').hide()
        $('#ship_js_express_no').hide()
        $('#ship_js_other_express_name').hide()
      }
    }

    $('.ship_js_ship_method').change(function(){
      ship_js_show_hide_switch($(this).val())
    })

    $('.ship_js_express_id').change(function(){
      //其他快递公司
      if ($(this).val() == '13'){
        $('#ship_js_other_express_name').show();
      }else{
        $('#ship_js_other_express_name').hide();
      }
    })


    ship_js_show_hide_switch($('.ship_js_ship_method').val());
  }

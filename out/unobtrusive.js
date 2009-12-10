var popupStatus = 0; // 0 means disabled; 1 means enabled.

// loading popup with jQuery magic!
  function loadPopup() {
    // loads popup only if it is disabled
    if (popupStatus == 0) {
      $("#descr_popup").css({"opacity" : "0.9"});
      $("#descr_popup").fadeIn("slow");
      popupStatus = 1;
    }
  }

  // disabling popup with jQuery magic!
  function disablePopup() {
    // disables popup only if it is enabled
    if (popupStatus == 1) {
        $("#descr_popup").fadeOut("slow");
        popupStatus = 0;
    }
  }

  //centering popup
  function centerPopup(){
    // request data for centering
    var windowWidth = document.documentElement.clientWidth;
    var windowHeight = document.documentElement.clientHeight;
    var popupHeight = $("#descr_popup").height();
    var popupWidth = $("#descr_popup").width();
    // centering
    $("#descr_popup").css({
      "position": "absolute",
      "top": windowHeight/2-popupHeight/2,
      "left": windowWidth/2-popupWidth/2
    });
  }


// ----------------------------------------------------------

$(document).ready(function(){

  // Allows clicking the navigation boxes and selecting maps.
  var oldNavBox = null;
  $('.nav_box').click( function(event){
    if (oldNavBox == this) return;
    if (oldNavBox != null) $(oldNavBox).removeClass('active');
    oldNavBox = this;
    $(this).addClass('active');
    img_path = $(this).attr('img_path')
    $('img#map').attr('src', img_path)
  });

  //---------------------------------------------------------
  // Popup magic here.

  $('img#map').click( function(event){
    centerPopup();
    loadPopup();
  });

  $('descr_popup').click( function(event){
    centerPopup();
    disablePopup();
  });

  // Press Escape event!
  $(document).keypress(function(e){
  if(e.keyCode==27 && popupStatus==1){
    disablePopup();
  }
  });

});

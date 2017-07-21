$(function() {
  var changeType = function() {
    $("form .step").hide()
    var block = $("#step_type").val()
    if (block)
      $("form .step." + block).show()
  }

  changeType();

  $("#step_type").change(changeType)
})
function reply() {
  jivo_api.sendMessage({message: "Everything is fineeee!"})
}

module.exports = function() {
  $("#jivo_container").contents().find("#input-field").keydown(function() {
    if($(this).keyCode == 13) {
      reply()
    }
  })
}

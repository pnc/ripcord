$(document).ready(function() {
  $('.repository').editable('/apps', {
    method    : 'PUT',
    indicator : 'Saving…',
    tooltip   : 'Click to edit…'
  });
});
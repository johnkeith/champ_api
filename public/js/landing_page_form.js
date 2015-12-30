(function(){
  $(document).ready(function (){
    validate();
    $('#authenticated_form__email, #authenticated_form__code').change(validate);
  });

  function validate(){
    if($('#authenticated_form__email').val().length > 0 &&
      $('#authenticated_form__code').val().length > 0){
      $("#authenticated_form__submit").prop("disabled", false);
    }
    else {
      $("#authenticated_form__submit").prop("disabled", true);
    }
  }
})();


class AntCat.TaxonForm extends AntCat.Form

  constructor: ->
    super
    $('#type_taxt_editor .taxt_edit_box').focus()

  submit: =>
    @start_throbbing()
    @form().submit()

  cancel: =>
    id = @form().attr('action').match(/\d+/)[0]
    window.location = "/catalog/#{id}"

$ ->
  new AntCat.TaxonForm $('.taxon_form'), button_container: '> .buttons_section'
  new AntCat.TaxtEditor $('#headline_notes_taxt_editor'), parent_buttons: '.buttons_section'
  new AntCat.TaxtEditor $('#type_taxt_editor'), parent_buttons: '.buttons_section'

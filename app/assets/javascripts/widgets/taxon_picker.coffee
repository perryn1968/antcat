class AntCat.TaxonPicker extends AntCat.NestedForm

  constructor: (@element, @options = {}) ->
    @options.button_container = element.find('.buttons')
    @options.modal = true
    super

  # returns the value of the taxon
  submit: (eventObject) =>
    @close()
    @options.on_ok($(eventObject.currentTarget).attr('id'))

  cancel: =>
    @close()

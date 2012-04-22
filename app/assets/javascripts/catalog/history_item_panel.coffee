window.AntCat or= {}

class AntCat.HistoryItemPanel

  constructor: ($element, options = {}) ->
    @on_edit_opened = options.on_edit_opened
    @spinner_path = 'assets/ui-anim_basic_16x16.gif'
    (new Image()).src = @spinner_path
    @initialize $element
    return @

  initialize: ($element) =>
    @element = $element
    @element
      .addClass(AntCat.HistoryItemPanel.element_class)
      .mouseenter(=> @element.find('.icon').show() unless @is_editing())
      .mouseleave(=> @element.find('.icon').hide())
      .find('.icon.edit').click @edit
    @element.find('.icon').hide() unless AntCat.testing

  @element_class: 'history_item'
  @is_editing: -> $(".#{AntCat.HistoryItemPanel.element_class} div.form").is ':visible'

  is_editing: => @element.find('div.form').is ':visible'

  show: =>
    @save_form_values()
    @show_form()

  show_form: =>
    @element.find('div.display').hide()
    $('.icon').hide() unless AntCat.testing
    @element.find('div.form').show()
    @resize_edit_box()
    @element.find('.taxt_edit_box').first().focus()

  save_form_values: =>
    panel_class = 'inline-form-panel'
    original_value_key = panel_class + '_original_value'
    $taxt_edit_box = @element.find 'textarea'
    $taxt_edit_box.data original_value_key, $taxt_edit_box.val()

  resize_edit_box: =>
    # make the textarea of the form the same height as the item it's editing
    display_height = @element.find('div.display').height()
    @element.find('.taxt_edit_box').height display_height + 30

  update_form: (data, statusText, xhr, $form) =>
    @stop_spinning()
    panel_selector = '#item_' + (if data.isNew then "" else data.id)
    $panel = $ panel_selector
    if not data.success
      @show_error_messages $form, data.content
      return
    $panel.replaceWith data.content
    @initialize $(panel_selector)

  restore_form_values: =>
    $taxt_edit_box = @element.find('textarea')
    panel_class = 'inline-form-panel'
    original_value_key = panel_class + '_original_value'
    $taxt_edit_box.val $taxt_edit_box.data original_value_key

  handle_error: (jq_xhr, text_status, error_thrown) =>
    @stop_spinning()
    alert "Oh, shoot. It looks like a bug prevented this item from being saved.\n\nPlease report this situation to Mark Wilden (mark@mwilden.com) and we'll fix it.\n\n#{error_thrown}" unless AntCat.testing

  start_spinning: =>
    @element.find(':button')
      .disable()
      .parent().spinner position: 'left', leftOffset: 1, img: @spinner_path

  stop_spinning: =>
    @element.find('.spinner')
      .enable()
      .spinner 'remove'

  show_error_messages: ($form, html) ->
    clear_error_messages()
    $form.prepend $(html).find 'ul.error_messages'

  clear_error_messages: =>
    @element.find('ul.error_messages').remove()

  edit: =>
    return false if @is_editing()
    @show()
    new AntCat.HistoryItemForm(@element.find 'div.form form')
    @on_edit_opened() if @on_edit_opened
    false

$.fn.history_item_panel = (options = {}) ->
  return this.each -> new AntCat.HistoryItemPanel $(this), options

#----------------------------------------------
class AntCat.HistoryItemForm

  constructor: (@element, options = {}) ->
    self = @
    @element
      .find('.submit')
        .button()
        .click(-> self.submit_form this )
        .end()
      .find('.cancel')
        .button()
        .click(-> self.cancel_form this )
        .end()
      .find('textarea')
        .taxt_edit_box()

  submit_form: (button) =>
    @start_spinning()
    @element.ajaxSubmit
      success: @update_form
      error: @handle_error
      dataType: 'json'
    false

  cancel_form: (button) =>
    @clear_error_messages()
    unless @element.attr('id') is 'item_'
      id = @element.attr('id')
      @restore_form_values()
      $panel = $('#' + id)
      $panel.find('div.form').hide()
      $panel.find('div.display').show()
    false


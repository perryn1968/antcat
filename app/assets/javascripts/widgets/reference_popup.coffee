class AntCat.ReferencePopup extends AntCat.ReferencePicker

  constructor: (@parent_element, @options = {}) ->
    @element = @parent_element.find('> .antcat_reference_popup')

    if @options.id
      @id = @options.id
    else
      @id = @element.find('#id').val()

    @original_id = @id
    if @id
      @load ''
    else
      @initialize()

  load: (url = '') =>
    if url.indexOf('/reference_popup') is -1
      url = '/reference_popup?' + url
    url = url + '&' + $.param id: @id if @id
    @start_throbbing()
    $.ajax
      url: url
      dataType: 'html'
      success: (data) =>
        @element.replaceWith data
        @element = @parent_element.find('> .antcat_reference_popup')
        @initialize()
      error: (xhr) => debugger

  initialize: =>
    @expansion = @element.find '> .expansion'
    @template = @element.find '> .template'
    @current = @element.find '> .current'
    @search_selector = @expansion.find '#search_selector.search_selector'
    @textbox = @expansion.find '.q'

    @setup_controls()
    @setup_references()
    @handle_new_selection()

    @show()
    @textbox.focus()

  editing: => @element.find('.edit:visible .nested_form').length > 0

  show: =>
    @element.show()
    @expansion.show()
    # apparently, can't setup selectmenu unless it's visible
    @setup_search_selector()

  ok: =>
    @element.find('#id').val(@id)
    taxt = if @current_reference() then @current_reference().data 'taxt' else null
    @options.on_ok(taxt) if @options.on_ok
    @close()

  cancel: =>
    @clear_current()
    @id = @original_id
    @element.find('#id').val(@id)
    @options.on_cancel if @options.on_cancel
    @close()

  close: =>
    @element.hide()
    @options.on_close() if @options.on_close

  value: => @id

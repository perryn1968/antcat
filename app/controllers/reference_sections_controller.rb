# coding: UTF-8
class ReferenceSectionsController < ApplicationController
  before_filter :authenticate_catalog_editor
  skip_before_filter :authenticate_catalog_editor, if: :preview?

  def update
    @item = ReferenceSections.find params[:id]
    #@item.update_taxt_from_editable params[:taxt]
    render_json false
  end

  def create
    taxon = Taxon.find params[:taxa_id]
    #@item = ReferenceSections.create_taxt_from_editable taxon, params[:taxt]
    render_json true
  end

  def destroy
    @item = ReferenceSections.find params[:id]
    @item.destroy
    json = {success: true}.to_json
    render json: json, content_type: 'text/html'
  end

  ###

  def render_json is_new
    json = {
      isNew: is_new,
      content: render_to_string(partial: 'reference_sections/panel', locals: {item: @item}),
      id: @item.id,
      success: @item.errors.empty?
    }.to_json

    render json: json, content_type: 'text/html'
  end

end
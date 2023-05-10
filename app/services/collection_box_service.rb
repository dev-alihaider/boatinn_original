# used gem 'kaminari'
class CollectionBoxService
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::FormTagHelper

  attr_reader :controller

  def initialize(selector, params, limit: 30)
    @selector = selector
    # need for UrlHelper
    @controller = params[:controller]
    @params = parse_params(params)
    @limit = limit
    @sortable_fields = {}
    @searchable_fields = {}

  end

  def sortable_fields
    @sortable_fields.keys
  end

  def sortable=(order_fields)
    @sortable_fields = order_fields
  end

  def searchable=(fields_params)
    @searchable_fields = fields_params
    if @params[:finds].blank?
      @params[:finds] = {}
    else
      @params[:finds] = @params[:finds].permit(@searchable_fields.keys)
    end
  end

  def collection
    @collection ||=
      apply_searchable
      apply_sorter
      apply_pagination
      @selector.all
  end

  def path_params(additional_params = {})
    @params.merge(additional_params)
  end

  def sort_path(key)
    url_for(path_params(sort: key, direction: direction_for(key)))
  end

  def sort_link(key, title, attr = {})
    title = current_order_field?(key) ? "#{title} #{order_icon}" : title
    link_to(title.html_safe, sort_path(key), attr)
  end

  def current_page
    @current_page ||= @params[:page].to_i.positive? ? @params[:page].to_i : 1
  end

  def current_order_field
    @sortable_fields.keys.include?(@params[:sort].to_s.to_sym) ? @params[:sort] : nil
  end

  def current_order_field?(field)
    field.to_s == current_order_field
  end

  def current_direction
    @params[:direction] == 'desc' ? 'desc' : 'asc'
  end

  def reverted_direction
    @params[:direction] == 'asc' ? 'desc' : 'asc'
  end

  def order_icon
    icon = current_direction == 'asc' ? 'fa fa-sort-asc' : 'fa fa-sort-desc'
    "<span class='order-direction'><i class='#{icon}'></i></span>"
  end

  def search_field_text_for(key, attr = {})
    text_field_tag "finds[#{key}]", search_value_for(key), attr
  end

  def search_value_for(key)
    @params[:finds][key.to_s.to_sym]
  end

  private

  def apply_sorter
    return unless current_order_field.present?
    @selector = @selector.order("#{@sortable_fields[current_order_field.to_s.to_sym]} #{current_direction}")
  end

  def apply_pagination
    @selector = @selector.page(current_page).per(@limit)
  end

  def apply_searchable
    @searchable_fields.each do |key, attr|
      value = search_value_for(key).to_s.strip.sub(' ', '%')
      next if value.blank?
      if attr[:from_many]
        set_search_from_many(attr, value)
      else
        mask = { key => ("%#{value}%").downcase }
        @selector.where!("LOWER (#{@searchable_fields[key][:field]}) LIKE :#{key}", mask)
      end
    end
  end

  def set_search_from_many(attr, search_text)
    field_select = attr[:relation].keys.first
    field_where_in = attr[:relation].values.first
    search_text = ("%#{search_text}%").downcase
    where_like ="LOWER (#{attr[:field]}) LIKE '#{search_text}'"

    sql =
      if attr[:through]
        field_select2 = attr[:relation].keys.second
        field_where_in2 = attr[:relation].values.second
        sub_sql = attr[:from_many].select(field_select2).where(where_like)
        attr[:through].select(field_select).where(field_where_in2 => sub_sql)
      else
        attr[:from_many].select(field_select).where(where_like)
      end

    @selector = @selector.where(field_where_in => sql)
  end

  # reverted direction for current order field
  def direction_for(key)
    current_order_field?(key) ? reverted_direction : current_direction
  end

  def parse_params(params)
    {
        sort: params[:sort],
        page: params[:page],
        direction: params[:direction],
        action: params[:action],
        controller: params[:controller],
        only_path: true,
        finds: params[:finds] || {}
     }
  end

end

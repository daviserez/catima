# == Schema Information
#
# Table name: containers
#
#  content    :jsonb
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  locale     :string
#  page_id    :integer
#  row_order  :integer
#  slug       :string
#  type       :string
#  updated_at :datetime         not null
#

class Container::ItemList < ::Container
  store_accessor :content, :item_type, :style

  include ItemListsHelper

  validate :style_validation
  validate :sort_validation
  validate :uniqueness_validation

  def custom_container_permitted_attributes
    %i(item_type style sort_field_id sort)
  end

  def render_view(options={})
    catalog = Catalog.find_by(slug: options[:catalog_slug])
    @item_type = catalog.item_types.where(:id => item_type).first!
    @browse = ::ItemList::Filter.new(
      :item_type => @item_type,
      :page => options[:page]
    )
    render_item_list(@browse)
  end

  def describe
    super.merge('content' => { 'item_type' => item_type.nil? ? nil : ItemType.find(item_type).slug })
  end

  def update_from_json(d)
    unless d[:content].nil?
      it = catalog.item_types.find_by(slug: d[:content]['item_type'])
      d[:content]['item_type'] = it.id.to_s
    end
    super(d)
  end

  private

  def style_validation
    unless style.empty? || ::ItemList::STYLES.key?(style)
      errors.add :style, "Style not allowed"
    end

    return if sort.empty?

    if style.eql?("line")
      return if Container::Sort.line_choices.key?(sort)

      errors.add :sort, "Option not allowed for this style"
    else
      return unless Container::Sort.field_choices.key?(sort)

      it = ItemType.find(item_type)
      return if it&.field_for_select&.sortable?

      errors.add :sort, "Sort not allowed with current primary field (#{it&.field_for_select&.slug})"
    end
  end

  def sort_validation
    return if sort.empty? || Container::Sort::CHOICES.key?(sort)

    errors.add :sort, "Sort not allowed"
  end

  def uniqueness_validation
    return unless page.containers.where.not(id: id).exists?(type: 'Container::ItemList')

    errors.add :slug, "Multiple ItemList containers in the same page not allowed."
  end
end

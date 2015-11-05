# Wraps the AdvancedSearch ActiveRecord model with all the actual logic for
# performing the search and paginating the results.
#
class Search::Advanced < Search
  include Search::Strategies

  attr_reader :model
  delegate :catalog, :item_type, :criteria, :to => :model
  delegate :fields, :to => :item_type

  def initialize(model:, page:nil, per:nil)
    super(model.catalog, page, per)
    @model = model
  end

  def permit_criteria(params)
    permitted = {}
    strategies.each do |strategy|
      permitted[strategy.field.uuid] = strategy.criteria_keys
    end
    params.permit(:criteria => permitted)
  end

  private

  def unpaginaged_items
    scope = item_type.items
    strategies.each do |strategy|
      scope = strategy.search(scope, field_criteria(strategy.field))
    end
    scope
  end

  def field_criteria(field)
    (criteria || {}).fetch(field.uuid, {})
  end
end

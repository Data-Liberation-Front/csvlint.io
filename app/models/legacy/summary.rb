class LevelSummary
  include Mongoid::Document
  embedded_in :summary
  field :errors_breakdown, type: Hash
  field :warnings_breakdown, type: Hash
  field :info_messages_breakdown, type: Hash
end

class CategorySummary
  include Mongoid::Document
  embedded_in :summary
  field :structure_breakdown, type: Hash
  field :schema_breakdown, type: Hash
  field :context_breakdown, type: Hash
end

class Legacy::Summary
  include Mongoid::Document
  store_in collection: "summaries"
  include Mongoid::Timestamps

  field :sources, type: Integer
  field :states, type: Hash
  field :hosts, type: Hash

  embeds_one :level_summary
  embeds_one :category_summary
end

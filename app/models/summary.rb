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

class Summary
  include Mongoid::Document
  include Mongoid::Timestamps

  field :sources, type: Integer
  field :states, type: Hash
  field :hosts, type: Hash

  embeds_one :level_summary
  embeds_one :category_summary

  def self.generate
    summary = Summary.create

    validations = Validation.where(:url.ne => nil).order_by(:created_at.desc)
    # retrieve validations from Mongo Datastore, ordered in reverse by date created

    summary.sources = validations.length
    summary.states = Hash.new 0
    summary.hosts = Hash.new 0
    summary.create_level_summary( errors_breakdown: Hash.new(0), warnings_breakdown: Hash.new(0), info_messages_breakdown: Hash.new(0) )
    summary.create_category_summary( structure_breakdown: Hash.new(0), schema_breakdown: Hash.new(0), context_breakdown: Hash.new(0) )

    validations.each do |validation|
      summary.states[validation.state] += 1
      host = source_host(validation.url)
      summary.hosts[host] += 1 unless host.nil?
      validator = validation.validator
      messages = []
      [:errors, :warnings, :info_messages].each do |level|
        unless validator.send(level).nil?
          messages = messages + validator.send(level)
          validator.send(level).uniq { |m| m.type }.each do |msg|
            summary.level_summary.send("#{level}_breakdown".to_sym)[ msg.type ] += 1
          end
        end
      end
      [:structure, :schema, :context].each do |category|
        messages.reject {|m| m.category != category }.uniq { |m| m.type }.each do |msg|
          summary.category_summary.send("#{category}_breakdown".to_sym)[ msg.type ] += 1
        end
      end
    end
    summary.save
    summary
  end

  private

  def self.source_host(url)
    host = URI.parse(url.to_s).host
    return if host.nil?
    host.downcase!
    host = host.start_with?('www.') ? host[4..-1] : host
    #TODO better option?
    host.gsub(".", "\uff0e")
  end

end

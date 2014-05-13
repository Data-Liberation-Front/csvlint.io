json.created @summary.created_at
json.sources @summary.sources
json.date_range do
  json.from Validation.first.created_at
  json.to Validation.last.created_at
end
json.results do
  @summary.states.each do |state, count|
    json.set! state, count
  end
end
json.hosts do
  @summary.hosts.each do |host, count|
    json.set! host.gsub("\uff0e", "."), count
  end
end
json.severity do
  [:errors, :warnings, :info_messages].each do |level| 
    json.set! level do
      @summary.level_summary.send("#{level}_breakdown").sort_by{|k,v| v}.reverse.each_with_index do |(type,count), index|
        json.set! type, count        
      end
    end
  end
end
json.category do
  [:structure, :schema, :context].each do |category| 
    json.set! category do
      @summary.category_summary.send("#{category}_breakdown").sort_by{|k,v| v}.reverse.each_with_index do |(type,count), index|
        json.set! type, count        
      end
    end
  end
end


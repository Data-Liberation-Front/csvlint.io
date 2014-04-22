json.version "0.1"
json.licence "http://opendatacommons.org/licenses/odbl/"
json._links do
  json.self validation_index_url(:page => @validations.current_page)
  json.first validation_index_url(:page => 1)
  unless @validations.current_page <= 1
    json.previous validation_index_url(:page => @validations.current_page - 1)
  end
  unless @validations.current_page == @validations.total_pages
    json.next validation_index_url(:page => @validations.next_page)
  end
  json.last validation_index_url(:page => @validations.total_pages)
end
json.validations do
  json.array! @validations, partial: 'validation/validation', as: :validation
end

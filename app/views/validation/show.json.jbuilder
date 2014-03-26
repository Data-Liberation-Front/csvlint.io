json.version "0.1"
json.licence "http://opendatacommons.org/licenses/odbl/"
json.validation do
  json.partial! 'validation/validation', validation: @validation
  json.errors do
    json.array! @result.errors, partial: 'validation/message', as: :message
  end
  json.warnings do
    json.array! @result.warnings, partial: 'validation/message', as: :message
  end
  json.info do
    json.array! @result.info_messages, partial: 'validation/message', as: :message
  end
  json.standardisedCSV validation_url(@validation, "csv")
  json.badges do
    json.svg validation_url(@validation, "svg")
    json.png validation_url(@validation, "png")
  end
end

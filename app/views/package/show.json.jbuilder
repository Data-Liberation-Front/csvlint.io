json.version "0.1"
json.licence "http://opendatacommons.org/licenses/odbl/"
json.package do
  json.validations do
    json.array! @validations, partial: 'validation/validation', as: :validation
  end
end

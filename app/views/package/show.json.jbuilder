json.package do
  json.validations do
    json.array! @validations do |validation|
      json.url validation.url
      json.state validation.state
    end
  end
end

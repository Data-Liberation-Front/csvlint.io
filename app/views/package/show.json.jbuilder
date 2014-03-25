json.package do
  json.array! @validations do |validation|
    json.url validation.url
    json.state validation.state
  end
end
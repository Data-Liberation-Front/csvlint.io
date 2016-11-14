json.package do
  json.id @package.id.to_s
  json.url package_url(@package)
end

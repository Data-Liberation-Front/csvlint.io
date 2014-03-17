module PackageHelper

  def package_type(type)
    case type
    when :datapackage
      "datapackage"
    when :ckan
      "CKAN dataset"
    end
  end

end

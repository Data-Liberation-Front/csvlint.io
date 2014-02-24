module SchemasHelper
  
  def date_type?(field)
    ['http://www.w3.org/2001/XMLSchema#dateTime', 
     'http://www.w3.org/2001/XMLSchema#date', 
     'http://www.w3.org/2001/XMLSchema#time', 
     'http://www.w3.org/2001/XMLSchema#gYear', 
     'http://www.w3.org/2001/XMLSchema#gYearMonth'].include? field.constraints["type"]  
  end
  
  def date_pattern(field)
    return "" unless date_type?(field)
    return field.constraints["datePattern"] if field.constraints["datePattern"]
    return {
      'http://www.w3.org/2001/XMLSchema#dateTime' => "%Y-%m-%dT%H:%M:%SZ",
      'http://www.w3.org/2001/XMLSchema#date' => "%Y-%m-%d",    
      'http://www.w3.org/2001/XMLSchema#time' => "%H:%M:%S", 
      'http://www.w3.org/2001/XMLSchema#gYear' => "%Y", 
      'http://www.w3.org/2001/XMLSchema#gYearMonth' => "%Y-%m"    
    }[ field.constraints["datePattern"] ]
  end
  
  def value_constraints(field)
    field.constraints.reject do |k,v|
      !["minimum", "minLength", "maximum", "maxLength", "pattern"].include?(k)
    end  
  end
  
end

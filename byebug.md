byebug inserted into Validation.check_schema

CASE: valid.csv ++ URL schema

#<Csvlint: : Validator: 0x007fc7e3c9b820@source=#<StringIO: 0x007fc7e3c9b848>,
@formats=[
  {
    : string=>1
  },
  {
    : string=>1
  },
  {
    : string=>1
  }
],
@schema=nil,
@supplied_dialect=false,
@dialect={
  "header"=>true,
  "delimiter"=>",",
  "skipInitialSpace"=>true,
  "lineTerminator"=>: auto,
  "quoteChar"=>"\""
},
@csv_header=true,
@limit_lines=nil,
@csv_options={
  : col_sep=>",",
  : row_sep=>: auto,
  : quote_char=>"\"",
  : skip_blanks=>false,
  : encoding=>nil
},
@extension="",
@errors=[
  #<Csvlint: : ErrorMessage: 0x007fc7e3c98968@type=: invalid_schema,
  @category=: schema,
  @row=nil,
  @column=nil,
  @content=nil,
  @constraints=nil>
],
@warnings=[

],
@info_messages=[
  #<Csvlint: : ErrorMessage: 0x007fc7e3c9b2a8@type=: assumed_header,
  @category=: structure,
  @row=nil,
  @column=nil,
  @content=nil,
  @constraints={

  }>
],
@encoding=nil,
@content_type=nil,
@headers=nil,
@expected_columns=3,
@col_counts=[
  3,
  3
],
@data=[
  [
    "firstname",
    "lastname",
    "status"
  ],
  [
    "Sam",
    "Pikesley",
    "Prawn"
  ],
  nil
],
@line_breaks="\r\n">
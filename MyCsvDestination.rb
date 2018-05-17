require 'rubygems'
require 'write_xlsx'
require 'rubyXL'

class MyCsvDestination

  def initialize(output_file)
    @outputFile = output_file
    @workbook = WriteXLSX.new(output_file)
    @showFileValuesWorksheet = @workbook.add_worksheet
    @tableFormattingWorksheet = @workbook.add_worksheet
  end

  def write(row)
    format = @workbook.add_format
    format.set_bold
    format.set_color('purple')

    columns = row.keys
    column_count = columns.count
    lookupPrefixHashSize =  row[:lookupPrefixHash].keys.count
    puts lookupPrefixHashSize

    (0..column_count-1).each do |column_index|
      unless columns.empty?
        @showFileValuesWorksheet.write(row[:index],  column_index , row.values[column_index], format)
      end
    end

    (0..lookupPrefixHashSize-1).each do |column_index|
      @tableFormattingWorksheet.write("A#{column_index}", row[:lookupPrefixHash].values[column_index])
      # @tableFormattingWorksheet.write( row[:index], column_index, row[:lookupPrefixHash].values[column_index])
      #    @showFileValuesWorksheet.write( "A#{column_index}", row[:lookupPrefixHash].keys[column_index])
    end

    # rubyXlWorkbook = RubyXL::Parser.parse(@outputFile)
    # rubyXlWorksheet = rubyXlWorkbook.worksheets[0]
    # rubyXlWorksheet.delete_column(1)

  end

  def close
    @workbook.close
  end

end
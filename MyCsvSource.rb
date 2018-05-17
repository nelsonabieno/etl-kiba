require 'csv'
require 'roo'


class MyCsvSource
  attr_reader :input_file

  def initialize(input_file)
    @input_file = input_file
  end

  def formatPropertyTableColumn word
    camelizedArray = word.scan(/[A-Z][a-z]+/)
    # camelizedArray = word.underscore #use humanize  word.underscore
    camelizedArray.join('_')
  end

  def formatHashColumn(tableName,code,label)
    "{table: :#{tableName.downcase()}, code: '#{code}', label: '#{label}'}"
  end

  def each
    xlsx = Roo::Excelx.new(@input_file)
    columnA = xlsx.sheet('residential_search_layout').column(1)
    columnB = xlsx.sheet('residential_search_layout').column(2)
    columnC = xlsx.sheet('residential_search_layout').column(3)

    resultArray = []
    prefixArray = []
    count = 0
    statusArray = %w[ active active under-contract sold withdrawn expired temporarily-off-market rented ]

    lookupPrefixHash = {  :construction_type =>   'constype',
                          :cooling_type =>  'cooltype',
                          :fireplace_type =>  'fireplace',
                          :heating_type =>  'heating',
                          :interior_feature =>  'interior',
                          :land_type =>  'land',
                          :mls_area =>  'area',
                          :parking_type =>  'parking',
                          :roof_type =>  'roof',
                          :sewer_type =>  'sewer',
                          :water_source =>  'water',
                          :property_status =>  'status'
                      }

    columnA.each_with_index  do |row, index|

      count = count + 1

      # unless (columnA[index].to_s.strip.empty?) && (columnC[index] == columnC[index-1])
      #   count = 0
      # end
      # puts "'#{columnC[index] columnC[index-1]}'"


      if  (columnA[index].to_s.strip.empty?) && (columnC[index] != columnC[index - 2])
        count = 0
      end

      unless columnA[index].nil?
        prefixArray.push(columnA[index])
      end

      unless columnB[index].nil?
         resultArray.push( "#{prefixArray.last} - #{columnB[index]}")
      end

      unless columnC[index].nil?

        getPropertyTableCol = formatPropertyTableColumn (columnC[index])

        propertyTableColLower =  getPropertyTableCol.downcase()

        lookupPrefix = if lookupPrefixHash.include?  propertyTableColLower
                         lookupPrefixHash[propertyTableColLower]
                       else
                         "#{columnC[index]}"
                       end

        getFormattedHash = formatHashColumn(
            getPropertyTableCol,
            "#{lookupPrefix.downcase}#{index+1}",
            columnB[index]
        )

        if columnC[index] == "PropertyStatus"
          propertyTableColLower = lookupPrefixHash["property_status"]
        end

        # puts count
        yield({
                index: index,
                row: "#{prefixArray.last} - #{columnB[index]}",
                propertyTableColumn: columnC[index],
                DatabaseTableName: propertyTableColLower,
                lookupCode: "#{lookupPrefix.downcase}#{count+1}",
                formatHashColumn: getFormattedHash,
                lookupPrefixHash: lookupPrefixHash
              })
      end
    end

  end
end
module RelatonIsoBib
  # Iso ICS classificator.
  class Ics < Isoics::ICS
    # @param code [String, NilClass]
    # @param field [Integer, NilClass]
    # @param group [Integer, NilClass]
    # @param subgroup [Integer, NilClass]
    def initialize(code = nil, field: nil, group: nil, subgroup: nil)
      unless code || field
        raise ArgumentError, "wrong arguments (should be string or { fieldcode: [String] }"
      end

      field, group, subgroup = code.split '.' if code
      super fieldcode: field, groupcode: group, subgroupcode: subgroup
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.ics do
        builder.code code
        builder.text_ description
      end
    end
  end
end
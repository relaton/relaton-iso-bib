module RelatonIsoBib
  # Iso ICS classificator.
  class Ics < Isoics::ICS
    # @param code [String, NilClass]
    # @param field [Integer, NilClass]
    # @param group [Integer, NilClass]
    # @param subgroup [Integer, NilClass]
    def initialize(code = nil, field: nil, group: nil, subgroup: nil)
      unless code || field
        raise ArgumentError,
              "wrong arguments (should be string or { fieldcode: [String] }"
      end

      field, group, subgroup = code.split "." if code
      super fieldcode: field, groupcode: group, subgroupcode: subgroup
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.ics do
        builder.code code
        builder.text_ description
      end
    end

    # @return [Hash]
    def to_hash
      hash = {}
      hash["code"] = code if code
      hash["text"] = description if description
      hash
    end

    # @param prefix [String]
    # @param count [Integer] number of ICS
    # @return [String]
    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? prefix : prefix + "."
      pref += "ics"
      out = count > 1 ? "#{pref}::\n" : ""
      out += "#{pref}.code:: #{code}\n"
      out += "#{pref}.description:: #{description}\n"
      out
    end
  end
end

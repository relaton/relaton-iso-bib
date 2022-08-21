module RelatonIsoBib
  # Document structured identifier.
  class StructuredIdentifier
    # @return [Integer, nil]
    attr_reader :tc_document_number

    # @return [String]
    attr_reader :project_number

    # @return [Integer, nil]
    attr_reader :part

    # @return [Integer, nil]
    attr_reader :subpart

    # @return [String, nil]
    attr_reader :type

    # @param tc_document_number [Integer, nil]
    # @param project_number [String]
    # @param part [String, nil]
    # @param subpart [String, nil]
    # @param type [String, nil]
    def initialize(**args)
      @tc_document_number = args[:tc_document_number]
      @project_number = args[:project_number]
      @part = args[:part]
      @subpart = args[:subpart]
      @type = args[:type]
    end

    # in docid manipulations, assume ISO as the default: id-part:year
    def remove_part
      @part = nil
      @subpart = nil
      @project_number = case @type
                        when "Chinese Standard"
                          @project_number.sub(/\.\d+/, "")
                        else
                          @project_number = @project_number.sub(/-\d+/, "")
                        end
    end

    def remove_date
      if @type == "Chinese Standard"
        @project_number.sub!(/-[12]\d\d\d/, "")
      else
        @project_number.sub!(/:[12]\d\d\d/, "")
      end
    end

    def all_parts
      @project_number = "#{@project_number} (all parts)"
    end

    def id
      project_number
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder) # rubocop:disable Metrics/AbcSize
      xml = builder.structuredidentifier do
        pn = builder.send :"project-number", project_number
        pn[:part] = part if part
        pn[:subpart] = subpart if subpart
        if tc_document_number
          builder.send :"tc-document-number", tc_document_number
        end
      end
      xml[:type] = type if type
    end

    # @return [Hash]
    def to_hash # rubocop:disable Metrics/AbcSize
      hash = {}
      hash["tc_document_number"] = tc_document_number if tc_document_number
      hash["project_number"] = project_number if project_number
      hash["part"] = part if part
      hash["subpart"] = subpart if subpart
      hash["type"] = type if type
      hash
    end

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix = "") # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      pref = prefix.empty? ? prefix : "#{prefix}."
      pref += "structured_identifier"
      out = ""
      if tc_document_number
        out += "#{pref}.tc_document_number:: #{tc_document_number}\n"
      end
      if project_number
        out += "#{pref}.project_number:: #{project_number}\n"
      end
      out += "#{pref}.part:: #{part}\n" if part
      out += "#{pref}.subpart:: #{subpart}\n" if subpart
      out += "#{pref}.type:: #{type}\n" if type
      out
    end

    def presence?
      true
    end
  end
end

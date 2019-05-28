module RelatonIsoBib
  # Document structured identifier.
  class StructuredIdentifier
    # @return [Integer, NilClass]
    attr_reader :tc_document_number

    # @return [String]
    attr_reader :project_number

    # @return [Integer, NilClass]
    attr_reader :part

    # @return [Integer, NilClass]
    attr_reader :subpart

    # @return [String, NilClass]
    attr_reader :type

    # @param tc_document_number [Integer, NilClass]
    # @param project_number [String]
    # @param part [String, NilClass]
    # @param subpart [String, NilClass]
    # @param type [String, NilClass]
    def initialize(**args)
      @tc_document_number = args[:tc_document_number]
      @project_number = args[:project_number]
      @part = args[:part]
      @subpart = args[:subpart]
      @prefix = args[:prefix]
      @type = args[:type]
    end

    # in docid manipulations, assume ISO as the default: id-part:year
    def remove_part
      @part_number = nil
      @subpart_number = nil
      case @type
      when "Chinese Standard" then @project_number = @project_number.sub(/\.\d+/, "")
      else
        @project_number = @project_number.sub(/-\d+/, "")
      end
    end

    def remove_date
      case @type
      when "Chinese Standard" then @project_number = @project_number.sub(/-[12]\d\d\d/, "")
      else
        @project_number = @project_number.sub(/:[12]\d\d\d/, "")
      end
    end

    def all_parts
      @project_number = @project_number + " (all parts)"
    end

    def id
      project_number
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      xml = builder.structuredidentifier do
        pn = builder.send "project-number", project_number
        pn[:part] = part if part
        pn[:subpart] = subpart if subpart
        builder.send "tc-document-number", tc_document_number if tc_document_number
      end
      xml[:type] = type if type
    end
  end
end

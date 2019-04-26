module RelatonIso
  # Iso document id.
  class IsoDocumentId
    # @return [Integer]
    attr_reader :tc_document_number

    # @return [String]
    attr_reader :project_number

    # @return [String]
    attr_reader :part_number

    # @return [String]
    attr_reader :subpart_number

    # @return [String]
    attr_reader :id

    # @return [String]
    attr_reader :prefix

    # @return [String]
    attr_reader :type

    # @param project_number [String]
    # @param part_number [String]
    # @param subpart_number [String]
    # @param prefix [String]
    # @param id [String]
    # @param type [String]
    def initialize(**args)
      @project_number = args[:project_number]
      @part_number    = args[:part_number]
      @subpart_number = args[:subpart_number]
      @prefix         = args[:prefix]
      @type           = args[:type]
      @id             = args[:id]
    end

    # in docid manipulations, assume ISO as the default: id-part:year
    def remove_part
      @part_number = nil
      @subpart_number = nil
      case @type
      when "Chinese Standard" then @id = @id.sub(/\.\d+/, "")
      else 
        @id = @id.sub(/-\d+/, "")
      end
    end

    def remove_date
      case @type
      when "Chinese Standard" then @id = @id.sub(/-[12]\d\d\d/, "")
      else
        @id = @id.sub(/:[12]\d\d\d/, "")
      end
    end

    def all_parts
      @id = @id + " (all parts)"
    end

    def to_xml(builder)
      attrs = {}
      attrs[:type] = @type if @type
      # builder.docidentifier project_number + '-' + part_number, **attrs
      builder.docidentifier id, **attrs
    end
  end
end
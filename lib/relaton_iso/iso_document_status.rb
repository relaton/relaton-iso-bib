# frozen_string_literal: true

module RelatonIso
  # ISO Document status.
  class IsoDocumentStatus < RelatonBib::DocumentStatus
    STAGE_CODES = %w[00 10 20 30 40 50 60 95]
    SUBSTAGE_CODES = %w[00 20 60 90 92 93 98 99]

    # @return [String, NilClass]
    attr_reader :stage

    # @return [String, NilClass]
    attr_reader :substage

    # @return [Integer, NilClass]
    attr_reader :iteration

    # @param status [String, NilClass]
    # @param stage [String, NilClass]
    # @param substage [String, NilClass]
    # @param iteration [Integer, NilClass]
    def initialize(status: nil, stage: nil, substage: nil, iteration: nil)
      raise ArgumentError, "status or stage is required" unless status || stage

      if stage && !STAGE_CODES.include?(stage)
        raise ArgumentError, "invalid stage: #{stage}"
      end

      if substage && !SUBSTAGE_CODES.include?(substage)
        raise ArgumentError, "invalid substage: #{substage}"
      end

      super RelatonBib::LocalizedString.new(status)
      @stage     = stage
      @substage  = substage
      @iteration = iteration
    end

    # @param builder [Nkogiri::XML::Builder]
    def to_xml(builder)
      if stage.nil? || stage.empty?
        super
      else
        builder.status do
          builder.stage stage
          builder.substage substage if substage
          builder.iteration iteration if iteration
        end
      end
    end
  end
end

module RelatonIsoBib
  class DocumentType < RelatonBib::DocumentType
    DOCTYPES = %w[
      international-standard technical-specification technical-report
      publicly-available-specification international-workshop-agreement guide
      recommendation amendment technical-corrigendum directive committee-document addendum
    ].freeze

    #
    # Create a new DocumentType object.
    #
    # @param [String] type document type
    # @param [String, nil] abbreviation type abbreviation
    #
    def initialize(type:, abbreviation: nil)
      check_doctype type
      super
    end

    #
    # Check if type is valid.
    #
    # @param [String] type document type
    #
    def check_doctype(type)
      unless DOCTYPES.include? type
        Util.warn "Invalid doctype: `#{type}`"
        Util.warn "Allowed doctypes are: `#{DOCTYPES.join('`, `')}`"
      end
    end
  end
end

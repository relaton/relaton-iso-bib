module RelatonIsoBib
  class TypedTitleString < RelatonBib::TypedTitleString
    # TITLE_TYPES = %w[title-main title-intro title-part main].freeze

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength

    # @param type [String]
    # @param title [RelatonBib::FormattedString, Hash]
    # @param content [String]
    # @param language [String]
    # @param script [String]
    def initialize(**args)
      # if args[:type] && !TITLE_TYPES.include?(args[:type])
      #   raise ArgumentError, %{The type #{args[:type]} is invalid.}
      # end

      unless args[:title] || args[:content]
        raise ArgumentError, %{Keyword "title" or "content" should be passed.}
      end

      @type = args[:type]

      if args[:title]
        @title = args[:title]
      else
        fsargs = args.select { |k, _v| %i[content language script format].include? k }
        @title = RelatonBib::FormattedString.new(fsargs)
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end

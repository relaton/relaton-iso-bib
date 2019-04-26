# frozen_string_literal: true

module RelatonIso
  # ISO localized string.
  class IsoLocalizedTitle
    # @return [RelatonBib::FormattedString]
    attr_reader :title_intro

    # @return [RelatonBib::FormattedString]
    attr_reader :title_main

    # @return [RelatonBib::FormattedString]
    attr_reader :title_part

    # @return [String] language code Iso639
    attr_reader :language

    # @return [String] script code Iso15924
    attr_reader :script

    # @param title_intro [String]
    # @param title_main [String]
    # @param title_part [String]
    # @param language [String] language Iso639 code
    # @param script [String] script Iso15924 code
    def initialize(title_intro:, title_main:, title_part: nil, language:,
                   script:)
      @title_intro = RelatonBib::FormattedString.new(
        content: title_intro, language: language, script: script, format: "text/plain"
      )
      # "[ -- ]" # title cannot be nil
      main = title_main
      main = '[ -- ]' if title_main.nil? || title_main.empty?
      @title_main  = RelatonBib::FormattedString.new(
        content: main, language: language, script: script, format: "text/plain"
      )
      @title_part  = RelatonBib::FormattedString.new(
        content: title_part, language: language, script: script, format: "text/plain"
      )
      @language    = language
      @script      = script
    end

    def remove_part
      @title_part = nil
    end

    # @return [String]
    def to_s
      ret = @title_main.to_s
      ret = "#{@title_intro} -- #{ret}" if @title_intro && !@title_intro.empty?
      ret = "#{ret} -- #{@title_part}" if @title_part && !@title_part.empty?
      ret
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      # builder.title(format: 'text/plain', language: language, script: script) do
      #   builder.text to_s
      # end
      builder.title do
        builder.send("title-intro") { title_intro.to_xml builder } if title_intro
        builder.send("title-main") { title_main.to_xml builder }
        builder.send("title-part") { title_part.to_xml builder } if title_part
      end
    end
  end
end

# frozen_string_literal: false

require "relaton_iso_bib/editorial_group"
require "relaton_iso_bib/xml_parser"
require "relaton_iso_bib/structured_identifier"
require "relaton_iso_bib/ics"
require "relaton_iso_bib/hash_converter"

module RelatonIsoBib
  # Bibliographic item.
  class IsoBibliographicItem < RelatonBib::BibliographicItem
    SUBDOCTYPES = %w[specification method-of-test vocabulary code-of-practice].freeze

    # @return [RelatonIsoBib::StructuredIdentifier]
    attr_reader :structuredidentifier

    # @return [String, nil]
    attr_reader :stagename, :price_code

    # @!attribute [r] subdoctype
    #  @return [RelatonIsoBib::DocumentType]

    # @return [Boolean, nil]
    attr_reader :horizontal, :fast_track

    # @return [RelatonIsoBib::EditorialGroup]
    attr_reader :editorialgroup

    # @return [Array<RelatonIsoBib::Ics>]
    attr_reader :ics

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity

    # @param edition [String]
    # @param docnumber [String, nil]
    # @param language [Array<String>]
    # @param script [Arrra<String>]
    # @param docstatus [RelatonBib::DocumentStatus, nil]
    # @param type [String, nil]
    # @param formattedref [RelatonBib::FormattedRef, nil]
    # @param version [RelatonBib::BibliographicItem::Version, nil]
    # @param biblionote [Array<RelatonBib::BiblioNote>]
    # @param series [Array<RelatonBib::Series>]
    # @param medium [RelatonBib::Medium, NilClas]
    # @param place [Array<String>]
    # @param extent [Array<Relaton::BibItemLocality>]
    # @param accesslocation [Array<String>]
    # @param classification [RelatonBib::Classification, nil]
    # @param validity [RelatonBib:Validity, nil]
    # @param docid [Array<RelatonBib::DocumentIdentifier>]
    # @param doctype [RelatonIsoBib::DocumentType]
    # @param subdoctype [String, nil]
    # @param horizontal [Boolean, nil]
    # @param structuredidentifier [RelatonIsoBib::StructuredIdentifier]
    # @param stagename [String, nil]
    # @param fast_track [Boolean, nil]
    # @param title [Array<Hash, RelatonBib::TypedTitleString>, RelatonBib::TypedTitleStringCollection]
    # @param price_code [String, nil]
    #
    # @param editorialgroup [Hash, RelatonIsoBib::EditorialGroup]
    # @option workgrpup [String] :name
    # @option workgrpup [String] :abbreviation
    # @option workgrpup [String] :url
    # @option workgrpup [Hash] :technical_committee
    # @option technical_committee [String] :name
    # @option technical_committee [String] :type
    # @option technical_committee [Integer] :number
    #
    # @param ics [Array<Hash>]
    # @option ics [Integer] :field
    # @option ics [Integer] :group
    # @option ics [Integer] :subgroup
    #
    # @param date [Array<Hash>]
    # @option date [String] :type
    # @option date [String] :from
    # @option date [String] :to
    #
    # @param abstract [Array<Hash>]
    # @option abstract [String] :content
    # @option abstract [String] :language
    # @option abstract [String] :script
    # @option abstract [String] :type
    #
    # @param contributor [Array<Hash>]
    # @option contributor [Hash] :entity
    # @option entity [String] :name
    # @option entity [String] :url
    # @option entity [String] :abbreviation
    # @option contributor [Array<String>] :role
    #
    # @param copyright [Hash]
    # @option copyright [Hash] :owner
    # @option owner [String] :name
    # @option owner [String] :abbreviation
    # @option owner [String] :url
    # @option copyright [String] :from
    # @option copyright [String] :to
    #
    # @param link [Array<Hash, RelatonBib::TypedUri>]
    # @option link [String] :type
    # @option link [String] :content
    #
    # @param relation [Array<Hash>]
    # @option relation [String] :type
    # @option relation [RelatonIsoBib::IsoBibliographicItem] :bibitem
    # @option relation [Array<RelatonBib::BibItemLocality>] :bib_locality
    #
    # @raise [ArgumentError]
    def initialize(**args)
      args[:type] ||= "standard"
      arg_names = %i[
        id title docnumber language script docstatus date abstract contributor
        edition version relation biblionote series medium place copyright link
        fetched docid formattedref extent accesslocation classification validity
        editorialgroup doctype keyword type
      ]
      super_args = args.select { |k| arg_names.include? k }
      super(**super_args)

      if args[:editorialgroup]
        @editorialgroup = if args[:editorialgroup].is_a?(Hash)
                            EditorialGroup.new(**args[:editorialgroup])
                          else args[:editorialgroup]
                          end
      end

      if args[:subdoctype] && !self.class::SUBDOCTYPES.include?(args[:subdoctype])
        Util.warn "Invald subdoctype `#{args[:subdoctype]}`. Allowed values are: #{self.class::SUBDOCTYPES.join(', ')}"
      end
      @subdoctype = args[:subdoctype]
      @structuredidentifier = args[:structuredidentifier]
      @horizontal = args[:horizontal]
      @ics = args.fetch(:ics, []).map { |i| i.is_a?(Hash) ? Ics.new(**i) : i }
      @stagename = args[:stagename]
      @id_attribute = true
      @fast_track = args[:fast_track]
      @price_code = args[:price_code] if args.key? :price_code # @TODO: remove `if` when all users update relaton-iec
    end

    #
    # Fetch the flavour schema version
    #
    # @return [String] flavour schema version
    #
    def ext_schema
      @ext_schema ||= schema_versions["relaton-model-iso"]
    end

    #
    # Render the document as an XML string.
    #
    # @param opts [Hash] options
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [Boolean] :bibdata if true, bibdata element is created
    # @option opts [Boolean] :embedded if true the document is embedded in another document
    # @option opts [String] :lang language
    #
    # @return [String] XML
    #
    def to_xml(**opts)
      super(**opts) do |b|
        if block_given? then yield b
        elsif opts[:bibdata] && has_ext?
          ext = b.ext do
            doctype.to_xml b if doctype
            b.subdoctype subdoctype if subdoctype
            b.horizontal horizontal unless horizontal.nil?
            editorialgroup&.to_xml b
            ics.each { |i| i.to_xml b }
            structuredidentifier&.to_xml b
            b.stagename stagename if stagename
            b.send("fast-track", fast_track) unless fast_track.nil?
            b.send("price-code", price_code) if price_code
          end
          ext["schema-version"] = ext_schema unless opts[:embedded]
        end
      end
    end

    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    #
    # Render the document as HASH
    #
    # @param embedded [Boolean] true if the bibitem is embedded in another bibitem
    #
    # @return [Hash] the document as HAS
    #
    def to_hash(embedded: false)
      hash = super
      hash["ext"]["horizontal"] = horizontal unless horizontal.nil?
      hash["ext"]["stagename"] = stagename if stagename
      hash["ext"]["fast_track"] = fast_track unless fast_track.nil?
      hash["ext"]["price_code"] = price_code if price_code
      hash
    end

    def has_ext?
      super || horizontal || stagename || fast_track || price_code
    end

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix = "")
      pref = prefix.empty? ? prefix : "#{prefix}."
      out = super
      out += "#{pref}stagename:: #{stagename}\n" if stagename
      out += "#{pref}fast-track:: #{fast_track}\n" unless fast_track.nil?
      out
    end

    private

    def makeid(id, attribute, _delim = "") # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/AbcSize
      return nil if attribute && !@id_attribute

      id ||= @docidentifier.reject { |i| i&.type == "DOI" }[0]
      if id
        idstr = id.id
        idstr = "IEV" if structuredidentifier&.project_number == "IEV"
      else
        idstr = formattedref&.content
      end
      idstr&.gsub(/:/, "-")&.gsub(/\s/, "")&.strip
    end

    #
    # @return [Boolean]
    #
    def has_ext? # rubocop:disable Metrics/CyclomaticComplexity
      super || !horizontal.nil? || ics&.any? || stagename || !fast_track.nil? || price_code
    end
  end
end

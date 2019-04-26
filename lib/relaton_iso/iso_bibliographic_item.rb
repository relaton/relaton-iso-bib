# frozen_string_literal: false

require "nokogiri"
require "isoics"
require "deep_clone"
require "relaton_bib"
require "relaton_iso/iso_document_status"
require "relaton_iso/iso_localized_title"
require "relaton_iso/iso_project_group"
require "relaton_iso/xml_parser"
require "relaton_iso/iso_document_relation"
require "relaton_iso/iso_document_id"
require "relaton_iso/ics"

# Add filter method to Array.
class Array
  def filter(type:)
    select { |e| e.type == type }
  end
end

module RelatonIso
  # Bibliographic item.
  class IsoBibliographicItem < RelatonBib::BibliographicItem
    TYPES = %w[international-standard technical-specification technical-report
      publicly-available-specification international-workshop-agreement guide]

    # @return [Array<RelatonIso::IsoDocumentId>]
    attr_reader :docidentifier

    # @!attribute [r] title
    #   @return [Array<RelatonIso::IsoLocalizedTitle>]

    # @return [RelatonIso::IsoDocumentType]
    attr_reader :type

    # @return [RelatonIso::IsoDocumentStatus]
    attr_reader :status

    # @return [RelatonIso::IsoProjectGroup]
    attr_reader :workgroup

    # @return [Array<RelatonIso::Ics>]
    attr_reader :ics

    # @param edition [String]
    # @param docnumber [String, NilClass]
    # @param language [Array<String>]
    # @param script [Arrra<String>]
    # @param type [String]
    # @param formattedref [RelatonBib::FormattedRef, NilClass]
    # @param version [RelatonBib::BibliographicItem::Version, NilClass]
    # @param series [Array<RelatonBib::Series>]
    # @param medium [RelatonBib::Medium, NilClas]
    # @param place [Array<String>]
    # @param extent [Array<Relaton::BibItemLocality>]
    # @param accesslocation [Array<String>]
    # @param classification [RelatonBib::Classification, NilClass]
    # @param validity [RelatonBib:Validity, NilClass]
    #
    # @param docid [Hash, RelatonIso::IsoDocumentId]
    # @opotion docid [Integer] :project_number
    # @opotion docid [Integer] :part_number
    # @opotion docid [String] :prefix
    #
    # @param titles [Array<Hash>]
    # @option title [String] :title_intro
    # @option title [String] :title_main
    # @option title [String] :title_part
    # @option title [String] :language
    # @option title [String] :script
    #
    # @param docstatus [Hash]
    # @option docstatus [String] :status
    # @option docstatus [String] :stage
    # @option docstatus [String] :substage
    #
    # @param workgroup [Hash, RelatonIso::IsoProjectGroup]
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
    # @param dates [Array<Hash>]
    # @option dates [String] :type
    # @option dates [String] :from
    # @option dates [String] :to
    #
    # @param abstract [Array<Hash>]
    # @option abstract [String] :content
    # @option abstract [String] :language
    # @option abstract [String] :script
    # @option abstract [String] :type
    #
    # @param contributors [Array<Hash>]
    # @option contributors [Hash] :entity
    # @option entity [String] :name
    # @option entity [String] :url
    # @option entity [String] :abbreviation
    # @option contributors [Array<String>] :roles
    #
    # @param copyright [Hash]
    # @option copyright [Hash] :owner
    # @option owner [String] :name
    # @option owner [String] :abbreviation
    # @option owner [String] :url
    # @option copyright [String] :from
    # @option copyright [String] :to
    #
    # @param link [Array<Hash, RelatonIso::TypedUri>]
    # @option link [String] :type
    # @option link [String] :content
    #
    # @param relations [Array<Hash>]
    # @option relations [String] :type
    # @option relations [RelatonIso::IsoBibliographicItem] :bibitem
    # @option relations [Array<RelatonBib::BibItemLocality>] :bib_locality
    def initialize(**args)
      if args[:type] && !TYPES.include?(args[:type])
        raise ArgumentError, "invalid type: #{args[:type]}"
      end

      args.fetch(:language, []).each do |lang|
        raise ArgumentError, "invalid language: #{lang}" unless %w[en fr].include? lang
      end

      args.fetch(:script, []).each do |scr|
        raise ArgumentError, "invalid script: #{scr}" unless scr == "Latn"
      end

      super_args = args.select do |k|
        %i[id docnumber language script dates abstract contributors edition
           version relations series medium place copyright link fetched
           formattedref extent accesslocation classification validity].include? k
      end
      super(super_args)

      args[:docid] = [args[:docid]] if args[:docid] && !args[:docid].is_a?(Array)
      @docidentifier = args.fetch(:docid, []).map do |t|
        t.is_a?(Hash) ? IsoDocumentId.new(t) : t
      end

      @title   = args.fetch(:titles, []).map do |t|
        t.is_a?(Hash) ? IsoLocalizedTitle.new(t) : t
      end

      @status = if args[:docstatus].is_a?(Hash)
                  IsoDocumentStatus.new(args[:docstatus])
                else args[:docstatus] end

      if args[:workgroup]
        @workgroup = if args[:workgroup].is_a?(Hash)
                       IsoProjectGroup.new(args[:workgroup])
                     else args[:workgroup] end
      end

      @type   = args[:type]
      @ics = args.fetch(:ics, []).map { |i| i.is_a?(Hash) ? Ics.new(i) : i }
      @link = args.fetch(:link, []).map { |s| s.is_a?(Hash) ? RelatonBib::TypedUri.new(s) : s }
      @id_attribute = true
    end

    def disable_id_attribute
      @id_attribute = false
    end

    # remove title part components and abstract  
    def to_all_parts
      me = DeepClone.clone(self)
      me.disable_id_attribute
      @relations << RelatonIso::IsoDocumentRelation.new(
        type: "partOf", bibitem: me,
      )
      @title.each(&:remove_part)
      @abstract = []
      @docidentifier.each(&:remove_part)
      @docidentifier.each(&:all_parts)
      @all_parts = true
    end

    # convert ISO:yyyy reference to reference to most recent
    # instance of reference, removing date-specific infomration:
    # date of publication, abstracts. Make dated reference Instance relation
    # of the redacated document
    def to_most_recent_reference
      me = DeepClone.clone(self)
      me.disable_id_attribute
      @relations << RelatonBib::DocumentRelation.new(type: "instance", bibitem: me)
      @abstract = []
      @dates = []
      @docidentifier.each(&:remove_date)
    end

    # @param lang [String] language code Iso639
    # @return [RelatonIso::IsoLocalizedTitle]
    def title(lang: nil)
      if lang
        @title.find { |t| t.language == lang }
      else
        @title
      end
    end

    # @param type [Symbol] type of url, can be :src/:obp/:rss
    # @return [String]
    def url(type = :src)
      @link.find { |s| s.type == type.to_s }.content.to_s
    end

    # @return [String]
    def to_xml(builder = nil, **opts, &block)
      if builder
        render_xml builder, **opts, &block
      else
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          render_xml xml, **opts, &block
        end.doc.root.to_xml
      end
    end

    private

    # @return [Array<RelatonIso::ContributionInfo>]
    # def publishers
    #   @contributors.select do |c|
    #     c.role.select { |r| r.type == 'publisher' }.any?
    #   end
    # end

    def makeid(id, attribute, delim = '')
      return nil if attribute && !@id_attribute
      id ||= @docidentifier.reject { |i| i&.type == "DOI" }[0]
      #contribs = publishers.map { |p| p&.entity&.abbreviation }.join '/'
      #idstr = "#{contribs}#{delim}#{id.project_number}"
      #idstr = id.project_number.to_s
      if id
        idstr = id.id
        idstr = "IEV" if id.project_number == "IEV"
      else
        idstr = formattedref&.content
      end
      #if id.part_number&.size&.positive? then idstr += "-#{id.part_number}"
      idstr&.gsub(/:/, "-")&.strip
    end

    def xml_attrs(type)
      attrs = {}
      attrs[:type] = type if type
      # attr_id = makeid(nil, true)&.gsub(/ /, "")
      # attrs[:id] = attr_id if attr_id
      attrs
    end

    # @param builder [Nokogiri::XML::Builder]
    def render_xml(builder, **opts)
      builder.send("iso-standard", xml_attrs(type)) do
        builder.fetched fetched if fetched
        formattedref.to_xml builder if formattedref
        title.each { |t| t.to_xml builder }
        link.each { |s| s.to_xml builder }
        docidentifier.each { |i| i.to_xml builder }
        builder.docnumber docnumber if docnumber
        dates.each { |d| d.to_xml builder, opts }
        contributors.each do |c|
          builder.contributor do
            c.role.each { |r| r.to_xml builder }
            c.to_xml builder
          end
        end
        builder.edition edition if edition
        version.to_xml builder if version
        if opts[:note]
          builder.note("ISO DATE: #{opts[:note]}", format: 'text/plain')
        end
        language.each { |l| builder.language l }
        script.each { |s| builder.script s }
        abstract.each { |a| builder.abstract { a.to_xml(builder) } }
        status.to_xml builder if status
        copyright.to_xml builder if copyright
        relations.each { |r| r.to_xml builder }
        series.each { |s| s.to_xml builder } if series
        medium.to_xml builder if medium
        place.each { |pl| builder.place pl }
        extent.each { |e| e.to_xml builder }
        accesslocation.each { |al| builder.accesslocation al }
        classification.to_xml builder if classification
        validity.to_xml builder if validity
        workgroup.to_xml builder if workgroup
        ics.each { |i| i.to_xml builder }
        builder.allparts 'true' if @all_parts
        yield(builder) if block_given?
      end
    end
  end
end

require "nokogiri"

module RelatonIsoBib
  class XMLParser < RelatonBib::XMLParser
    class << self
      private

      # Override RelatonBib::XMLParser.item_data method.
      # @param isoitem [Nokogiri::XML::Element]
      # @returtn [Hash]
      def item_data(isoitem)
        data = super
        ext = isoitem.at "./ext"
        return data unless ext

        hrzt = ext.at("./horizontal")
        data[:horizontal] = hrzt.text == "true" if hrzt
        data[:stagename] = ext.at("./stagename")&.text
        data[:fast_track] = ext.at("./fast-track")&.text
        data[:price_code] = ext.at("./price-code")&.text
        data
      end

      # override RelatonBib::BibliographicItem.bib_item method
      # @param item_hash [Hash]
      # @return [RelatonIsoBib::IsoBibliographicItem]
      def bib_item(item_hash)
        IsoBibliographicItem.new(**item_hash)
      end

      def create_doctype(type)
        DocumentType.new type: type.text, abbreviation: type[:abbreviation]
      end

      # @param ext [Nokogiri::XML::Element]
      # @return [RelatonIsoBib::StructuredIdentifier]
      def fetch_structuredidentifier(ext)
        sid = ext&.at "./structuredidentifier"
        return unless sid

        pn = sid.at "project-number"
        tdn = sid.at "tc-document-number"
        RelatonIsoBib::StructuredIdentifier.new(
          type: sid[:type], project_number: pn.text, part: pn[:part],
          subpart: pn[:subpart], tc_document_number: tdn&.text
        )
      end

      # @TODO Organization doesn't recreated
      # @param ext [Nokogiri::XML::Element]
      # @return [RelatonIsoBib::EditorialGroup]
      def fetch_editorialgroup(ext) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/PerceivedComplexity
        eg = ext&.at("./editorialgroup")
        return unless eg

        tc = eg&.xpath("technical-committee")&.map { |t| iso_subgroup(t) }
        sc = eg&.xpath("subcommittee")&.map { |s| iso_subgroup(s) }
        wg = eg&.xpath("workgroup")&.map { |w| iso_subgroup(w) }
        sr = eg&.at "secretariat"
        EditorialGroup.new(technical_committee: tc, subcommittee: sc,
                           workgroup: wg, secretariat: sr&.text)
      end

      # @param com [Nokogiri::XML::Element]
      # @return [RelatonIsoBib::IsoSubgroup]
      def iso_subgroup(com)
        return nil if com.nil?

        RelatonBib::WorkGroup.new(name: com.text, type: com[:type],
                                  number: com[:number]&.to_i)
      end
    end
  end
end

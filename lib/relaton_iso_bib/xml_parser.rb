require "nokogiri"

module RelatonIsoBib
  class XMLParser < RelatonBib::XMLParser
    class << self
      # Override RelatonBib::XMLParser.form_xml method.
      # @param xml [String]
      # @return [RelatonIsoBib::IsoBibliographicItem]
      def from_xml(xml)
        doc = Nokogiri::XML(xml)
        doc.remove_namespaces!
        isoitem = doc.at "/bibitem|/bibdata"
        if isoitem
          IsoBibliographicItem.new item_data(isoitem)
        else
          warn "[relato-iso-bib] can't find bibitem or bibdata element in the XML"
        end
      end

      private

      # Override RelatonBib::XMLParser.item_data method.
      # @param isoitem [Nokogiri::XML::Element]
      # @returtn [Hash]
      def item_data(isoitem)
        data = super
        ext = isoitem.at "./ext"
        return data unless ext

        data[:doctype] = ext.at("./doctype")&.text
        data[:editorialgroup] = fetch_editorialgroup ext
        data[:ics] = fetch_ics ext
        data[:structuredidentifier] = fetch_structuredidentifier ext
        data
      end

      # @param ext [Nokogiri::XML::Element]
      # @return [RelatonIsoBib::StructuredIdentifier]
      def fetch_structuredidentifier(ext)
        sid = ext.at "./structuredidentifier"
        return unless sid

        pn = sid.at "project-number"
        tdn = sid.at "tc-document-number"
        RelatonIsoBib::StructuredIdentifier.new(
          type: sid[:type], project_number: pn.text, part: pn[:part],
          subpart: pn[:subpart], tc_document_number: tdn&.text
        )
      end

      # Override RelatonBib::XMLParser.ttitle method.
      # @param title [Nokogiri::XML::Element]
      # @return [RelatonIsoBib::TypedTitleString]
      def ttitle(title)
        return unless title

        TypedTitleString.new(
          type: title[:type], content: title.text, language: title[:language],
          script: title[:script], format: title[:format]
        )
      end

      # @param item [Nokogiri::XML::Element]
      # @return [Array<RelatonIsoBib::Ics>]
      def fetch_ics(ext)
        ext.xpath("./ics/code").map { |ics| Ics.new ics.text }
      end

      # @TODO Organization doesn't recreated
      # @param ext [Nokogiri::XML::Element]
      # @return [RelatonIsoBib::EditorialGroup]
      def fetch_editorialgroup(ext)
        eg = ext.at("./editorialgroup")
        return unless eg

        tc = eg&.xpath("technical-committee")&.map { |t| iso_subgroup(t) }
        sc = eg&.xpath("subcommittee")&.map { |s| iso_subgroup(s) }
        wg = eg&.xpath("workgroup")&.map { |w| iso_subgroup(w) }
        sr = eg&.at "secretariat"
        EditorialGroup.new(
          technical_committee: tc, subcommittee: sc, workgroup: wg, secretariat: sr&.text,
        )
      end

      # @param com [Nokogiri::XML::Element]
      # @return [RelatonIsoBib::IsoSubgroup]
      def iso_subgroup(com)
        return nil if com.nil?

        IsoSubgroup.new(name: com.text, type: com[:type],
                        number: com[:number]&.to_i)
      end
    end
  end
end

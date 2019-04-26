require "nokogiri"

module RelatonIso
  class XMLParser < RelatonBib::XMLParser
    class << self
      def from_xml(xml)
        doc = Nokogiri::XML(xml)
        isoitem = doc.at "/iso-standard"
        IsoBibliographicItem.new( 
          type:           isoitem[:type],
          fetched:        isoitem.at("./fetched")&.text,
          titles:         fetch_titles(isoitem),
          link:           fetch_link(isoitem),
          docid:          fetch_docid(isoitem),
          docnumber:      isoitem.at("./docnumber")&.text,
          dates:          fetch_dates(isoitem),
          contributors:   fetch_contributors(isoitem),
          edition:        isoitem.at("./edition")&.text,
          version:        fetch_version(isoitem),
          biblionote:     fetch_note(isoitem),
          language:       isoitem.xpath("./language").map(&:text),
          script:         isoitem.xpath("./script").map(&:text),
          abstract:       fetch_abstract(isoitem),
          docstatus:      fetch_status(isoitem),
          copyright:      fetch_copyright(isoitem),
          relations:      fetch_relations(isoitem),
          series:         fetch_series(isoitem),
          medium:         fetch_medium(isoitem),
          place:          isoitem.xpath("./place").map(&:text),
          extent:         fetch_extent(isoitem),
          accesslocation: isoitem.xpath("./accesslocation").map(&:text),
          classification: fetch_classification(isoitem),
          validity:       fetch_validity(isoitem),
          ics:            fetch_ics(isoitem),
          workgroup:      fetch_workgroup(isoitem),
        )
      end

      private

      def get_id(did)
        did.text.match(/^(?<project>.*?\d+)(?<hyphen>-)?(?(<hyphen>)(?<part>\d*))/)
      end

      def fetch_docid(item)
        ret = []
        item.xpath("./docidentifier").each do |did|
          #did = doc.at('/iso-standard/docidentifier')
          type = did.at("./@type")
          if did.text == "IEV" then ret << RelatonIso::IsoDocumentId.new(project_number: "IEV", part_number: nil, prefix: nil)
          else
            id = get_id did
            ret << RelatonIso::IsoDocumentId.new(project_number: id.nil? ? did.text : id[:project],
                                                 part_number:    (id.nil? || !id.names.include?("part")) ? nil : id[:part],
                                                 prefix:         nil,
                                                 id:             did.text,
                                                 type:           type&.text)
          end
        end
        ret
      end

      def fetch_titles(item)
        item.xpath("./title").map do |t|
          # titl = t.text.sub("[ -- ]", "").split " -- "
          # case titl.size
          # when 0
          #   intro, main, part = nil, "", nil
          # when 1
          #   intro, main, part = nil, titl[0], nil
          # when 2
          #   if /^(Part|Partie) \d+:/.match titl[1]
          #     intro, main, part = nil, titl[0], titl[1]
          #   else
          #     intro, main, part = titl[0], titl[1], nil
          #   end
          # when 3
          #   intro, main, part = titl[0], titl[1], titl[2]
          # else
          #   intro, main, part = titl[0], titl[1], titl[2..-1]&.join(" -- ")
          # end
          intro = t.at "title-intro"
          main = t.at "title-main"
          part = t.at "title-part"
          IsoLocalizedTitle.new(
            title_intro: intro&.text, title_main: main&.text, title_part: part&.text,
            language: intro[:language], script: intro[:script]
          )
        end
      end

      def fetch_status(item)
        status = item.at "./status"
        return unless status

        stage     = status&.at("stage")&.text
        substage  = status&.at("substage")&.text
        iteration = status&.at("iterarion")&.text&.to_i
        IsoDocumentStatus.new(status: status&.text, stage: stage,
                              substage: substage, iteration: iteration)
      end

      def fetch_ics(item)
        item.xpath('./ics/code').map { |ics| Ics.new ics.text }
      end

      # @TODO Organization doesn't recreated
      def fetch_workgroup(item)
        eg = item.at("./editorialgroup")
        tc = eg&.xpath("technical_committee").map { |t| iso_subgroup(t) }
        sc = eg&.xpath("subcommittee").map { |s| iso_subgroup(s) }
        wg = eg&.xpath("workgroup").map { |w| iso_subgroup(w) }
        IsoProjectGroup.new(technical_committee: tc, subcommittee: sc, workgroup: wg)
      end

      def iso_subgroup(com)
        return nil if com.nil?
        IsoSubgroup.new(name: com.text, type: com[:type],
                        number: com[:number].to_i)
      end

      def fetch_relations(item)
        item.xpath("./relation").map do |r|
          localities = r.xpath("./locality").map do |l|
            ref_to = (rt = l.at("./referenceTo")) ? RelatonBib::LocalizedString.new(rt.text) : nil
            RelatonBib::BibItemLocality.new(
              l[:type],
              RelatonBib::LocalizedString.new(l.at("./referenceFrom").text),
              ref_to
            )
          end
          relitem = r.at "./iso-standard"
          identifier = relitem&.at("./formattedref | ./docidentifier")&.text
          fref = RelatonBib::FormattedRef.new(content: identifier)
          RelatonIso::IsoDocumentRelation.new(
            type: r[:type],
            bibitem: IsoBibliographicItem.new(
              type: relitem[:type], formattedref: fref, docstatus: fetch_status(relitem)
            ),
            bib_locality: localities,
          )
        end
      end
    end
  end
end

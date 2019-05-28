module RelatonIsoBib
  class IsoDocumentRelation < RelatonBib::DocumentRelation
    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.relation(type: type) do
        bibitem.to_xml(builder, {})
        bib_locality.each do |l|
          l.to_xml builder
        end
      end
    end
  end
end

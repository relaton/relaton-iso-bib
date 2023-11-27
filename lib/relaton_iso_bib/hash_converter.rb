module RelatonIsoBib
  module HashConverter
    include RelatonBib::HashConverter
    extend self

    private

    #
    # Ovverides superclass's method
    #
    # @param item [Hash]
    # @retirn [RelatonIsoBib::IsoBibliographicItem]
    def bib_item(item)
      IsoBibliographicItem.new(**item)
    end

    #
    # Ovverides superclass's method
    #
    # @param title [Hash]
    # @return [RelatonBib::TypedTitleString]
    def typed_title_strig(title)
      RelatonBib::TypedTitleString.new(**title)
    end

    # @param ret [Hash]
    def editorialgroup_hash_to_bib(ret)
      eg = ret[:editorialgroup]
      return unless eg

      ret[:editorialgroup] = EditorialGroup.new(
        technical_committee: RelatonBib.array(eg[:technical_committee]),
        subcommittee: RelatonBib.array(eg[:subcommittee]),
        workgroup: RelatonBib.array(eg[:workgroup]),
        secretariat: eg[:secretariat],
      )
    end

    # @param ret [Hash]
    def ics_hash_to_bib(ret)
      ret[:ics] = RelatonBib.array(ret[:ics]).map do |ics|
        Ics.new(ics[:code] || ics)
      end
    end

    # @param ret [Hash]
    def structuredidentifier_hash_to_bib(ret)
      return unless ret[:structuredidentifier]

      ret[:structuredidentifier] = RelatonIsoBib::StructuredIdentifier.new(**ret[:structuredidentifier])
    end

    def create_doctype(**args)
      DocumentType.new(**args)
    end
  end
end

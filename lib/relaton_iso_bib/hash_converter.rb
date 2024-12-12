module RelatonIsoBib
  module HashConverter
    include RelatonBib::HashConverter
    extend self

    private

    def ext_has_to_bib(ret)
      super
      ret[:stagename] = ret[:ext][:stagename] if ret.dig(:ext, :stagename)
      ret[:horizontal] = ret[:ext][:horizontal] unless ret.dig(:ext, :horizontal).nil?
      ret[:fast_track] = ret[:ext][:fast_track] unless ret.dig(:ext, :fast_track).nil?
      ret[:price_code] = ret[:ext][:price_code] if ret.dig(:ext, :price_code)
      ret
    end

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
      eg = ret.dig(:ext, :editorialgroup) || ret[:editorialgroup] # TODO: remove :editorialgroup after all bibdata are updated
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
      ics = ret.dig(:ext, :ics) || ret[:ics] # TODO: remove :ics after all bibdata are updated
      return unless ics

      ret[:ics] = RelatonBib.array(ics).map { |item| Ics.new(item[:code] || item) }
    end

    # @param ret [Hash]
    def structuredidentifier_hash_to_bib(ret)
      struct_id = ret.dig(:ext, :structuredidentifier) || ret[:structuredidentifier] # TODO: remove :structuredidentifier after all bibdata are updated
      return unless struct_id

      ret[:structuredidentifier] = RelatonIsoBib::StructuredIdentifier.new(**struct_id)
    end

    def create_doctype(**args)
      DocumentType.new(**args)
    end
  end
end

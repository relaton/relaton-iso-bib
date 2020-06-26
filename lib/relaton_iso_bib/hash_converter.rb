module RelatonIsoBib
  class HashConverter < RelatonBib::HashConverter
    class << self
      private

      #
      # Ovverides superclass's method
      #
      # @param item [Hash]
      # @retirn [RelatonIsoBib::IsoBibliographicItem]
      def bib_item(item)
        IsoBibliographicItem.new(item)
      end

      #
      # Ovverides superclass's method
      #
      # @param title [Hash]
      # @return [RelatonBib::TypedTitleString]
      def typed_title_strig(title)
        RelatonBib::TypedTitleString.new title
      end

      # @param ret [Hash]
      def editorialgroup_hash_to_bib(ret)
        eg = ret[:editorialgroup]
        return unless eg

        ret[:editorialgroup] = EditorialGroup.new(
          technical_committee: array(eg[:technical_committee]),
          subcommittee: array(eg[:subcommittee]),
          workgroup: array(eg[:workgroup]),
          secretariat: eg[:secretariat],
        )
      end

      # @param ret [Hash]
      def ics_hash_to_bib(ret)
        ret[:ics] = array(ret[:ics]).map do |ics|
          ics[:code] ? Ics.new(ics[:code]) : Ics.new(ics)
        end
      end

      # @param ret [Hash]
      def structuredidentifier_hash_to_bib(ret)
        return unless ret[:structuredidentifier]

        ret[:structuredidentifier] = RelatonIsoBib::StructuredIdentifier.new(
          ret[:structuredidentifier],
        )
      end
    end
  end
end

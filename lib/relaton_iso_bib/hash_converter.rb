module RelatonIsoBib
  class HashConverter < RelatonBib::HashConverter
    class << self
      # @override RelatonBib::HashConverter.hash_to_bib
      # @param args [Hash]
      # @param nested [TrueClass, FalseClass]
      # @return [Hash]
      def hash_to_bib(args, nested = false)
        ret = super
        return if ret.nil?

        editorialgroup_hash_to_bib(ret)
        ics_hash_to_bib(ret)
        structuredidentifier_hash_to_bib(ret)
        ret
      end

      def split_title(content, lang = "en", script = "Latn")
        titles = content&.split " -- "
        case titles&.size
        when nil, 0
          intro, main, part = nil, "", nil
        when 1
          intro, main, part = nil, titles[0], nil
        when 2
          if /^(Part|Partie) \d+:/ =~ titles[1]
            intro, main, part = nil, titles[0], titles[1]
          else
            intro, main, part = titles[0], titles[1], nil
          end
        when 3
          intro, main, part = titles[0], titles[1], titles[2]
        else
          intro, main, part = titles[0], titles[1], titles[2..-1]&.join(" -- ")
        end
        {
          title_intro: intro,
          title_main: main,
          title_part: part,
          language: lang,
          script: script,
        }
      end

      private

      #
      # Ovverides superclass's method
      #
      # @param ret [Hash]
      def title_hash_to_bib(ret)
        return unless ret[:title]

        ret[:title] = array(ret[:title])
        ret[:title] = ret[:title].reduce([]) do |a, t|
          if t.is_a?(String)
            a << split_title(t)
          elsif t.is_a?(Hash) && t[:type]
            idx = a.index { |i| i[:language] == t[:language] }
            title_key = t[:type].sub("-", "_").to_sym
            if idx
              a[idx][title_key] = t[:content]
              a
            else
              a << { title_key => t[:content], language: t[:language], script: t[:script] }
            end
          elsif t.is_a?(Hash) && t[:content]
            a << split_title(t[:content], t[:language], t[:script])
          end
        end
      end

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
      # @return [RelatonIsoBib::TypedTitleString]
      def typed_title_strig(title)
        TypedTitleString.new title
      end

      # @param ret [Hash]
      def editorialgroup_hash_to_bib(ret)
        eg = ret[:editorialgroup]
        return unless eg

        ret[:editorialgroup] = EditorialGroup.new(
          technical_committee: eg[:technical_committee],
          subcommittee: eg[:subcommittee],
          workgroup: eg[:workgroup],
          secretariat: eg[:secretariat],
        )
      end

      # @param ret [Hash]
      def ics_hash_to_bib(ret)
        ret[:ics] = ret.fetch(:ics, []).map do |ics|
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

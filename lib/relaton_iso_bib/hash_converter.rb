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

      def title_hash_to_bib(ret)
        return unless ret[:title]

        ret[:title] = array(ret[:title])
        ret[:title] = ret[:title].map do |t|
          titleparts = {}
          titleparts = split_title(t) unless t.is_a?(Hash)
          if t.is_a?(Hash) && t[:content]
            titleparts = split_title(t[:content], t[:language], t[:script])
          end
          if t.is_a?(Hash) then t.merge(titleparts)
          else
            { content: t, language: "en", script: "Latn", format: "text/plain", type: "main" }
          end
        end
      end

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

      def ics_hash_to_bib(ret)
        ret[:ics] = ret.fetch(:ics, []).map do |ics|
          ics[:code] ? Ics.new(ics[:code]) : Ics.new(ics)
        end
      end

      def structuredidentifier_hash_to_bib(ret)
        return unless ret[:structuredidentifier]

        ret[:structuredidentifier] = RelatonIsoBib::StructuredIdentifier.new(
          ret[:structuredidentifier],
        )
      end
    end
  end
end

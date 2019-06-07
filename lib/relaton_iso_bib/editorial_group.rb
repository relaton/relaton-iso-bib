# frozen_string_literal: true

module RelatonIsoBib
  # ISO project group.
  class EditorialGroup
    # @return [Array<RelatonIsoBib::IsoSubgroup>]
    attr_reader :technical_committee

    # @return [RelatonIsoBib::IsoSubgroup]
    attr_reader :subcommittee

    # @return [RelatonIsoBib::IsoSubgroup]
    attr_reader :workgroup

    # @return [String]
    attr_reader :secretariat

    # @param technical_committee [Array<Hash, RelatonIsoBib::IsoSubgroup>]
    # @option technical_committee [String] :name
    # @option technical_committee [String] :type
    # @option technical_committee [Integer] :number
    #
    # @param subcommittee [Array<Hash, RelatonIsoBib::IsoSubgroup>]
    # @option subcommittee [String] :name
    # @option subcommittee [String] :type
    # @option subcommittee [Integer] :number
    #
    # @param workgroup [Array<Hash, RelatonIsoBib::IsoSubgroup>]
    # @option workgroup [String] :name
    # @option workgroup [String] :type
    # @option workgroup [Integer] :number
    #
    # @param secretariat [String, NilClass]
    def initialize(technical_committee:, **args)
      @technical_committee = technical_committee.map do |tc|
        tc.is_a?(Hash) ? IsoSubgroup.new(tc) : tc
      end
      @subcommittee = args.fetch(:subcommittee, []).map do |sc|
        sc.is_a?(Hash) ? IsoSubgroup.new(sc) : sc
      end
      @workgroup = args.fetch(:workgroup, []).map do |wg|
        wg.is_a?(Hash) ? IsoSubgroup.new(wg) : wg
      end
      @secretariat = args[:secretariat]
    end

    # rubocop:disable Metrics/AbcSize

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      return unless technical_committee || subcommittee || workgroup || secretariat

      builder.editorialgroup do
        technical_committee.each do |tc|
          builder.technical_committee { tc.to_xml builder }
        end
        subcommittee.each do |sc|
          builder.subcommittee { sc.to_xml builder }
        end
        workgroup.each do |wg|
          builder.workgroup { wg.to_xml builder }
        end
        builder.secretariat secretariat if secretariat
      end
    end
    # rubocop:enable Metrics/AbcSize
  end

  # ISO subgroup.
  class IsoSubgroup
    # @return [String, NilClass]
    attr_reader :type

    # @return [Integer, NilClass]
    attr_reader :number

    # @return [String]
    attr_reader :name

    # @param name [String]
    # @param type [String, NilClass]
    # @param number [Integer, NilClass]
    def initialize(name:, type: nil, number: nil)
      @name   = name
      @type   = type
      @number = number
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.parent[:number] = number if number
      builder.parent[:type] = type if type
      builder.text name
    end
  end
end

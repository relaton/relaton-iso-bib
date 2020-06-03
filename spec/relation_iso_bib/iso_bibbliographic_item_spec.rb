# encoding: UTF-8
# frozen_string_literal: true

require "yaml"
require "jing"
require "relaton_iso_bib/iso_bibliographic_item"

RSpec.describe RelatonIsoBib::IsoBibliographicItem do
  context "instance" do
    subject do
      RelatonIsoBib::IsoBibliographicItem.new(
        fetched: Date.today.to_s,
        structuredidentifier: RelatonIsoBib::StructuredIdentifier.new(
          type: "sid", project_number: "ISO 1-2:2014", part: 2, subpart: 2,
        ),
        docnumber: "123456",
        title: [
          { title_intro: "Geographic information", title_main: "Metadata",
            title_part: "Part 1: Fundamentals", language: "en", script: "Latn" },
          { title_intro: "Information géographique", title_main: "Métadonnées",
            title_part: "Information géographique", language: "fr",
            script: "Latn" },
        ],
        edition: "1",
        version: RelatonBib::BibliographicItem::Version.new("2019-04-01", ["draft"]),
        language: %w[en fr],
        script: ["Latn"],
        type: "standard",
        doctype: "international-standard",
        docstatus: RelatonBib::DocumentStatus.new(stage: "60", substage: "60"),
        date: [{ type: "published", on: "2014-04" }],
        abstract: [
          { content: "ISO 19115-1:2014 defines the schema required for ...",
            language: "en", script: "Latn", format: "text/plain" },
          { content: "L'ISO 19115-1:2014 définit le schéma requis pour ...",
            language: "fr", script: "Latn", format: "text/plain" },
        ],
        contributor: [
          { entity: { name: "International Organization for Standardization",
                      url: "www.iso.org", abbreviation: "ISO" },
            role: [type: "publisher"] },
          {
            entity: RelatonBib::Person.new(
              name: RelatonBib::FullName.new(
                completename: RelatonBib::LocalizedString.new("John Smith"),
              ),
            ),
            role: [type: "author"],
          },
        ],
        copyright: [{ owner: [{
          name: "International Organization for Standardization",
          abbreviation: "ISO", url: "www.iso.org"
        }], from: "2014" }],
        link: [
          { type: "src", content: "https://www.iso.org/standard/53798.html" },
          { type: "obp",
            content: "https://www.iso.org/obp/ui/#!iso:std:53798:en" },
          { type: "rss", content: "https://www.iso.org/contents/data/standard"\
            "/05/37/53798.detail.rss" },
        ],
        relation: [
          RelatonBib::DocumentRelation.new(
            type: "updates",
            bibitem: RelatonIsoBib::IsoBibliographicItem.new(
              formattedref: RelatonBib::FormattedRef.new(content: "ISO 19115:2003"),
              docstatus: RelatonBib::DocumentStatus.new(stage: "60", substage: "60"),
            ),
            locality: [
              RelatonBib::LocalityStack.new(
                [RelatonBib::Locality.new("section", "Reference form")],
              ),
            ],
          ),
          RelatonBib::DocumentRelation.new(
            type: "updates",
            bibitem: RelatonIsoBib::IsoBibliographicItem.new(
              type: "standard",
              formattedref: RelatonBib::FormattedRef.new(content: "ISO 19115:2003/Cor 1:2006"),
            ),
          ),
        ],
        series: [
          RelatonBib::Series.new(
            type: "main",
            title: RelatonIsoBib::TypedTitleString.new(
              type: "title-main", content: "ISO/IEC FDIS 10118-3", language: "en", script: "Latn",
            ),
            place: "Serie's place",
            organization: "Serie's organization",
            abbreviation: RelatonBib::LocalizedString.new("ABVR", "en", "Latn"),
            from: "2009-02-01",
            to: "2010-12-20",
            number: "serie1234",
            partnumber: "part5678",
          ),
          RelatonBib::Series.new(
            type: "alt",
            formattedref: RelatonBib::FormattedRef.new(
              content: "serieref", language: "en", script: "Latn",
            ),
          )
        ],
        medium: RelatonBib::Medium.new(
          form: "medium form", size: "medium size", scale: "medium scale",
        ),
        place: ["bib place"],
        extent: [
          RelatonBib::BibItemLocality.new(
            "section", "Reference from", "Reference to"
          ),
        ],
        accesslocation: ["accesslocation1", "accesslocation2"],
        classification: [RelatonBib::Classification.new(type: "type", value: "value")],
        validity: RelatonBib::Validity.new(
          begins: Time.new(2010, 10, 10, 12, 21),
          ends: Time.new(2011, 2, 3, 18,30),
          revision: Time.new(2011, 3, 4, 9, 0),
        ),
        editorialgroup: {
          technical_committee: [{
            name: " ISO/TC 211 Geographic information/Geomatics",
            type: "technicalCommittee", number: 211
          }],
          subcommittee: [{
            name: "International Organization for Standardization",
            type: "ISO", number: 122,
          }],
          workgroup: [RelatonIsoBib::IsoSubgroup.new(
            name: "Workgroup Organization",
            type: "WG", number: 111,
          )],
        },
        ics: [{ field: 35, group: 240, subgroup: 70 }],
        stagename: "International Standard published",
      )
    end

    it "create instance" do
      expect(subject).to be_instance_of RelatonIsoBib::IsoBibliographicItem
    end

    it "has titles" do
      expect(subject.title).to be_instance_of Array
      expect(subject.title(lang: "en").detect do |t|
        t.type == "title-main"
      end.title.content).to eq "Metadata"
    end

    it "has urls" do
      expect(subject.url).to eq "https://www.iso.org/standard/53798.html"
      expect(subject.url(:rss)).to eq "https://www.iso.org/contents/data/"\
                                          "standard/05/37/53798.detail.rss"
    end

    it "has relations" do
      expect(subject.relation.replaces).to be_instance_of RelatonBib::DocRelationCollection
    end

    it "has abstracts" do
      expect(subject.abstract(lang: "en")).to be_instance_of(
        RelatonBib::FormattedString,
      )
    end

    it "returns shortref" do
      expect(subject.shortref(subject.structuredidentifier)).to eq "ISO1-2-2014:2014"
      expect(subject.shortref(subject.structuredidentifier, no_year: true)).to eq "ISO1-2-2014"
      subject.instance_variable_set :@docidentifier, []
      expect(subject.shortref(nil)).to eq ":2014"
    end

    it "has contributors" do
      expect(subject.contributor.first.entity.url).to eq "www.iso.org"
    end

    it "returns xml" do
      file = "spec/examples/iso_bib_item.xml"
      File.write file, subject.to_xml(bibdata: true), encoding: "utf-8" unless File.exist? file
      xml = File.read file, encoding: "UTF-8"
      expect(subject.to_xml(bibdata: true)).to be_equivalent_to xml.sub(
        %r{(?<=<fetched>)\d{4}-\d{2}-\d{2}}, Date.today.to_s
      )
      schema = Jing.new "spec/examples/isobib.rng"
      errors = schema.validate file
      expect(errors).to eq []
    end

    it "returns xml with note" do
      file = "spec/examples/iso_bib_item_note.xml"
      xml_res = subject.to_xml(
        note: [{ type: "note type", text: "test note" }], bibdata: true,
      )
      File.write file, xml_res, encoding: "utf-8" unless File.exist? file
      expect(xml_res).to be_equivalent_to File.read(file, encoding: "UTF-8").sub(
        %r{(?<=<fetched>)\d{4}-\d{2}-\d{2}}, Date.today.to_s
      )
      expect(xml_res).to include "<note format=\"text/plain\" type=\"note type\">test note</note>"
      schema = Jing.new "spec/examples/isobib.rng"
      errors = schema.validate file
      expect(errors).to eq []
    end

    it "returs xml with given block" do
      xml = subject.to_xml bibdata: true do |builder|
        builder.gbtype "type"
      end
      expect(xml).to include "<gbtype>type</gbtype>"
    end

    it "returns xml with gbcommittee instead editorialgroup (for GB)" do
      expect(subject).to receive(:respond_to?).with(:docsubtype).and_return(false).at_least :once
      expect(subject).to receive(:respond_to?).with(:committee).and_return(true).at_least :once
      committee = double
      expect(committee).to receive(:to_xml) { |bldr| bldr.gbcommittee "committee" }
      expect(subject).to receive(:committee).and_return committee
      expect(subject.to_xml(bibdata: true)).to include "<gbcommittee>committee</gbcommittee>"
    end

    it "has dates" do
      expect(subject.date.filter(type: "published").first).to be_instance_of RelatonBib::BibliographicDate
    end

    it "converts to all_parts reference" do
      expect(subject.title.detect { |t| t.type == "title-part" }).not_to be nil
      expect(subject.relation.last.type).not_to eq "partOf"
      all_parts_item = subject.to_all_parts
      expect(all_parts_item.relation.last.type).to eq "instance"
      expect(all_parts_item.title.detect { |t| t.type == "title-part" }).to be nil
      expect(all_parts_item.title.detect { |t| t.type == "main" }.title.content).to eq "Geographic information – Metadata"
    end

    it "converts to latest year reference" do
      expect(subject.title.detect { |t| t.type == "title-part" }).not_to be nil
      expect(subject.relation.last.type).not_to eq "instance"
      expect(subject.date).not_to be_empty
      most_recent_ref = subject.to_most_recent_reference
      expect(most_recent_ref.relation.last.type).to eq "instance"
      expect(most_recent_ref.date).to be_empty
    end

    it "returns hash" do
      hash = subject.to_hash
      file = "spec/examples/hash.yml"
      File.write file, hash.to_yaml unless File.exist? file
      h = RelatonIsoBib::HashConverter.hash_to_bib(YAML.load_file(file))
      h[:fetched] = Date.today.to_s
      b = RelatonIsoBib::IsoBibliographicItem.new(h)
      expect(hash).to eq b.to_hash
    end
  end

  it "raises invalid type argument error" do
    expect do
      RelatonIsoBib::IsoBibliographicItem.new doctype: "type"
    end.to output(/invalid doctype: type/).to_stderr
  end

  # removed this functionality
=begin
  it "raise invalid language argument error" do
    expect do
      RelatonIsoBib::IsoBibliographicItem.new(
        type: "international-standard", language: ["ru"],
      )
    end.to raise_error ArgumentError
  end
=end

  context "doc identifier remove part/date" do
    it "Chinese Standard" do
      docid = RelatonIsoBib::StructuredIdentifier.new(
        project_number: "GB 1.2-2014", type: "Chinese Standard",
      )
      docid.remove_part
      expect(docid.id).to eq "GB 1-2014"
      docid.remove_date
      expect(docid.id).to eq "GB 1"
    end

    it "other standards" do
      docid = RelatonIsoBib::StructuredIdentifier.new(
        project_number: "ISO 1-2:2014", part: 2, type: "International Standard"
      )
      docid.remove_part
      expect(docid.id).to eq "ISO 1:2014"
      docid.remove_date
      expect(docid.id).to eq "ISO 1"
    end
  end
end

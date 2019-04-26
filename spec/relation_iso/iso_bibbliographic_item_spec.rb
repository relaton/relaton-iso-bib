# encoding: UTF-8
# frozen_string_literal: true

require "relaton_iso/iso_bibliographic_item"

RSpec.describe RelatonIso::IsoBibliographicItem do
  context "instance" do
    subject do
      RelatonIso::IsoBibliographicItem.new(
        fetched: "2018-10-21",
        docid: { project_number: "ISO 1", part_number: 2, prefix: nil, id: "ISO 1-2:2014" },
        docnumber: "123456",
        titles: [
          { title_intro: "Geographic information", title_main: "Metadata",
            title_part: "Part 1: Fundamentals", language: "en", script: "Latn" },
          { title_intro: "Information géographique", title_main: "Métadonnées",
            title_part: "Information géographique", language: "fr",
            script: "Latn" },
        ],
        edition:   "1",
        version:   RelatonBib::BibliographicItem::Version.new("2019-04-01", ["draft"]),
        language:  %w[en fr],
        script:    ["Latn"],
        type:      "international-standard",
        docstatus: { status: "Published", stage: "60", substage: "60" },
        dates:     [{ type: "published", on: "2014-04" }],
        abstract:  [
          { content: "ISO 19115-1:2014 defines the schema required for ...",
            language: "en", script: "Latn", format: "text/plain" },
          { content: "L'ISO 19115-1:2014 définit le schéma requis pour ...",
            language: "fr", script: "Latn", format: "text/plain" },
        ],
        contributors: [
          { entity: { name: "International Organization for Standardization",
                      url: "www.iso.org", abbreviation: "ISO" },
            roles: ["publisher"] },
          {
            entity: RelatonBib::Person.new(
              name: RelatonBib::FullName.new(
                completename: RelatonBib::LocalizedString.new("John Smith"),
              ),
            ),
            roles: ["author"],
          },
        ],
        copyright: { owner: {
          name: "International Organization for Standardization",
          abbreviation: "ISO", url: "www.iso.org"
        }, from: "2014" },
        link: [
          { type: "src", content: "https://www.iso.org/standard/53798.html" },
          { type: "obp",
            content: "https://www.iso.org/obp/ui/#!iso:std:53798:en" },
          { type: "rss", content: "https://www.iso.org/contents/data/standard"\
            "/05/37/53798.detail.rss" },
        ],
        relations: [
          RelatonIso::IsoDocumentRelation.new(
            type: "updates",
            bibitem: RelatonIso::IsoBibliographicItem.new(
              formattedref: RelatonBib::FormattedRef.new(content: "ISO 19115:2003"),
              docstatus: { status: "Published" },
            ),
            bib_locality: [
              RelatonBib::BibItemLocality.new("updates", "Reference form"),
            ],
          ),
          RelatonIso::IsoDocumentRelation.new(
            type: "updates",
            bibitem: RelatonIso::IsoBibliographicItem.new(
              type: "international-standard",
              formattedref: RelatonBib::FormattedRef.new(content: "ISO 19115:2003/Cor 1:2006"),
            ),
          ),
        ],
        series: [
          RelatonBib::Series.new(
            type: "main",
            title: RelatonBib::TypedTitleString.new(
              type: "original", content: "ISO/IEC FDIS 10118-3", language: "en", script: "Latn",
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
        classification: RelatonBib::Classification.new(type: "type", value: "value"),
        validity: RelatonBib::Validity.new(
          begins: Time.new(2010, 10, 10, 12, 21),
          ends: Time.new(2011, 2, 3, 18,30),
          revision: Time.new(2011, 3, 4, 9, 0),
        ),
        workgroup: {
          technical_committee: [{
            name: " ISO/TC 211 Geographic information/Geomatics",
            type: "technicalCommittee", number: 211
          }],
          subcommittee: [{
            name: "International Organization for Standardization",
            type: "ISO", number: 122,
          }],
          workgroup: [RelatonIso::IsoSubgroup.new(
            name: "Workgroup Organization",
            type: "WG", number: 111,
          )],
        },
        ics: [{ field: 35, group: 240, subgroup: 70 }],
      )
    end

    it "create instance" do
      expect(subject).to be_instance_of RelatonIso::IsoBibliographicItem
    end

    it "has titles" do
      expect(subject.title).to be_instance_of Array
      expect(subject.title(lang: "en").title_main.to_s).to eq "Metadata"
    end

    it "has urls" do
      expect(subject.url).to eq "https://www.iso.org/standard/53798.html"
      expect(subject.url(:rss)).to eq "https://www.iso.org/contents/data/"\
                                          "standard/05/37/53798.detail.rss"
    end

    it "has relations" do
      expect(subject.relations.replaces).to be_instance_of Array
    end

    it "has abstracts" do
      expect(subject.abstract(lang: "en")).to be_instance_of(
        RelatonBib::FormattedString,
      )
    end

    it "returns shortref" do
      expect(subject.shortref(subject.docidentifier.first)).to eq "ISO 1-2-2014:2014"
      expect(subject.shortref(subject.docidentifier.first, no_year: true)).to eq "ISO 1-2-2014"
      subject.instance_variable_set :@docidentifier, []
      expect(subject.shortref(nil)).to eq ":2014"
    end

    it "has contributors" do
      expect(subject.contributors.first.entity.url).to eq "www.iso.org"
    end

    it "returns xml" do
      file = "spec/examples/iso_bib_item.xml"
      File.write file, subject.to_xml, encoding: "utf-8" unless File.exist? file
      xml = File.read file, encoding: "UTF-8"
      expect(subject.to_xml).to be_equivalent_to xml
    end

    it "return xml with note" do
      file = "spec/examples/iso_bib_item_note.xml"
      File.write file, subject.to_xml(note: "test note"), encoding: "utf-8" unless File.exist? file
      xml_res = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |builder|
        subject.to_xml builder, note: "test note"
      end.doc.root.to_xml
      xml = File.read file, encoding: "UTF-8"
      expect(xml_res).to be_equivalent_to xml
    end

    it "has dates" do
      expect(subject.dates.filter(type: "published").first).to be_instance_of RelatonBib::BibliographicDate
    end

    it "converts to all_parts reference" do
      expect(subject.title.first.title_part).not_to be nil
      expect(subject.relations.last.type).not_to eq "partOf"
      expect(subject.to_xml).not_to include "<allparts>true</allparts>"
      expect(subject.to_xml).to include "<iso-standard type=\"international-standard\">"
      subject.to_all_parts
      expect(subject.relations.last.type).to eq "partOf"
      expect(subject.title.first.title_part).to be nil
      expect(subject.to_xml).to include "<allparts>true</allparts>"
      expect(subject.to_xml).to include "<iso-standard type=\"international-standard\">"
    end

    it "converts to latest year reference" do
      expect(subject.title.first.title_part).not_to be nil
      expect(subject.relations.last.type).not_to eq "instance"
      expect(subject.dates).not_to be_empty
      subject.to_most_recent_reference
      expect(subject.relations.last.type).to eq "instance"
      expect(subject.dates).to be_empty
    end
  end

  it "raises invalid type argument error" do
    expect { RelatonIso::IsoBibliographicItem.new type: "type" }.to raise_error ArgumentError
  end

  it "doc identifier remove part/date" do
    docid = RelatonIso::IsoDocumentId.new(id: "GB 1.2-2014", type: "Chinese Standard")
    docid.remove_part
    expect(docid.id).to eq "GB 1-2014"
    docid.remove_date
    expect(docid.id).to eq "GB 1"
  end
end

# encoding: UTF-8
# frozen_string_literal: true

require "yaml"
require "jing"
require "relaton_iso_bib/iso_bibliographic_item"

RSpec.describe RelatonIsoBib::IsoBibliographicItem do
  before do
    RelatonIsoBib.instance_variable_set :@configuration, nil
  end

  context "instance" do
    subject do
      hash = YAML.load_file "spec/examples/iso_bib_item.yml"
      bib_hash = RelatonIsoBib::HashConverter.hash_to_bib hash
      RelatonIsoBib::IsoBibliographicItem.new(**bib_hash)
    end

    it "create instance" do
      expect(subject).to be_instance_of RelatonIsoBib::IsoBibliographicItem
    end

    it "has relations" do
      expect(subject.relation.replaces).to be_instance_of(
        RelatonBib::DocRelationCollection,
      )
    end

    it "has abstracts" do
      expect(subject.abstract(lang: "en")).to be_instance_of(
        RelatonBib::FormattedString,
      )
    end

    it "returns shortref" do
      expect(subject.shortref(subject.structuredidentifier))
        .to eq "ISO1-2-2014:2014"
      expect(subject.shortref(subject.structuredidentifier, no_year: true))
        .to eq "ISO1-2-2014"
      subject.instance_variable_set :@docidentifier, []
      expect(subject.shortref(nil)).to eq ":2014"
    end

    it "has contributors" do
      expect(subject.contributor.first.entity.url).to eq "www.iso.org"
    end

    it "returns xml" do
      file = "spec/examples/iso_bib_item.xml"
      unless File.exist? file
        File.write file, subject.to_xml(bibdata: true), encoding: "utf-8"
      end
      xml = subject.to_xml(bibdata: true)
        .sub(%r{(?<=<fetched>)\d{4}-\d{2}-\d{2}}, Date.today.to_s)
      expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
        .sub(%r{(?<=<fetched>)\d{4}-\d{2}-\d{2}}, Date.today.to_s)
      schema = Jing.new "grammars/relaton-iso-compile.rng"
      errors = schema.validate file
      expect(errors).to eq []
    end

    it "returns xml with note" do
      file = "spec/examples/iso_bib_item_note.xml"
      xml_res = subject.to_xml(
        note: [{ type: "note type", text: "test note" }], bibdata: true,
      ).sub(%r{(?<=<fetched>)\d{4}-\d{2}-\d{2}}, Date.today.to_s)
      File.write file, xml_res, encoding: "utf-8" unless File.exist? file
      expect(xml_res).to be_equivalent_to File.read(file, encoding: "UTF-8")
        .sub(%r{(?<=<fetched>)\d{4}-\d{2}-\d{2}}, Date.today.to_s)
      expect(xml_res).to include(
        "<note format=\"text/plain\" type=\"note type\">test note</note>",
      )
      schema = Jing.new "grammars/relaton-iso-compile.rng"
      errors = schema.validate file
      expect(errors).to eq []
    end

    it "returs xml with given block" do
      xml = subject.to_xml bibdata: true do |builder|
        builder.gbtype "type"
      end
      expect(xml).to include "<gbtype>type</gbtype>"
    end

    it "has dates" do
      expect(subject.date.filter(type: "published").first)
        .to be_instance_of RelatonBib::BibliographicDate
    end

    it "converts to all_parts reference" do
      expect(subject.title.detect { |t| t.type == "title-part" }).not_to be nil
      expect(subject.relation.last.type).not_to eq "partOf"
      all_parts_item = subject.to_all_parts
      expect(all_parts_item.relation.last.type).to eq "instanceOf"
      expect(all_parts_item.title.detect { |t| t.type == "title-part" })
        .to be_nil
      expect(
        all_parts_item.title.detect { |t| t.type == "main" }.title.content,
      ).to eq "Geographic information – Metadata"
    end

    it "converts to latest year reference" do
      expect(subject.title.detect { |t| t.type == "title-part" }).not_to be nil
      expect(subject.relation.last.type).not_to eq "instanceOf"
      expect(subject.date).not_to be_empty
      most_recent_ref = subject.to_most_recent_reference
      expect(most_recent_ref.relation.last.type).to eq "instanceOf"
      expect(most_recent_ref.date).to be_empty
    end

    it "returns hash" do
      hash = subject.to_hash
      file = "spec/examples/hash.yml"
      File.write file, hash.to_yaml unless File.exist? file
      h = RelatonIsoBib::HashConverter.hash_to_bib(YAML.load_file(file))
      b = RelatonIsoBib::IsoBibliographicItem.new(**h)
      expect(hash).to eq b.to_hash
    end

    it "returns AsciiBib" do
      file = "spec/examples/asciibib.adoc"
      bib = subject.to_asciibib
      File.write file, bib, encoding: "UTF-8" unless File.exist? file
      expect(bib).to eq File.read(file, encoding: "UTF-8")
    end
  end

  it "create editorial group from Hash" do
    item = RelatonIsoBib::IsoBibliographicItem.new(
      editorialgroup: { technical_committee: [{ name: "Committee" }] },
    )
    expect(item.editorialgroup).to be_instance_of RelatonIsoBib::EditorialGroup
  end

  it "warn invalid subdoctype argument" do
    expect do
      RelatonIsoBib::IsoBibliographicItem.new subdoctype: "type"
    end.to output("[relaton-iso-bib] Invald subdoctype `type`. Allowed values are: " \
                  "specification, method-of-test, vocabulary, code-of-practice\n").to_stderr
  end

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
        project_number: "ISO 1-2:2014", part: 2, type: "International Standard",
      )
      docid.remove_part
      expect(docid.id).to eq "ISO 1:2014"
      docid.remove_date
      expect(docid.id).to eq "ISO 1"
    end
  end
end

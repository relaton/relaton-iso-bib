RSpec.describe RelatonIsoBib::XMLParser do
  it "creates item form xml" do
    xml = File.read "spec/examples/iso_bib_item.xml", encoding: "UTF-8"
    item = RelatonIsoBib::XMLParser.from_xml xml
    expect(item.to_xml(bibdata: true)).to be_equivalent_to xml
  end

  it "warn if XML doesn't have bibitem or bibdata element" do
    item = ""
    expect { item = RelatonIsoBib::XMLParser.from_xml "" }.to(
      output(/can't find bibitem/).to_stderr_from_any_process
    )
    expect(item).to be_nil
  end

  it "create_doctype" do
    xml = Nokogiri::XML(<<~XML).at("doctype")
      <doctype abbreviation="TR">technical-report</doctype>
    XML
    expect do
      doctype = described_class.send :create_doctype, xml
      expect(doctype).to be_instance_of RelatonIsoBib::DocumentType
      expect(doctype.type).to eq "technical-report"
      expect(doctype.abbreviation).to eq "TR"
    end.not_to output(/invalid doctype/).to_stderr_from_any_process
  end
end

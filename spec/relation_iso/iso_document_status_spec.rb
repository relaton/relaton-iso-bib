RSpec.describe RelatonIso::IsoDocumentStatus do
  it "raises staus or stage required argument error" do
    expect { RelatonIso::IsoDocumentStatus.new }.to raise_error ArgumentError
  end

  it "raises invalid stage argument error" do
    expect { RelatonIso::IsoDocumentStatus.new stage: "11" }.to raise_error ArgumentError
  end

  it "raises invalid substage argument error" do
    expect { RelatonIso::IsoDocumentStatus.new stage: "00", substage: "22" }.to raise_error ArgumentError
  end
end

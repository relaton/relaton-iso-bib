RSpec.describe RelatonIsoBib::TypedTitleString do
  context "raise ArgumentError" do
    it "type is invalid" do
      expect { RelatonIsoBib::TypedTitleString.new type: "type" }.to raise_error ArgumentError
    end

    it "title or content should passed" do
      expect do
        RelatonIsoBib::TypedTitleString.new type: "main"
      end.to raise_error ArgumentError
    end
  end

  it "create instance without error" do
    title = RelatonBib::FormattedString.new(
      content: "Title", language: "en", script: "Latn", format: "text/plain",
    )
    typed_title = RelatonIsoBib::TypedTitleString.new(
      type: "main", title: title,
    )
    expect(typed_title).to be_instance_of RelatonIsoBib::TypedTitleString
  end
end

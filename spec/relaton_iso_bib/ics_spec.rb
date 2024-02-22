RSpec.describe RelatonIsoBib::Ics do
  it "raises error when there is no ICS code and field" do
    expect { RelatonIsoBib::Ics.new }.to raise_error ArgumentError
  end
end

describe RelatonIsoBib::DocumentType do
  it "warn invalid doctype argument" do
    expect do
      RelatonIsoBib::DocumentType.new type: "type"
    end.to output(
      match(/\[relaton-iso-bib\] WARN: Invalid doctype: `type`/)
        .and(match(/Allowed doctypes are: `international-standard`/))
    ).to_stderr_from_any_process
  end
end

require "spec_helper"
require "json"
require 'active_support/core_ext/string'

describe RSpec::Snapshot::Matchers do
  context "when matching snapshot file exists" do
    before do
      expect_any_instance_of(File).not_to receive(:write)
    end

    context "with json" do
      let(:json) { JSON.pretty_generate({ a: 1, b: 2 }) }

      it "matches" do
        expect(json).to match_snapshot("snapshot/json")
      end

      context "when result doesn't match snapshot" do
        let(:json) { JSON.pretty_generate({ a: 1, b: 2, c: 3 }) }

        it "doesn't match" do
          expect(json).not_to match_snapshot("snapshot/json")
        end
      end
    end

    it "snapshot html" do
      html = <<-HTML.strip_heredoc
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <title></title>
      </head>
      <body>
        <h1>rspec-snapshot</h1>
        <p>
          Snapshot is awesome!
        </p>
      </body>
      </html>
      HTML

      expect(html).to match_snapshot("snapshot/html")
    end

    context "when snapshotting non-string objects" do
      it "stringifies simple POROs" do
        simple_data_structure = { a_key: %w(some values) }
        expect(simple_data_structure).to match_snapshot("snapshot/simple_data_structure")
      end
    end
  end

  context "when no matching snapshot file exists" do
    let(:json) { JSON.pretty_generate({ a: 1, b: 2 }) }
    let(:file) { double("file") }

    it "writes a new snapshot file and passes" do
      expect(File).to receive(:new).with("spec/fixtures/snapshots/snapshot/not-saved.snap", "w+").and_return(file)
      expect(file).to receive(:write).with(json)
      expect(file).to receive(:close)

      expect(json).to match_snapshot("snapshot/not-saved")
    end
  end

  context "writing and reading" do
    let(:json) { JSON.pretty_generate({ a: 1, b: 2 }) }

    it "reads the new snapshot file the next time match_snapshot is called" do
      expect_any_instance_of(File).to receive(:write).and_call_original
      expect(json).to match_snapshot("snapshot/tmp")

      expect_any_instance_of(File).to receive(:read).and_call_original
      expect(json).to match_snapshot("snapshot/tmp")
    end

    after do
      File.delete("spec/fixtures/snapshots/snapshot/tmp.snap")
    end

  end

end

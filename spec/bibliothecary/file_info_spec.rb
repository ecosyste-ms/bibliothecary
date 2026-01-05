# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::FileInfo do
  describe "#groupable?" do
    let(:file_info) { described_class.new(folder_path, full_path, contents) }
    let(:folder_path) { "spec/fixtures" }
    let(:contents) { nil }

    subject { file_info.groupable? }

    context "groupable" do
      let(:full_path) { "spec/fixtures/package.json" }

      it "determines if file is groupable" do
        file_info.package_manager = Bibliothecary::Parsers::NPM
        expect(subject).to eq(true)
      end
    end
  end
end

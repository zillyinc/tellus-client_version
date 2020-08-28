require 'pry'

RSpec.describe Tellus::ClientVersion do
  it 'has a version number' do
    expect(Tellus::ClientVersion::VERSION).not_to be nil
  end

  context 'with numeric-only version number' do
    let(:client_version) { '1.2.3' }
    let(:platform) { :ios }
    subject { described_class.current }

    before do
      described_class.set :platform, platform
      described_class.set :version, client_version
    end
    after { RequestStore.clear! }

    describe '#lt?' do
      context 'when checked version is a patch version less' do
        it { expect(subject.lt?(platform, '1.2.2')).to be false }
      end

      context 'when checked version is a minor version less' do
        it { expect(subject.lt?(platform, '1.1.7')).to be false }
      end

      context 'when checked version is a major version less' do
        it { expect(subject.lt?(platform, '0.9.0')).to be false }
      end

      context 'when checked version is the same' do
        it { expect(subject.lt?(platform, '1.2.3')).to be false }
      end

      context 'when checked version a sub-patch version more' do
        it { expect(subject.lt?(platform, '1.2.3.1')).to be true }
      end

      context 'when checked version a patch version more' do
        it { expect(subject.lt?(platform, '1.2.4')).to be true }
      end

      context 'when checked version a minor version more' do
        it { expect(subject.lt?(platform, '1.3.0')).to be true }
      end

      context 'when checked version a major version more' do
        it { expect(subject.lt?(platform, '2.0.0')).to be true }
      end
    end

    describe '#present?' do
      context 'when version string is set' do
        it { expect(described_class.new(:android, '1.2.3').present?).to be true}
      end

      context 'when version string is not set' do
        before { RequestStore.clear! }
        it { expect(described_class.new(:android).present?).to be false }
      end
    end

    describe '.get' do
      context 'when no version is set' do
        let(:client_version) { nil }
        it { expect(described_class.get(:version)).to be nil }
      end

      context 'when a version is set' do
        it { expect(described_class.get(:version)).to eql :'1.2.3' }
      end
    end

    describe '.set' do
      let(:client_version) { nil }

      it 'sets the version' do
        expect {
          described_class.set(:version, '0.4.2')
        }.to change { described_class.get(:version) }.from(nil).to :'0.4.2'
      end
    end

    describe '.set_from_request' do
      let(:client_version) { nil }
      let(:headers) { {} }
      let(:request) { double('request', headers: headers) }

      context 'when version header does not exist' do
        it 'does nothing' do
          expect {
            described_class.set_from_request(request)
          }.to_not change { described_class.get(:version) }
        end
      end

      context 'when version header exists' do
        let(:headers) { { 'X-Zilly-Ios-Version' => '1.2.3'} }

        it 'does nothing' do
          expect {
            described_class.set_from_request(request)
          }.to change { described_class.get(:version) }.from(nil).to :'1.2.3'
        end
      end
    end
  end

  context 'with prefixed version number' do
    let(:client_version) { 'v1.2.3' }
    let(:platform) { :ios }
    let(:app) { :zilly }
    subject { described_class.new(platform) }

    before do
      described_class.set :platform, platform
      described_class.set :version, client_version
    end
    after { RequestStore.clear! }

    describe '#lt?' do
      context 'when checked version is a patch version less' do
        it { expect(subject.lt?(platform, '1.2.2')).to be false }
      end
    end
  end
end

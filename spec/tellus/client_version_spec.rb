
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

      context 'when nil' do
        subject { described_class.new }

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

      context 'when iOS version header exists' do
        let(:headers) { { 'X-Zilly-Ios-Version' => '1.2.3'} }

        it 'sets the iOS version and platform' do
          expect {
            described_class.set_from_request(request)
          }.to change { described_class.get(:version) }.from(nil).to :'1.2.3'
          expect(described_class.get(:platform)).to eq :ios
        end
      end

      context 'when Android version header exists' do
        let(:headers) { { 'X-Zilly-Android-Version' => '2.1.0'} }

        it 'sets the Android version and platform' do
          expect {
            described_class.set_from_request(request)
          }.to change { described_class.get(:version) }.from(nil).to :'2.1.0'
          expect(described_class.get(:platform)).to eq :android
        end
      end

      context 'when Web version header exists' do
        let(:headers) { { 'X-Zilly-Web-Version' => '3.0.1'} }

        it 'sets the Web version and platform' do
          expect {
            described_class.set_from_request(request)
          }.to change { described_class.get(:version) }.from(nil).to :'3.0.1'
          expect(described_class.get(:platform)).to eq :web
        end
      end

      context 'when WebApp version header exists' do
        let(:headers) { { 'X-Zilly-WebApp-Version' => '1.5.2'} }

        it 'sets the WebApp version and platform' do
          expect {
            described_class.set_from_request(request)
          }.to change { described_class.get(:version) }.from(nil).to :'1.5.2'
          expect(described_class.get(:platform)).to eq :web_app
        end
      end

      context 'when multiple version headers exist' do
        let(:headers) { { 'X-Zilly-Ios-Version' => '1.2.3', 'X-Zilly-WebApp-Version' => '1.5.2'} }

        it 'sets the first matching header found' do
          described_class.set_from_request(request)
          # The behavior depends on which header is processed first by the VERSION_HEADERS hash
          expect(described_class.get(:version)).to_not be_nil
          expect(described_class.get(:platform)).to_not be_nil
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

  context 'with webapp platform' do
    let(:client_version) { '2.1.0' }
    let(:platform) { :web_app }
    subject { described_class.new(platform, client_version) }

    describe '#friendly_str' do
      it 'returns correct format for webapp' do
        expect(subject.friendly_str).to eq 'Zilly Web_app 2.1.0'
      end
    end

    describe '#lt?' do
      context 'when webapp version is compared' do
        it { expect(subject.lt?(:web_app, '2.2.0')).to be true }
        it { expect(subject.lt?(:web_app, '2.0.0')).to be false }
        it { expect(subject.lt?(:web_app, '2.1.0')).to be false }
      end

      context 'when different platform is compared' do
        it { expect(subject.lt?(:ios, '2.2.0')).to be false }
      end
    end

    describe '#present?' do
      it { expect(subject.present?).to be true }
    end
  end

  describe '.current' do
    after { RequestStore.clear! }

    context 'when webapp platform is set' do
      before do
        described_class.set :platform, :web_app
        described_class.set :version, '1.5.0'
      end

      it 'returns ClientVersion with webapp platform' do
        current = described_class.current
        expect(current.platform).to eq :web_app
        expect(current.version).to eq :'1.5.0'
      end
    end

    context 'when no platform is set' do
      it 'returns empty ClientVersion' do
        current = described_class.current
        expect(current.platform).to be_nil
        expect(current.version).to be_nil
      end
    end
  end

  describe '.from_friendly_version_str' do
    subject(:parsed) { described_class.from_friendly_version_str(version_string) }

    let(:version_string) { 'Zilly Ios 1.2.3' }

    it { expect(parsed.platform).to eq :ios }
    it { expect(parsed.version).to eq '1.2.3' }

    context 'with Android platform' do
      let(:version_string) { 'Zilly Android 2.1.0' }

      it { expect(parsed.platform).to eq :android }
      it { expect(parsed.version).to eq '2.1.0' }
    end

    context 'with Web platform' do
      let(:version_string) { 'Zilly Web 3.0.1' }

      it { expect(parsed.platform).to eq :web }
      it { expect(parsed.version).to eq '3.0.1' }
    end

    context 'with Web_app platform' do
      let(:version_string) { 'Zilly Web_app 1.5.2' }

      it { expect(parsed.platform).to eq :web_app }
      it { expect(parsed.version).to eq '1.5.2' }
    end

    context 'with invalid string' do
      let(:version_string) { 'foo' }

      it { expect(parsed.platform).to eq nil }
      it { expect(parsed.version).to eq nil }
    end

    context 'with nil' do
      let(:version_string) { nil }

      it { expect(parsed.platform).to eq nil }
      it { expect(parsed.version).to eq nil }
    end
  end
end

require 'pry'

RSpec.describe Tellus::ClientVersion do
  it 'has a version number' do
    expect(Tellus::ClientVersion::VERSION).not_to be nil
  end

  context 'with numeric-only version number' do

    let(:client_version) { '1.2.3' }
    let(:platform) { :ios }
    let(:app) { :zilly }
    subject { described_class.new(platform, app) }

    before { described_class.set platform, app, client_version }
    after { RequestStore.clear! }

    describe '#lt?' do
      context 'when checked version is a patch version less' do
        it { expect(subject.lt? '1.2.2').to be false }
      end

      context 'when checked version is a minor version less' do
        it { expect(subject.lt? '1.1.7').to be false }
      end

      context 'when checked version is a major version less' do
        it { expect(subject.lt? '0.9.0').to be false }
      end

      context 'when checked version is the same' do
        it { expect(subject.lt? '1.2.3').to be false }
      end

      context 'when checked version a sub-patch version more' do
        it { expect(subject.lte? '1.2.3.1').to be true }
      end

      context 'when checked version a patch version more' do
        it { expect(subject.lt? '1.2.4').to be true }
      end

      context 'when checked version a minor version more' do
        it { expect(subject.lt? '1.3.0').to be true }
      end

      context 'when checked version a major version more' do
        it { expect(subject.lt? '2.0.0').to be true }
      end
    end

    describe '#lte?' do
      context 'when checked version is a patch version less' do
        it { expect(subject.lte? '1.2.2').to be false }
      end

      context 'when checked version is a minor version less' do
        it { expect(subject.lte? '1.1.7').to be false }
      end

      context 'when checked version is a major version less' do
        it { expect(subject.lte? '0.9.0').to be false }
      end

      context 'when checked version is the same' do
        it { expect(subject.lte? '1.2.3').to be true }
      end

      context 'when checked version a sub-patch version more' do
        it { expect(subject.lte? '1.2.3.1').to be true }
      end

      context 'when checked version a patch version more' do
        it { expect(subject.lte? '1.2.4').to be true }
      end

      context 'when checked version a minor version more' do
        it { expect(subject.lte? '1.3.0').to be true }
      end

      context 'when checked version a major version more' do
        it { expect(subject.lte? '2.0.0').to be true }
      end
    end

    describe '#present?' do
      context 'when version string is set' do
        it { expect(subject.present?).to be true}
      end

      context 'when version string is not set' do
        it { expect(described_class.new(:android, :zilly).present?).to be false }
      end
    end

    describe '.get' do
      context 'when no version is set' do
        let(:client_version) { nil }
        it { expect(described_class.get).to be nil }
      end

      context 'when a version is set' do
        it { expect(described_class.get).to eql '1.2.3' }
      end
    end

    describe '.set' do
      let(:client_version) { nil }

      it 'sets the version' do
        expect {
          described_class.set(:ios, :zilly, '0.4.2')
        }.to change { described_class.get(:ios, :zilly) }.from(nil).to '0.4.2'
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
          }.to_not change { described_class.get }
        end
      end

      context 'when version header exists' do
        let(:headers) { { 'X-Zilly-Ios-Version' => '1.2.3'} }

        it 'does nothing' do
          expect {
            described_class.set_from_request(request)
          }.to change { described_class.get }.from(nil).to '1.2.3'
        end
      end
    end

    describe '.all_for_app' do
      it 'returns ClientVersion instances for all platforms' do
        cvs = Tellus::ClientVersion.all_for_app(:zilly)
        expect(cvs.count).to eql 5
        cvs.each { |cv| expect(cv).to be_instance_of Tellus::ClientVersion }
      end
    end
  end

  context 'with prefixed version number' do
    let(:client_version) { 'v1.2.3' }
    let(:platform) { :ios }
    let(:app) { :zilly }
    subject { described_class.new(platform, app) }

    before { described_class.set platform, app, client_version }
    after { RequestStore.clear! }

    describe '#lt?' do
      context 'when checked version is a patch version less' do
        it { expect(subject.lt? '1.2.2').to be false }
      end
    end
  end
end

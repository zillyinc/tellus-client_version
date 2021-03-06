require 'tellus/client_version/version'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/blank'
require 'request_store'

module Tellus
  # Encapsulates a platform and version for clients of the Tellus API.
  class ClientVersion
    VERSION_HEADERS = {
      ios:            'X-Zilly-Ios-Version',
      android:        'X-Zilly-Android-Version',
      web:            'X-Zilly-Web-Version'
    }.freeze

    attr_reader :platform, :version

    def initialize(platform = nil, version = nil)
      @platform = platform.presence || self.class.get(:platform)
      @version = version.presence || self.class.get(:version)
    end

    def self.from_friendly_version_str(version_str)
      return new unless version_str.present?

      version_str = version_str.split(' ')
      return new unless version_str.length == 3

      platform = version_str[1].downcase.to_sym
      version = version_str[2]
      new(platform, version)
    end

    def lt?(plat, ver)
      return false if blank? || ver.blank? || plat.blank?

      plat == @platform && version_object < version_object_for(ver)
    end

    def matches?(version_requirement_string)
      Gem::Requirement.new(version_requirement_string) =~ version_object
    end

    def friendly_str
      "Zilly #{platform.to_s.capitalize} #{version}"
    end

    delegate :blank?, :to_s, :present?, to: :version

    def self.platform
      current&.platform
    end

    def self.version
      current&.version
    end

    # returns ClientVersion instance with platform and app for the current request
    def self.current
      VERSION_HEADERS.each do |platform, _|
        return new(platform) if get(:platform) == platform
      end

      new
    end

    def self.get(key)
      RequestStore.store[key].presence
    end

    def self.set(key, value)
      RequestStore.store[key] = value&.to_sym
    end

    def self.set_from_request(request)
      VERSION_HEADERS.each do |platform, header|
        if (version = request.headers[header]).present?
          set(:platform, platform)
          set(:version, version)
        end
      end
    end

    def self.cleanup_version_str(version)
      cleanup_regex = /[[:alpha:]](\d)/
      version.gsub(cleanup_regex, '\1')
    end

    private

    def version_object_for(version)
      return nil if version.blank?
      return version if version.is_a? Gem::Version

      return Gem::Version.new(version) if Gem::Version.correct? version

      fixed_version = self.class.cleanup_version_str(version.to_s)

      if Gem::Version.correct? fixed_version
        Gem::Version.new(fixed_version)
      else
        msg = "Malformed version number string" \
              " #{fixed_version} (from #{version})"
        raise ArgumentError, msg
      end
    end

    def version_object
      @version_object ||= version_object_for(version)
    end
  end
end

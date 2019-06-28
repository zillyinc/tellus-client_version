require 'tellus/client_version/version'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/blank'
require 'request_store'

module Tellus
  # Encapsulates a platform and version for clients of the Tellus API.
  class ClientVersion
    APP_HEADERS = {
      zilly: {
        ios:            'X-Zilly-Ios-Version',
        android:        'X-Zilly-Android-Version',
        web:            'X-Zilly-Web-Version',
        chrome_wo:      'X-Zilly-Chrome-Wo-Version', # Chrome extension for work orders
        resource_guide: 'X-Zilly-Resource-Guide-Version', # resource guides
      },
    }.freeze

    attr_reader :version_string, :platform, :app

    def initialize(platform = :ios, app = :zilly)
      @platform = platform
      @app = app
      @version_string = self.class.get(platform, app)
    end

    def lt?(version)
      return false if blank?

      version_object < version_object_for(version)
    end

    def lte?(version)
      return false if blank?

      version_object <= version_object_for(version)
    end

    def matches?(version_requirement_string)
      Gem::Requirement.new(version_requirement_string) =~ version_object
    end

    def friendly_str
      "#{app.to_s.titleize} #{platform.to_s.titleize} #{version_string}"
    end

    delegate :blank?, :to_s, :present?, to: :version_string

    # returns a list of ClientVersion instances for every platform for the given app
    # can be used to check e.g. which app the current request is for regardless of platform
    def self.all_for_app(app = :zilly)
      APP_HEADERS.fetch(app, {}).keys.map do |platform|
        ClientVersion.new(platform, app)
      end
    end

    def self.app
      current&.app
    end

    def self.platform
      current&.platform
    end

    def self.version
      current&.version_string&.to_s
    end

    # returns ClientVersion instance with platform and app for the current request
    def self.current
      APP_HEADERS.each do |app, platforms|
        platforms.each do |platform, _|
          return new(platform, app) if get(platform, app).present?
        end
      end

      nil
    end

    def self.get(platform = :ios, app = :zilly)
      RequestStore.store[key(platform, app)].presence
    end

    def self.set(platform, app, version)
      RequestStore.store[key(platform, app)] = version.to_s
    end

    def self.key(platform, app)
      "#{platform}_#{app}_version".to_sym
    end

    def self.set_from_request(request)
      APP_HEADERS.each do |app, platforms|
        platforms.each do |platform, header|
          if (version = request.headers[header]).present?
            set platform, app, version
          end
        end
      end
    end

    private

    def version_object_for(version)
      return nil if version.blank?
      return version if version.is_a? Gem::Version

      Gem::Version.new(version)
    end

    def version_object
      @version_object ||= version_object_for(version_string)
    end
  end
end

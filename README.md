# Tellus::ClientVersion

Utility to parse and store client version strings from request headers, e.g. `X-Zilly-iOS-Version: 1.0.0`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tellus-client_version'
```

## Usage

Get the current client version:

```ruby
Tellus::ClientVersion.current
```

Populate `RequestStore` with the client version information given a Rack request:

```ruby
Tellus::ClientVersion.set_from_request(request)
```

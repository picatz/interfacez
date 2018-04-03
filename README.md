# Interfacez
> Simplified network interfaces API

## Installation

    $ gem install interfacez

## Usage

```ruby
require 'interfacez'

Interfacez.default
# => en0

Interfacez.loopback
# => lo0

Interfacez.all do |interface|
  # do something with interface name
  puts interface
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

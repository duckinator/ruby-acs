# ACS

A port of [ooc](http://ooc-lang.org)'s Awesome Clojure Syntax to Ruby.

Yes, this modifies Ruby's syntax.

Makes the following two lines equivalent:

```ruby
test(|a, b| p [a, b])
test(lambda {|a, b| p [ a , b ]})
```

Enjoy.

## Installation

Add this line to your application's Gemfile:

    gem 'acs'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install acs

## Usage

Run programs with `ruby-acs` instead of `ruby`.

You can set the shebang line to `#!/usr/bin/env ruby-acs`, or run it directly with `ruby-acs <normal arguments for ruby>`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# Qdocs

Qdocs is a very lightweight language intelligence server, which provides runtime information about constants and methods. It currently supports:

- Providing detailed information about instance and singleton methods for Ruby constants (eg. Classes and Modules)
- Querying a constant's instance and singleton methods by regular expression, returning the methods whose names match the given pattern
- Providing detailed information about active record attributes, if the constant being queried is an ActiveRecord model

It has minimal dependencies (probably nothing extra, if your application uses rails or another common web framework)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'qdocs', require: false
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install qdocs

## Usage

This gem offers CLI usage, or server usage:

#### Server usage:
`$ qdocs --server`


`$ curl 'http://localhost:8080/?input=User%2Efind'`

#### CLI usage

```
$ qdocs 'Set#length'
{
  "original_input": "Set#length",
  "constant": {
    "name": "Set",
    "type": "Class"
  },
  "query_type": "instance_method",
  "attributes": {
    "defined_at": "/Users/josephjohansen/.rvm/rubies/ruby-2.7.1/lib/ruby/2.7.0/set.rb:151",
    "source": "def size\n  @hash.size\nend\n",
    "arity": 0,
    "parameters": {
    },
    "comment": "# Returns the number of elements.",
    "name": "length",
    "belongs_to": "Set",
    "super_method": null
  }
}
```
**also provides support for constants which are recognised to be ActiveRecord models:**

```
$ curl 'http://localhost:7593/?input=User%2Femail%2F'
{
  "constant": {
    "name": "User",
    "type": "Class"
  },
  "query_type": "methods",
  "attributes": {
    "constant": "User",
    "singleton_methods": [
      "find_by_unconfirmed_email_with_errors"
    ],
    "instance_methods": [
      "postpone_email_change?",
      "postpone_email_change_until_confirmation_and_regenerate_confirmation_token",
      "send_email_changed_notification?",
      "send_verification_email"
    ]
  }
}

```

#### Further usage examples:

`$ qdocs --help` 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/qdocs.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

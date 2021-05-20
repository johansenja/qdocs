# Qdocs

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/qdocs`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'qdocs'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install qdocs

## Usage

### Example

```
$ qdocs 'Set#length'
{
  "defined_at": "~/.rvm/rubies/ruby-2.7.1/lib/ruby/2.7.0/set.rb:151",
  "source": "def size\n  @hash.size\nend\n",
  "arity": 0,
  "parameters": {
  },
  "comment": "# Returns the number of elements.",
  "name": "length",
  "belongs_to": "Set",
  "super_method": null
}
```

#### Further usage examples:
`$ qdocs --help`

#### Server usage:
`$ qdocs --server` or with Rails: `$ bundle exec rails runner 'require "qdocs/server"'`

`$ curl 'http://localhost:8080/?input=User%2Efind'` 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/qdocs.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

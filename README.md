# Qdocs

Qdocs is a very lightweight language intelligence server, which provides runtime information about constants and methods. Note that this is not a full-on "langauge server" implementing LSP, but a quick and lightweight way of finding information. It currently supports:

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

This gem offers CLI usage, text editor integration, or viewing in a browser:

#### Starting a server manually:
`$ qdocs --server`


`$ curl 'http://localhost:7593/?input=User%2Efind' # view JSON response`

or view it in your browser, to be able to navigate through a GUI:

`$ open 'http://localhost:7593/?input=User%2Efind'`

<img width="1346" alt="Screenshot 2021-05-24 at 11 30 29" src="https://user-images.githubusercontent.com/43235608/119334821-771c1980-bc83-11eb-8027-af9c31338885.png">


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
$ curl 'http://localhost:7593/?input=User%2Eemail'
{
  "original_input": "User#id",
  "constant": {
    "name": "User",
    "type": "Class"
  },
  "query_type": "instance_method",
  "attributes": {
    "defined_at": "~/.rvm/gems/ruby-2.7.1/gems/activerecord-6.0.3.6/lib/active_record/attribute_methods/primary_key.rb:18",
    "source": "def id\n  _read_attribute(@primary_key)\nend\n",
    "arity": 0,
    "parameters": {},
    "comment": "# Returns the primary key column's value.",
    "name": "id",
    "belongs_to": "ActiveRecord::AttributeMethods::PrimaryKey",
    "super_method": null
  }
}

```

#### Editor integration

See below

#### Further usage examples:

`$ qdocs --help` 

## Editor integration

Feel free to add others! 

- [Vim](https://github.com/johansenja/qdocs-vim) 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/johansenja/qdocs.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

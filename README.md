# miner

A standalone SQL ORM library for [Crystal](http://crystal-lang.com)

> **IMPORTANT:** This library is still under heavy development, and is far from ready for use in your Crystal projects.

## Todo List

- [x] Query Builder
- [ ] Execute Queries
- [ ] Models
- [ ] Collections
- [ ] Auto-discovery of relationships
- [ ] Auto-casting of field values based on column type

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  miner:
    github: molovo/miner
```

## Usage

```crystal
require "miner"

# Create a config object
config = Miner::Config.new({
  "name" => "my_database",
  "username" => "foo",
  "password" => "bar"
})

# Set the default database
Miner.set_default_database Miner::Database.new(config)

# Create a query
query = Miner::Query.new("countries")
  .select("name", "population")
  .join("city")
    .select({"name", "capital"})
    .on("id", "=", "parent.capital")

# Fetch the results
countries = query.fetch # => Miner::Collection

# Output the result set as JSON
puts countries.to_json
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/[your-github-name]/miner/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[your-github-name]](https://github.com/[your-github-name]) James Dinsdale - creator, maintainer

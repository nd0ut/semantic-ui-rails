# Semantic UI
UI is the vocabulary of the web.

Semantic empowers designers and developers by creating a language for sharing UI.

Homepage: http://semantic-ui.com/

## SASS
Please use the [semantic-ui-sass](https://github.com/doabit/semantic-ui-sass) gem.

## Installation
Inside your Gemfile add the following lines:
```ruby
gem 'therubyracer', platforms: :ruby # or any other runtime
gem 'less-rails'
gem 'autoprefixer-rails'
gem 'semantic-ui-rails'
```
Then run `bundle install` to install gems.

Run generator to include assets to your project
```bash
rails g semantic:install
```

## Versioning
First three numbers are the version of Semantic UI.

Last single number is the version of this gem with the same Semantic UI version.

i.e. `0.3.5.3` means that `0.3.5` is Semantic UI version and `.3` is the rails gem version.

## Pull Semantic UI from it's repository
If you want to update version to newer, run
`thor semantic:update`
from gem root path and create new Pull Request

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

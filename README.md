# Quicken
![Quicken](https://avatars2.githubusercontent.com/u/42966791?s=200&v=4)
  
**Stimulate your development!** Quicken is a command line tool to generate software project based on clear, repeatable recipes.

Quicken is a software project scaffolder written in Ruby. 
It allows to create projects based on a *recipe* that defines steps necessary to create and configure new projects.
It is based on an extensible plugin architecture that allows anyone to write custom generators based on their needs.
See [Plugins](#plugins) for more informations


Table of Contents
=================

  * [Installation](#installation)
  * [Usage](#usage)
  * [Recipes](#recipes)
     * [Example](#example)
  * [Plugins](#plugins)
     * [Install Plugins](#install-plugins)
     * [Write New Plugins](#write-new-plugins)
     * [Helpers](#helpers)
     * [Distribute Plugins](#distribute-plugins)
  * [Development](#development)
  * [Contributing](#contributing)
  * [Code of Conduct](#code-of-conduct)
  * [Attributions](#attributions)


## Installation

Install it via **RubyGems**

    $ gem install quicken-ruby

## Usage

Upon installing the `qk` executable will be available in your command line. 
Run `qk help` to see a list of all available commands and flags.

The most important ones are:

- `qk init` Initialize a new `recipe.yml` file in the current directory with a base template.  
Pass the `-e` flag to create an empty file

- `qk init plugin [NAME]` Initialize a new project for a Quicken plugin in a new directory called `quicken-NAME` under the current folder.

- `qk create` Create a new project in the current directory using the default recipe file, which is looked for in the 
directory itself as `recipe.yml`.  
Specify a custom file by passing its path to the `-f` flag (supports both local files
and remote ones via HTTP/HTTPS, so you can host your recipe files on something GitHub Gist and pass the raw file URL).

## Recipes
Recipe files are YAML files defined as a list of steps, which will be executed sequentially in the order they are defined.  
Steps are identified by the corresponding plugin name and optional arguments defined by the plugin itself.

### Example

```yaml
- echo: This is an example recipe

- readme:
    project_name: Quicken
    author_name: Matteo Joliveau
    author_email: matteojoliveau@gmail.com
    description: This is a test project generated by Quicken!
    
- echo: I will run after the readme plugin
```

## Plugins
Plugins are the core of Quicken. They implement the actual scaffolding logic and allow for extensions to be quickly written.  

### Install Plugins
Plugins are packaged as Ruby gems under the name `quicken-PLUGINNAME`, for example `quicken-git`.
Installing a new project is as simple as running `gem install quicken-git`.

### Write New Plugins
Plugins consist in a plain Ruby class implementing `initialize(args)`, where `args` is an hash extracted from the recipe file, 
and `call()`. They live under the namespace `Quicken::Plugins` and must be requirable from `quicken/plugins/NAME`.

An example of bare minumum Quicken plugin:

```ruby
module Quicken
  module Plugins
    class MyPlugin
      def initialize args
        @args = args
      end
      
      def call
        puts "Called with args: #{@args}!"
      end
    end
  end
end
```  

Quicken offers a set of classes and modules to ease plugins development. The most useful one is the `Quicken::Plugin` class, which
includes some basic helper methods and defines a standard constructor as:
```ruby
def initialize args
  @args = args
end
```

So the above example can be rewritten as:

```ruby
require 'quicken'

module Quicken
  module Plugins
    class MyPlugin < Quicken::Plugin
      def call
        puts "Called with args: #{@args}!"
      end
    end
  end
end
```

### Helpers

There are also some helper modules that add convenience methods to run commonly used logic, like prompt the user or access files.  
The basic one is `Quicken::Helpers::Base`, which is automatically included by extending the `Plugin` class and offers many
useful methods taken from `Thor::Shell::Basic`, like `say` or `ask`.

```ruby
require 'quicken'

module Quicken
  module Plugins
    class MyPlugin < Quicken::Plugin
      def call
        color = ask 'What is your favourite color?', default: 'blue'
        say "I like #{color} too!"
      end
    end
  end
end
```

If your plugin needs to work with files, include `Quicken::Helpers::File`.

```ruby
require 'quicken'

module Quicken
  module Plugins
    class MyPlugin < Quicken::Plugin
      include Quicken::Helpers::File
      
      def initialize args
        @path = args[:path]
      end
      
      def call
        @file = read_file @path
        say "The file contains: #{@file}"
        
        outcome = write_file 'hello.txt', 'Hello!'
        if outcome == :file_exists
          say 'README already present. Skipping...'
        else
          say 'Created hello.txt file!'
        end
      end
    end
  end
end
```

`Quicken::Helpers::Template` provides methods to work with ERB templates, like `parse` to parse template strings, and `compile` to generate the final 
value from variables.  
This is how the `readme` plugins generates new README.md files.

```ruby
require 'quicken'

module Quicken
  module Plugins
    class Readme < Quicken::Plugin
      include Quicken::Helpers::File
      include Quicken::Helpers::Template

      def initialize args
        @template = args.delete(:template)
        @variables = args
        parse template
      end

      def call
        result = compile @variables
        outcome = write_file 'README.md', result
        if outcome == :file_exists
          say 'README already present. Skipping...'
        else
          say 'Created README file'
        end
      end

      private

      def template
        @template ||= DEFAULT
      end

      DEFAULT = <<~ERB
        # <%= project_name %>
        ### by <%= author_name %> <<%= author_email %>>
        ---
        <%= description %>
      ERB
    end
  end
end
```

### Distribute Plugins
Plugins must be packaged as Ruby gems under the name `quicken-PLUGINNAME`, for example `quicken-git`.
The main entry point must be located under `lib/quicken/plugins`.
This is an example of plugins folder structure:

```
.
├── Gemfile
├── Gemfile.lock
├── LICENSE
├── README.md
├── Rakefile
├── bin
│   ├── console
│   └── setup
├── lib
│   └── quicken
│       ├── git
│       │   └── version.rb
│       ├── plugins
│       │   └── git.rb
│       └── git.rb
└── quicken-git.gemspec

```

## Development

This repo uses the [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/) paradigm to organize and manage branches. Please refer to [this cheatsheet](https://danielkummer.github.io/git-flow-cheatsheet/) for more informations.

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/quicken-rb/quicken. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Quicken project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/quicken/blob/master/CODE_OF_CONDUCT.md).

## Attributions

Logo made by [srip](https://www.flaticon.com/authors/srip) from [www.flaticon.com](https://www.flaticon.com/) is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a>


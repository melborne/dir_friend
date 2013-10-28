# DirFriend

`DirFriend` is a tool for visualizing file directory.

## Installation

Add this line to your application's Gemfile:

    gem 'dir_friend'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dir_friend

## Usage

In your terminal, try followings;

    # Show help
    % dir_friend

    # Create a dot file for path/to/project
    % dir_friend dot path/to/project
    
    # Create with some options
    % dir_friend dot path/to/project -l fdp -c blues --dir_shape box
    % dir_friend dot path/to/project -g "bgcolor:azure,rkdir:LR,splines:ortho"

In your ruby script;

```ruby
require 'dir_friend'

dir = DirFriend::D.new('path/to/project')

# Show info
dir.info #=> {:directories=>7, :files=>2, :depth=>3}

# Show children in the directory
puts dir.entries
>> F: Gemfile
>> D: lib
>> F: LICENSE.txt
>> F: myproject.gemspec
>> F: Rakefile
>> F: README.md

# Traverse all files and directories under the directory
dir.each do |f|
  puts f.path
end
>> /project/myproject/Gemfile
>> /project/myproject/lib
>> /project/myproject/lib/myproject
>> /project/myproject/lib/myproject/version.rb
>> /project/myproject/lib/myproject.rb
>> /project/myproject/LICENSE.txt
>> /project/myproject/myproject.gemspec
>> /project/myproject/Rakefile
>> /project/myproject/README.md

# Output a dot data(Gviz object)
puts dir.to_dot # => dot data

# with options
opt = {colorscheme:greens, layout:'fdp', global:"bgcolor:azure,splines:ortho" }
puts dir.to_dot(opt)

# Save to a file
dir.to_dot.save(:mydot)

# Open Graphviz.app with tempfile for dot data(mac only)
dir.to_dot open:true
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

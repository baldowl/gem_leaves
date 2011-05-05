require 'optparse'
require 'yaml'

# Amateurish prototype of a tool to check the installed gems looking for
# _leaves_ that can be removed.
# 
# I call _leaves_ those gems with no reverse dependency that can be removed
# without breaking anything. Of course, users may desire to keep something
# around even if nothing depends on it, so this tool looks for and loads a
# simple YAML configuration file:
# 
#   ignore:
#     RedCloth: >= 0
#     capistrano: >= 2
#     mongrel_cluster: >= 0
#     piston: >= 0
#     rake: >= 0.7
#     rubygems-update: >= 0
#     ruport-util: = 0.10.0
#     sources: >= 0
# 
# <tt>gem_leaves</tt> can generate its own configuration file merging the
# leaves list with the content of an already loaded configuration file (if
# any). The tool looks for the default configuration file,
# <tt>.gem_leaves.yml</tt>, in the current working directory and the user's
# home directory.

class GemLeaves
  VERSION = '1.0.9'

  def initialize(args)
    @options = {:color => "d0ed0e"}
    @configuration = {}
    @leaves = []
    parse_options(args)
  end

  def run
    load_config_file
    find_leaves
    show_leaves
    generate_config_file
  end

  protected

  # Parses the command line arguments.
  def parse_options(args)
    OptionParser.new('Usage: gem_leaves [OPTIONS]') do |p|
      p.separator ''
      p.on('-c', '--config-file=FILE', 'Load the named configuration file') {|v| @options[:config_file] = v}
      p.on('-C', '--color=COLOR', "Set the leaves' color in the DOT diagram") {|v| @options[:color] = v}
      p.on('-d', '--diagram', 'Generate a DOT diagram on stdout') {|v| @options[:diagram] = v}
      p.on('-g', '--generate-config-file=FILE',
        "Generate a new configuration file merging",
        "the leaves' list with the content of the",
        "old configuration file (if any)") {|v| @options[:new_config_file] = v}
      p.on('-i', '--ignore', 'Ignore every configuration file') {|v| @options[:ignore] = v}
      p.on('-p', '--pipe', 'Pipe Format (name --version ver)') {|v| @options[:pipe] = v}
      p.on('-r', '--reverse', "Reverse the edges in the DOT diagram") {|v| @options[:reverse] = v}
      p.parse(args)
    end
  end

  # Looks for a YAML configuration file in:
  # 
  # 1. the PWD;
  # 2. the user's home directory.
  # 
  # Optionally load a specific configuration file whose name has been set by
  # the user.
  def load_config_file
    if @options[:ignore]
      @configuration = {'ignore' => {}}
    else
      if @options[:config_file].nil?
        cf = ['.gem_leaves.yml', File.join(find_home, '.gem_leaves.yml')]
        cf.each {|f| (@configuration = YAML.load_file(f); return) rescue nil}
        @configuration = {'ignore' => {}}
      else
        @configuration = YAML.load_file(@options[:config_file])
      end
    end
  end

  # Lifted from RubyGems 0.9.5; it's a semi-portable way to find the user's
  # home directory.
  def find_home
    ['HOME', 'USERPROFILE'].each do |homekey|
      return ENV[homekey] if ENV[homekey]
    end
    if ENV['HOMEDRIVE'] && ENV['HOMEPATH']
      return "#{ENV['HOMEDRIVE']}:#{ENV['HOMEPATH']}"
    end
    begin
      File.expand_path("~")
    rescue StandardError => ex
      if File::ALT_SEPARATOR
        "C:/"
      else
        "/"
      end
    end
  end

  # Looks at the installed gems to find the _leaves_.
  def find_leaves
    ignorable = @configuration['ignore'].map do |k, v|
      Gem::Specification.find_all_by_name k, v
    end.flatten
    @leaves = Gem::Specification.select {|s| s.dependent_gems.empty?} - ignorable
  end

  # Show the leaves using one of the supported output format.
  def show_leaves
    if @options[:diagram]
      diagrammatical_output
    elsif @options[:pipe]
      pipe_output
    else
      textual_output
    end
  end

  # Simply puts the list of _leaves_ to STDOUT in a format suitable to pipe it
  # to RubyGems.
  def pipe_output
    @leaves.sort.each do |leaf|
      puts "#{leaf.name} --version #{leaf.version}"
    end
  end

  # Simply puts the list of _leaves_ to STDOUT. It optionally merges the
  # content of the already loaded configuration file with the leaves list.
  def textual_output
    @leaves.sort.each do |leaf|
      puts "#{leaf.name} (#{leaf.version})"
    end
  end

  # Build a DOT diagram of the installed gems, highlighting the leaves with
  # a customizable color, leaving those gems that *must* be kept according
  # to the current configuration in the standard color.
  def diagrammatical_output
    diagram = "digraph leaves_diagram {\n"
    Gem::Specification.all.each do |g|
      if @options[:reverse]
        g.dependent_gems.each {|d| diagram << %Q(  "#{d[0].full_name}" -> "#{g.full_name}"\n)}
      else
        g.dependent_gems.each {|d| diagram << %Q(  "#{g.full_name}" -> "#{d[0].full_name}"\n)}
      end
      if g.dependent_gems.empty?
        str = %Q(  "#{g.full_name}")
        if @leaves.include?(g)
          str += %Q( [color="##{@options[:color]}", style=filled]\n)
        else
          str += "\n"
        end
        diagram << str
      end
    end
    diagram << "}"
    puts diagram
  end

  # Writes the new configuration file merging the optionally already loaded
  # one with the leaves just found.
  def generate_config_file
    if @options[:new_config_file]
      @leaves.sort.each do |leaf|
        @configuration['ignore']["#{leaf.name}"] = "= #{leaf.version}"
      end
      File.open(@options[:new_config_file], 'w') do |out|
        YAML.dump(@configuration, out)
      end
    end
  end
end

gem_root = File.dirname(File.dirname(__FILE__))
$LOAD_PATH << File.join(gem_root, 'lib')
require 'omniboard'

RSpec::Matchers.define :include_tag do |name, props_hash|
  def processed(hash)
    hsh = hash.dup
    hsh.delete(:data).each{ |k,v| hsh["data-#{k}"] = v } if hsh.has_key? :data
    hsh
  end

  match do |string|
    string_props = processed(props_hash).map{ |k,v| %|#{k}="#{v}"| }

    occurances_of_tag = string.scan(/<#{name}[^>]*>/)
    occurances_of_tag.any?{ |tag| string_props.all?{ |sp| tag.include?(sp) } }
  end

  failure_message do |string|
    "#{string} should match tag #{name} with properties #{props_hash}, but doesn't."
  end
end

def render(obj)
  case obj
  when Omniboard::Column
    Omniboard::Renderer.new.render_column(obj)
  else
    raise RuntimeError, "I don't know how to render a #{obj.class} yet!"
  end
end

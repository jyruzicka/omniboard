gem_root = File.dirname(File.dirname(__FILE__))
$LOAD_PATH << File.join(gem_root, 'lib')
require 'omniboard'

RSpec::Matchers.define :include_tag do |name, props_hash|
  def processed(hash)
    return {} if hash.nil?
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
    if props_hash
      "#{string} should match tag <#{name}> with properties #{props_hash}, but doesn't."
    else
      "#{string} should match tag <#{name}>, but doesn't."
    end
  end
end

def render(obj)
  @renderer ||= Omniboard::Renderer.new
  case obj
  when Omniboard::Column
    @renderer.render_column(obj)
  when Rubyfocus::Project
    @renderer.render_project(wrap obj)
  when Omniboard::ProjectWrapper
    @renderer.render_project(obj)
  when  nil
    @renderer.to_s
  else
    raise RuntimeError, "I don't know how to render a #{obj.class} yet!"
  end
end

def wrap(obj)
  Omniboard::ProjectWrapper.new(obj)
end
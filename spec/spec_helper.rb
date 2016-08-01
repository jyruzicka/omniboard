gem_root = File.dirname(File.dirname(__FILE__))
$LOAD_PATH << File.join(gem_root, 'lib')
require 'omniboard'
require "rexml/document"

def truncate_string(str,truncate=80)
  if str.length <= truncate
    str
  else
    str[0..truncate] + "... [+#{str.length - truncate} chars]"
  end
end

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

RSpec::Matchers.define :contain_xpath do |xpath|
  match{ |string| !xml(string).elements.to_a(xpath).empty? }
  failure_message{ |string| "Expected the following to match XPath element '#{xpath}':\n#{truncate_string string}" }
  failure_message_when_negated{ |string| "Expected the following not to match XPath element '#{xpath}':\n#{truncate_string string}" }
end

RSpec::Matchers.define :contain_xpath_with_contents do |xpath, contents|
  match{ |string| xml(string).elements.to_a(xpath).any?{ |m| m.text == contents } }
  
  failure_message{ |string| "Expected the following to match XPath element '#{xpath}' with contents '#{contents}':\n#{truncate_string string}" }
end

RSpec::Matchers.define :contain_one_xpath do |xpath|
  match{ |string| xml(string).elements.to_a(xpath).size == 1 }
  failure_message{ |string| "Expected the following to match just one XPath element '#{xpath}':\n#{truncate_string string}" }
end

RSpec::Matchers.define :contain_n_of_xpath do |xpath, amnt|
  match{ |string| xml(string).elements.to_a(xpath).size == amnt }
  failure_message{ |string| "Expected the following to match #{amnt} XPath elements '#{xpath}':\n#{truncate_string string}" }
end


def xml(str)
  REXML::Document.new(str).root
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

def render_xml(obj)
  xml(render(obj))
end

def wrap(obj)
  Omniboard::ProjectWrapper.new(obj)
end
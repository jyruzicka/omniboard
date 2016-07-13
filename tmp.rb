string = "<foo>something?</foo>"
name = "foo"
occurances_of_tag = string.scan(/<(#{name}[^>]*)>(.*?)<\/#{name}\s*>/)
puts occurances_of_tag.inspect

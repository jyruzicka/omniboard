class String
  HTML_ESCAPE_CHARS = {
    "&" => "&amp;",
    ">" => "&gt;",
    "<" => "&lt;",
    '"' => "&quot;",
    "'" => "&#39;"
  }

  def html_escape
    HTML_ESCAPE_CHARS.reduce(self){ |str, (replace_this, with_this)| str.gsub(replace_this, with_this) }
  end

  # TODO Fix up all of these
	def sanitize
		self.gsub('"','\"').gsub("<","&lt;").gsub(">", "&gt;")
	end

	def sanitize_quotes
		self.gsub('"','&#34;')
	end
end
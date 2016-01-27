class String
	def sanitize
		self.gsub('"','\"').gsub("<","&lt;").gsub(">", "&gt;")
	end

	def sanitize_quotes
		self.gsub('"','&#34;')
	end
end
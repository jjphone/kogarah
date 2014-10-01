
class View
	include ActiveModel::Model
	attr_accessor :source, :site_url, :path, :flash, :current_user, :template, :data, :title, :syn_url

	def initialize(attributes = {} )
		attributes.each do |name, value|
			send("#{name}=",value)
			p "#{name} = #{value}"
		end
	end


	def related_links(relates)
		if self.data
			if self.data[:links] && data[:links][:level]
				self.data[:links] = {level: data[:links][:level], related: relates}
			else
				self.data[:links] = {level: nil, related: relates}
			end
		else
			self.data = {main: nil, paginate: nil, links: {level: nil, related: relates} }
		end
	end

	def level_links(levels)
		Rails.logger.debug("--- level_links" + self.inspect() )
		if self.data
			if self.data[:links] && data[:links][:related]
				self.data[:links] = { level: levels , related: data[:links][:related] }
			else
				self.data[:links] = { level: levels , related: nil }
			end
		else
			self.data = {main: nil, paginate: nil, links: {level: levels, related: nil} }
		end
	end

	def main=(hash_obj)
		if self.data
			self.data[:main] = hash_obj
		else
			self.data = {main: hash_obj, paginate: nil, links: nil}
		end
	end
	
	def paginate(hash_obj)
		if self.data
			self.data[:paginate] = hash_obj
		else
			self.data = {main: nil, paginate: hash_obj, links: nil }
		end
	end

	def parse_user(user, suffix, ok_page, nok_page)
		if user 
			self.title = "Trainbuddy | #{user.name}"
			self.template = ok_page
			self.main = user.errors.count>0 ? {type:"user", pack:user.to_h({errors: user.errors.messages})} : {type:"user", pack:user.to_h(nil)}
			self.path[:current] = "/users/#{user.id}#{suffix}"
			true
		else
			self.title = "Trainbuddy"
			self.template = nok_page
			self.flash={error: "User not found"}
			self.path[:current] = "/users"
			false
		end
	end

	def parse_paginate(type, obj, path, raw)
		if obj.size > 0 
			self.paginate({type: type, page: obj.current_page.to_i, total: obj.total_pages, path: path, pack: raw, loading: false})
		else
			self.paginate({type: type, page: obj.current_page.to_i, total: obj.total_pages, path: path, pack: nil, loading: false})
		end
	end

	def persisted?
		false
	end
end

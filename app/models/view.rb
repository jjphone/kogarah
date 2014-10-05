
class View
	include ActiveModel::Model
	attr_accessor :source, :site_url, :title, :path, :flash, :current_user, :template, :data, :syn_url

	def initialize(obj)
		self.path = obj[:path]
		self.flash = obj[:flash]
		self.current_user = obj[:current_user]
		self.template = obj[:template]
		self.title = obj[:title]

		self.syn_url = false
		self.data = {main: nil, paginate: nil, links: nil}
	end

	def main=(obj)
		h = {main: obj}
		self.data.merge! h
	end

	def relative_links=(relates)
		h = {links: {related: relates} }
		self.data.merge! h
	end

	def level_links=(levels)
		h = {links: {level: levels} }
		self.data.merge! h
	end

	def locations=(current, prev)
		self.path[:current] = current
		self.path[:pre] = prev if prev
	end

	def paginates(type, path, obj, json_hash)
		p = {type: type, page: obj.current_page.to_i, total: obj.total_pages, path: path, loading: false, pack: nil}
		p[:pack] = json_hash if obj.size > 0
		self.data.merge!( {paginate: p} )
	end

	def user_main(user)
		self.title ||= "Trainbuddy | #{user.name}"
		self.main = {type: "user", pack: user.errors.count>0 ? user.to_h({errors: user.errors.messages}) : user.to_h(nil) }
		self
	end

	def persisted?
		false
	end
end

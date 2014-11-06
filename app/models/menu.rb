class Menu < ActiveRecord::Base
	belongs_to :link
	default_scope -> { order(:order) }

end
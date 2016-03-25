class Sexo < ActiveRecord::Base
	def name_literal
		self.id==1 ? 'masculino' : 'feminino'
	end
end

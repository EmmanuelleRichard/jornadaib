class Tipousuario < ActiveRecord::Base

	def usuario?
		id==0
	end
	def administrador?
		id==1
	end
	def partner?
		id>1
	end
	# def partnerjunior?
	# 	id==3
	# end	
end

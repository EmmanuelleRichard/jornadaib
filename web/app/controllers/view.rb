class ViewController < ApplicationController
	logger.debug 'entrou no ViewController'
	
	def page
		logger.debug 'entrou no page'
	 	@path = params[:path]
	  	render :template => 'views/' + @path, :layout => nil
	end
end

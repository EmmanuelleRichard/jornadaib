class PageController < ApplicationController
	logger.debug 'entrou no PageController'
	layout :selecionalayout #"principal"
	#logger.debug params[:id]
	
	def index
		
	end	
  
	def show
		if params[:id]
			  render :action => params[:id]
		end  
	end
  
	def in
		if params[:id]
		  render :action => params[:id]
		end
	end 
	
	def selecionalayout  	
		logger.debug 'entrou no seleciona layout'
		logger.debug params[:action]

		if params[:action]=="s2desktop"
			return nil
		else
			return 'application' #'principal'
		end
	end	
end

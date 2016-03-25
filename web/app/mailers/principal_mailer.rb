# encoding: utf-8

class PrincipalMailer < ActionMailer::Base
	default from: "#{Principal.codigo} <#{Principal.emailcontato}>"
  
	def envia_principal_email(params)
		logger.debug 'envia_principal_email.entrou'
		
		@name_from = params[:nome_from]
		@email_para = params[:email_para]
		@nome_para = params[:nome_para]
		@assunto = params[:assunto]
		@mensagem = params[:mensagem]
		@bcc=params[:email_bcc] || Principal.emailcontato
		
		@email_from=params[:email_from] || Principal.emailcontato
		# email_with_name = "#{@user.name} <#{@user.email}>"
		
		mail(:to => "#{@nome_para} <#{@email_para}>", :subject => @assunto, :from => "#{@name_from} <#{@email_from}>", :bcc => @bcc) do |format|
		  format.html { render 'principal_email' } #app/views/s2_mailer/s2_email.html.erb
		end
	end  
	
  # send password reset instructions
  	def reset_password_instructions(user, opts={})
     	@resource = user
     	mail(:to => @resource.email, :subject => "[#{Principal.codigo}] Instruções para alterar a senha", :tag => 'password-reset', :content_type => "text/html") do |format|
       		format.html { render "devise/mailer/reset_password_instructions" }
    	end
	end 	
	#def confirmation_instructions(user, opts={})
	def confirmation_instructions(user, opts={}, zzzz)
		logger.debug 'confirmation_instructions.entrou'
		logger.debug user
		logger.debug opts
		logger.debug zzzz
		@resource = user
		mail(:to => @resource.email, :subject => "[#{Principal.codigo}] Confirmação de cadastro", :tag => 'confirmation_instructions', :content_type => "text/html") do |format|
			format.html { render "devise/mailer/confirmation_instructions" }
		end
	end   
end

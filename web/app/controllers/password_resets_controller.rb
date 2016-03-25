class PasswordResetsController < ApplicationController
	before_filter :load_user_using_perishable_token, :only => [:edit, :update]
	layout :layoutpadrao
	def new
	end
	def create
		@user = User.find_by_email(params[:email])
		if @user && @user.deliver_password_reset_instructions!
			send_email_password_reset
			flash[:notice] = "Foi enviado por e-mail a instrucao de como alterar a sua senha."
			if params[:negocio]
				redirect_to login_path(:negocio=>params[:negocio])
			else
				redirect_to login_path
			end
		else
			flash[:notice] = "Nenhum usuario com o e-mail informado!"
			render :action => :new
		end
	end
	def edit
	render
	end
	def update
		@user.password = params[:user][:password]
		@user.password_confirmation = params[:user][:password_confirmation]
		if @user.save
			flash[:notice] = "Senha alterada com sucesso!"
			redirect_to edit_user_path(@user)
		else
			render :action => :edit
		end
	end
	private
	def load_user_using_perishable_token
		@user = User.find_using_perishable_token(params[:id])
		if !@user
			flash[:notice] = "Link invalido"
			redirect_to :controller => "users", :action => "new"
		end
	end
	#Envia email (instrucoes para recuperar a senha)
	def send_email_password_reset
		logger.debug 'send_email_passuword_reset'
		logger.debug @user.perishable_token
		corpo = <<-CODE
		<b>Instrucoes para mudar a senha<br /></b>
		<b>Login: </b>#{@user.login}<br />
		<b>E-mail: </b>#{@user.email}<br />
		<b>Para trocar a senha <b>Link: </b><a href='#{edit_password_reset_url(@user.perishable_token)}'>clique aqui.</a>
		CODE
		Email.deliver_padrao(:corpo => corpo, :assunto => "Instrucoes para trocar a senha", :para => @user.email)
	end 
end

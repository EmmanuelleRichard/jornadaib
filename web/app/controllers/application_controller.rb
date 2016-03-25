# encoding: utf-8

class ApplicationController < ActionController::Base
  	include DeviseTokenAuth::Concerns::SetUserByToken
	protect_from_forgery with: :null_session
	helper :all
	helper_method :current_user_session, :current_user_admin? , :current_user_partner? , :fv_registraacesso, :fv_responsavel? #esses metodos estarão acessíveis no helper também
	
	respond_to :json

	before_action :configure_permitted_parameters, if: :devise_controller?

	include SimpleCaptcha::ControllerHelpers
	

	def index
		render 'layouts/application'
	end
	# filter_parameter_logging :password, :password_confirmation #filtramos os campos de senha, para que o mesmo não aparece legivelmente nos logs.
=begin
	#Não use esse método como privado, para que possa interagir com outros plugins(Ex.: o plugin rails_authorization)
	def current_user #retorna o usuário atual
		return @current_user if defined?(@current_user)
		@current_user = current_user_session && current_user_session.record
	end
=end

	# def require_user
	# 	logger.debug 'require_user.entrou'
	# 	logger.debug params
	# 	logger.debug request  		
	# 	logger.debug request.headers['client']  		
	# 	logger.debug request.headers['access-token']	
	# end

 #  	def current_user
 #  		logger.debug 'criado por rick para funcionar o devise_token_auth'
	# 	logger.debug params
	# 	logger.debug request  		
	# 	logger.debug request.headers['client']  		
	# 	logger.debug request.headers['access-token']	
		

	#     client_id = request.headers['client']
	#     token = request.headers['access-token']

	#     logger.debug client_id
	#     logger.debug token

	#     # logger.debug valid_token?(token, client_id)
	    
	#     user = User.find_by_uid(request.headers["uid"])  		
 #  	end

  	def angular
    	render 'layouts/application'
	end

	def current_user_comercial? #retorna se o usuario atual é admin
		if current_user
			return current_user.comercial
		end
	end	
	
	def current_user_suporte? #retorna se o usuario atual é admin
		if current_user
			return current_user.suporte
		end
	end	
	
	def current_user_admin? #retorna se o usuario atual é admin
		if current_user
			return current_user.admin
		end
	end		

	def current_user_partner? #retorna se o usuario atual é partner
		if current_user
			return current_user_admin? || Partner.exists?(:user_id=>current_user)
			#return current_user.partner
		end
	end		
	
 	def fv_responsavel?(negocio)
 		logger.debug 'fv_responsavel?.entrou'
 		logger.debug params

		if current_user and negocio
			logger.debug negocio.user_id
			logger.debug current_user.id
			logger.debug current_user_admin?
			
			negocio.user_id==current_user.id or current_user_admin? 
		else
			logger.debug 'false'
			false
		end
	end

	private

  	def configure_permitted_parameters
    	# devise_parameter_sanitizer.for(:sign_up) << :username
    	devise_parameter_sanitizer.for(:sign_up) << :user
  	end

	def current_cart
		logger.debug 'entrou no current_cart'
		begin
			Cart.find(session[:cart_id]) 
		rescue ActiveRecord::RecordNotFound
			logger.debug 'nao encontrou'
			cart = Cart.create
			cart.user_id=current_user.id
			if !current_user_admin?
				cart.cliente_id=current_user.cliente.id
				cart.endereco=current_user.endereco
				cart.numero=current_user.numero
				cart.complemento=current_user.complemento
				cart.bairro=current_user.bairro
				cart.municipio=current_user.municipio
				cart.uf=current_user.uf
				cart.cep=current_user.cep
				cart.geoname_id=current_user.geoname_id
				cart.pontoreferencia=current_user.pontoreferencia
				cart.telefone1=current_user.telefone1
				cart.telefone2=current_user.telefone2
			end
			cart.save
			logger.debug cart.user_id

			@cartstatus=Cartstatu.new(:cart_id=>cart.id, :user_id=>current_user.id, :status=>Cartstatu.status_id(:adicionando))
			@cartstatus.save

			session[:cart_id] = cart.id
			#session[:cart_id] = cart.codigo
			cart
		end
	end

	def current_user_session #retorna a sessão do usuário atual
		return @current_user_session if defined?(@current_user_session)
		@current_user_session = UserSession.find
	end

	def require_user #informa o que precisa estar logado
		# unless current_user
			# flash[:error]= 'Não permitido'
			# store_location
			# redirect_to login_path #new_user_session_url
			# return false
		# end
		
		unless current_user
			store_location
			redirect_to(login_path, :flash => { :error => 'É necessário logar-se para continuar.'} ) and return
			return false
		end		
	end
	
	def require_admin #informa o que precisa estar logado
		store_location
		if current_user
			if !current_user.admin?
				flash[:error]= 'Não permitido - Admin'
				redirect_to root_path #new_user_session_url
				return false		
			end
		else
			flash[:error]= 'Não permitido'
			store_location
			redirect_to root_path #new_user_session_url
			return false
		end
	end
	
	def require_partner #informa o que precisa estar logado
		store_location
		if current_user
			if !current_user_partner?
				flash[:error]= 'Contacte um Parceiro do Ah!Tah!'
				redirect_to root_path #new_user_session_url
				return false		
			end
		else
			flash[:error]= 'Contacte um Parceiro do Ah!Tah!'
			store_location
			redirect_to root_path #new_user_session_url
			return false
		end
	end

	def require_no_user #informa o que não precisa estar logado
		if current_user
			store_location
			redirect_to root_path
			return false
		end
	end

	def store_location #retorna a ultima url que nao pode ser acessada, pois o usuario nao estava logado
		logger.debug 'store_location'
		logger.debug "http://#{request.host}:#{request.port.to_s+request.fullpath}"
		session[:return_to] = "http://#{request.host}:#{request.port.to_s+request.fullpath}" #request.fullpath  #request_uri
	end

	def redirect_back_or_default(default) #retorna para a ultima url que não pode ser acessada ou a definida como default
		redirect_to(session[:return_to] || default)
		session[:return_to] = nil
	end
	
	def trata_negocio_id
		if params[:negocio_id]
			if (params[:negocio_id].to_i.to_s != params[:negocio_id])  
				@negocio = Negocio.find_by_codigo(params[:negocio_id])
				params[:negocio_id]=@negocio.id
			end  
		end
	end  	
	
	def layoutpadrao #(negocio_id)
		logger.debug 'layoutpadrao'
		if params[:negocio_id]
			negocio_id=params[:negocio_id]
		elsif  params[:negocio]
			negocio_id=params[:negocio]
		end
		logger.debug negocio_id #params[:negocio_id]
		#if params[:negocio_id]
		if negocio_id
			@negocio = Negocio.find_by_codigo(negocio_id)
			@negocio.layout
=begin			
			if @negocio.temsitegold
				'negociositegold'
			elsif @negocio.temsite
				'negociosite'	
			else
				'application'			
			end
=end			
		else
			'application'
		end
	end	

	def fv_registraacesso(negocio)
		logger.debug 'fv_registraacesso.entrou'
		logger.debug params[:negocio_id]
		logger.debug negocio
		acesso=Negocioacesso.find_by_negocio_id_and_data(negocio, Time.now.to_date)
		if acesso
			acesso.update_attribute :quant, acesso.quant.succ
		else
			acesso=Negocioacesso.new
			acesso.negocio=@negocio
			acesso.data=Time.now.to_date
			acesso.quant=1
			acesso.save
		end
		logger.debug 'fv_registraacesso.saiu'
	end
	
#app_registra_atividade(@noticia.negocio, current_user, @noticia, current_user.login+' adicionou uma not&iacute;cia no Neg&oacute;cio '+@noticia.negocio.codigo)      	
	# def app_registra_atividade(negocio, user, objeto, descricao)
	def app_registra_atividade(params)
		logger.debug 'app_registra_atividade.entrou'
		
		vnegocio=params[:negocio]
		vuser=params[:user] || current_user
		vobjeto=params[:objeto]
		vdescricao=params[:descricao]
		venviaemail=params[:enviaemail] ? params[:enviaemail] :  false
		
		@registroatividade=Registroatividade.new
		@registroatividade.negocio=vnegocio	#params[:negocio] if params[:negocio]# @recado.negocio
		@registroatividade.user=vuser	#user #current_user
		@registroatividade.registravel=vobjeto	#objeto #@recado
		@registroatividade.descricao=vdescricao	#descricao #user.nome+' adicionou um recado no Negocio '+@recado.negocio.nome
		@registroatividade.save
		
		#fv_envia_email(negocio, user_para, assunto, mensagem, nome_from='')
		
		if venviaemail
			logger.debug 'vai chamar fv_envia_email'
			if vobjeto.is_a?Indicacao
				fv_envia_email(
					nil, #negocio	Nao envia email para todos os que estao ligados no negocio
					vnegocio.user, #user
					'[Ah!Tah!] '+vobjeto.user.login+' indicou '+vobjeto.negocio.nome,
					@registroatividade.descricao
				)	
			elsif vobjeto.is_a?Conexao
				fv_envia_email(
					nil, #negocio	Nao envia email para todos os que estao ligados no negocio
					vnegocio.user, #user
					'[Ah!Tah!] '+vobjeto.user.login+' conectou-se a '+vobjeto.negocio.nome,
					@registroatividade.descricao
				)	
			elsif vobjeto.is_a?Noticia
				fv_envia_email(
					vnegocio, #negocio
					vnegocio.user, #user
					'[Ah!Tah!] '+vnegocio.codigo+' - '+vobjeto.titulo,
					'veja o novo post no blog'
				)	
			elsif vobjeto.is_a?Classificado	
				if vnegocio
					fv_envia_email(
						vnegocio, #negocio
						vnegocio.user, #user
						'[Ah!Tah!] Registro de atividades de '+vnegocio.nome, #assunto, 
						@registroatividade.descricao #mensagem
					)
				else
					fv_envia_email(
						nil, #negocio
						vuser, #user
						'[Ah!Tah!] Registro de atividades.', #assunto, 
						@registroatividade.descricao #mensagem
					)			
				end
			elsif vobjeto.is_a?Comentario
				if vobjeto.comentavel.is_a? Imagem
					@comentavel_user=vobjeto.comentavel.galeria.negocio.user
				elsif (vobjeto.comentavel.is_a? Classificado ) or (vobjeto.comentavel.is_a? Noticia)
					if vobjeto.comentavel.negocio
						@comentavel_user=vobjeto.comentavel.negocio.user
					else
						@comentavel_user=vobjeto.comentavel.user
					end
				else
					@comentavel_user=vobjeto.comentavel.user
				end
				
				if vobjeto.comentavel.is_a?Classificado
					mensagem=
						'<br/>'+
						vuser.nome+' postou uma pergunta no anúncio.'+vobjeto.comentavel.titulo+
						'<br/>'+
						'Para ver a pergunta acesse: '+
						'<a target="_blank" href="http://www.speedflash.com.br">'+
						'http://www.speedflash.com.br</a>.'
				elsif vobjeto.comentavel.is_a?Comentario
					mensagem=
						'<br/>'+
						vuser.nome+' respondeu a pergunta no anúncio.'+vobjeto.comentavel.comentavel.titulo+
						'<br/>'+
						'Para ver a resposta acesse: '+
						'<a target="_blank" href="http://www.speedflash.com.br">'+
						'http://www.speedflash.com.br</a>.'
				elsif vobjeto.comentavel.is_a?Video
					mensagem=
						'<br/>'+
						vuser.nome+' postou um comentário no vídeo '+vobjeto.comentavel.name+
						'<br/>'+
						'Para ver o comentário acesse: '+
						'<a target="_blank" href="http://www.speedflash.com.br">'+
						'http://www.speedflash.com.br</a>.'						
				elsif vobjeto.comentavel.is_a?Imagem
					mensagem=
						'<br/>'+
						vuser.nome+' postou um comentário em uma imagem da galeria '+vobjeto.comentavel.galeria.titulo+
						'<br/>'+
						'Para ver o comentário acesse: '+
						'<a target="_blank" href="http://www.speedflash.com.br/galerias/'+vobjeto.comentavel.galeria.id.to_s+'/showimagem?imagem='+vobjeto.comentavel.id.to_s+'">'+
						'http://www.speedflash.com.br/galerias/'+vobjeto.comentavel.galeria.id.to_s+'/showimagem?imagem='+vobjeto.comentavel.id.to_s+'</a>.'	
				elsif vobjeto.comentavel.is_a?Noticia
					mensagem=
						'<br/>'+
						vuser.nome+' postou um comentário no post '+vobjeto.comentavel.titulo+
						'<br/>'+
						'Para ver o comentário acesse: '+
						"<a target='_blank' href='http://'#{request.host_with_port+url_for( negocio_noticia_path(vobjeto.comentavel.negocio.codigo, vobjeto.comentavel))}'>"+
						'http://'+request.host_with_port+url_for( negocio_noticia_path(vobjeto.comentavel.negocio.codigo, vobjeto.comentavel))+'</a>.'	
				end
				mensagem=
					mensagem+
					'<br/>'+
					'A equipe do Ah!Tah!'+
					'www.speedflash.com.br'+
					'<br/>'				
				fv_envia_email(
					nil, #negocio
					@comentavel_user, #user
					'[Ah!Tah!] mensagem para '+@comentavel_user.nome,
					mensagem	#mensagem
				)	
			elsif vnegocio
				fv_envia_email(
					vnegocio, #negocio
					vobjeto.user, #user
					'[Ah!Tah!] Registro de atividades de '+vnegocio.nome, #assunto, 
					@registroatividade.descricao #mensagem
				)		
			else		
				fv_envia_email(
					nil, #negocio
					vuser, #user
					'[Ah!Tah!] Registro de atividades.', #assunto, 
					@registroatividade.descricao #mensagem
				)
			end	
		end
	end

	def fv_envia_email(negocio, user_para, assunto, mensagem, nome_from='')
		logger.debug "entrou em fv_envia_email"
		logger.debug nome_from
		#nome_from='Ah!Tah!' #nome_from, 
		if !negocio 
			logger.debug 'sem negocio'
			nome_from='Ah!Tah!' if nome_from.blank?
			fv_envia_email_unico(nome_from, user_para.email, user_para.nome, assunto, mensagem, nil)
		#Se o usuario for o responsavel pelo negocio, envia para todos que estao linkados ao negocio
		elsif negocio.user==user_para
			logger.debug 'negocio.user==user_para'
			negocio.conexaos.each do |c|
				fv_envia_email_unico(nome_from, c.user.email, c.user.nome, assunto, mensagem, negocio)
			end
		else
			logger.debug 'caso contrario, envia para o responsavel pelo negocio '
			fv_envia_email_unico(nome_from, negocio.user.email, negocio.user.nome, assunto, mensagem, negocio)
		end		
	end

 	def fv_envia_email_unico(nome_from, email_para, nome_para, assunto, mensagem, objeto)
		logger.debug "entrou em fv_envia_email_unico"
		logger.debug nome_from
		logger.debug email_para
		logger.debug nome_para
		logger.debug assunto
		logger.debug mensagem
		if objeto
			logger.debug 'objeto'
			if objeto.is_a?Negocio
				logger.debug 'negocio'
				icone='http://'+request.host_with_port+objeto.picture.url(:thumb)	
				nome_from=objeto.nome if !nome_from
				nome_titulo=objeto.nome
			elsif objeto.is_a?User
				logger.debug 'user'
				icone='http://'+request.host_with_port+objeto.picture.url(:thumb)		
			end
		else
			icone='http://'+request.host_with_port+'/images/logo.png'
		end
		nome_titulo=nome_from if !nome_titulo
		logger.debug 'listou os parametros'
		if !assunto.blank? and !mensagem.blank? and !nome_from.blank?
			corpo = <<-CODE
			
<style type="text/css">
<!--
.style1 {
	color: #FFFFFF;
	font-weight: bold;
}
-->
</style>
<table cellspacing="0" cellpadding="40" border="0" width="98%">
  <tbody>
    <tr>
      <td bgcolor="#f7f7f7" width="100%" style="font-family: 'lucida grande',tahoma,verdana,arial,sans-serif;"><table cellspacing="0" cellpadding="0" border="0" width="620">
          <tbody>
            <tr bgcolor="#FF6633">
              <td bgcolor="#FF6633"  font-weight: bold; font-family: 'lucida grande',tahoma,verdana,arial,sans-serif; padding: 4px 8px; vertical-align: middle; font-size: 16px; letter-spacing: -0.03em; text-align: left;">
								<span class="style1">#{nome_titulo}</span>
							</td>
            </tr>
            <tr>
              <td valign="top" style="background-color: rgb(255, 255, 255); border-bottom: 1px solid rgb(59, 89, 152); border-left: 1px solid rgb(204, 204, 204); border-right: 1px solid rgb(204, 204, 204); font-family: 'lucida grande',tahoma,verdana,arial,sans-serif; padding: 15px;"><table width="100%">
                  <tbody>
                    <tr>
                      <td align="left" width="149" valign="top" style="padding-left: 15px;">
												<table cellspacing="0" cellpadding="0" width="100px" style="border-collapse: collapse;">
                          <tbody>
                            <tr>
                              <td>
																<a target="_blank">
																	<img width="100" style="border: 0pt none;" src="#{icone}">
																</a>
															</td>
                            </tr>
                          </tbody>
                        </table>
											</td>
                      <td width="427" align="left" valign="top" bgcolor="#FFFF99" style="font-size: 12px;">
				<b>Mensagem enviada por #{nome_from}<br /></b><br />		
				#{mensagem}<br />
											</td>
                    </tr>
                  </tbody>
                </table></td>
            </tr>
            <tr>
              <td style="color: rgb(153, 153, 153); padding: 10px; font-size: 11px; font-family: 'lucida grande',tahoma,verdana,arial,sans-serif;">Você está recebendo este e-mail de #{nome_from}.</td>
            </tr>
          </tbody>
        </table></td>
    </tr>
  </tbody>
</table>
			CODE
			# Email.deliver_padrao(:corpo => corpo, :assunto => assunto, :para => email_para)
			
			begin
				PrincipalMailer.envia_speedflash_email({:nome_from=>nome_from, :email_para=>email_para, :nome_para=>nome_para, :assunto=>assunto, :mensagem=>mensagem}).deliver
			rescue Exception => e
			
			end

				
			return if request.xhr?
#			flash[:notice]= 'E-mail enviado com sucesso.'
		else
			@form_error = 'Nao foi enviado o email'
			flash[:notice]= 'Nao foi enviado o email'
		end	
	end	
	
	def fv_extrai_id(id)
#		idreverso=(id.reverse).to_i
		#logger.debug idreverso
		
		#id=((idreverso.to_s).reverse).to_i
		id=id.split('-')[id.split('-').count-1]
	end
	def app_extrai_codigo_id(id)
#		idreverso=(id.reverse).to_i
		#logger.debug 'app_extrai_codigo_id'
		
		#id=((idreverso.to_s).reverse).to_i
		id=id.split('-')[id.split('-').count-1][0..-5]
		#logger.debug id
		#return id
	end	
	protected

	# def after_sign_in_path_for(resource)
		# logger.debug 'after_sign_in_path_for.entrou'
		# logger.debug params
		# # app_registra_atividade :nomeatividade=>current_user.name+' logou-se no sistema'
		# # app_registra_atividade( nil, current_user, current_user, current_user.nome+' logou-se no sistema')	
		# if params[:redirect_to]
			# logger.debug 'redirect_to:'+params[:redirect_to]
			
			# # current_user.loginempresa.update_columns :quantlogin=>(current_user.loginempresa.quantlogin || 0 ).to_i+1, :ultimologin=>Time.now
			
			# params[:redirect_to]
		# elsif session[:user_return_to]
			# logger.debug 'user_return_to:'+session[:user_return_to]
			
			# # current_user.loginempresa.update_columns( :quantlogin=>(current_user.loginempresa.quantlogin || 0 ).to_i+1, :ultimologin=>Time.now) if current_user.loginempresa
			
			# session[:user_return_to]
		# else
			# logger.debug 'vai para home'
			
			# # current_user.loginempresa.update_columns :quantlogin=>(current_user.loginempresa.quantlogin || 0 ).to_i+1, :ultimologin=>Time.now
			# # root_path	#(resource)
			# user_path(current_user.login)
		# end
	# end
# 	def after_sign_in_path_for(resource)
# 		logger.debug 'after_sign_in_path_for.entrou'
# 		logger.debug params
# 		logger.debug 'a'
# 		logger.debug session[:redirect_to]
# 		logger.debug 'b'
# 		logger.debug session[:previous_url]
# 		logger.debug 'c'
# 		logger.debug session[:return_to]
# 		logger.debug 'd'
# 		logger.debug session[:user_return_to]		
# 		#app_registra_atividade :nomeatividade=>current_user.name+' logou-se no sistema'
		
# 		# app_registra_atividade(current_user.nome+' logou-se no sistema', nil, nil, current_user, nil)
		
# # (negocio, user, objeto, descricao)
		
# # app_registra_atividade( nil, current_user, current_user, current_user.nome+' logou-se no sistema')	
# 		# current_user.atualizacliente if !current_user.cliente 
# 		# app_registra_atividade :user=>current_user, :objeto=>current_user, :descricao=>current_user.nome+' logou-se no sistema'
		
# 		# if session[:redirect_to]
# 		# 	logger.debug 'redirect_to:'+session[:redirect_to]
# 		# 	session[:redirect_to]
# 		# elsif session[:previous_url]
# 		# 	logger.debug 'previous_url:'+session[:previous_url]
# 		# 	session[:previous_url]			
# 		# elsif session[:return_to]
# 		# 	logger.debug 'return_to:'+session[:return_to]
# 		# 	session[:return_to]
# 		# elsif params[:return_to]
# 		# 	logger.debug 'return_to:'+params[:return_to]
# 		# 	params[:return_to]	
# 		# elsif params[:redirect_to]
# 		# 	logger.debug 'redirect_to:'+params[:redirect_to]
# 		# 	params[:redirect_to]				
# 		# elsif session[:user_return_to]
# 		# 	logger.debug 'user_return_to:'+session[:user_return_to]
# 		# 	session[:user_return_to]
# 		# else
# 		# 	if current_user.negocios.count>0
# 		# 		logger.debug 'vai para negocio'
# 		# 		# user_path(resource)
# 		# 		if current_user.lastnegocio
# 		# 			url_for('/'+current_user.lastnegocio.codigo)
# 		# 		else
# 		# 			url_for('/'+current_user.negocios.last.codigo)
# 		# 		end
# 		# 	else
# 		# 		# user_path(resource)
# 		# 		if current_user.partner?
# 		# 			user_path(current_user.login)
# 		# 		else
# 		# 			#url_for('/$'+current_user.login)
# 		# 			user_path(current_user.login)
# 		# 		end
# 		# 		# new_negocio_path, :notice => 'xxxxxxxxx'
# 		# 	end
# 		# end
# 	end	
	
	def after_sign_out_path_for(resource_or_scope)
		logger.debug 'after_sign_out_path_for.entrou'
		session[:redirect_to]=nil
		logger.debug session[:redirect_to]
		session[:previous_url]=nil
		logger.debug session[:previous_url]
		
		session[:return_to]=nil
		logger.debug session[:return_to]
		
		session[:user_return_to]=nil
		logger.debug session[:user_return_to]
		
		root_path
	end	
end



#2364759ad13fb6ca2a99bb318b9d152198fff2d2587aa290a8e4cf0fbdef7b55
#58553235715969451a68837042823ff0adb98cc8c9827e58ae75d1b6f9d4a441
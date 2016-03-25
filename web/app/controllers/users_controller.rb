# encoding: utf-8

class UsersController < ApplicationController
# 	before_filter :require_no_user, :only => [:new, :create]

	#before_filter :require_user, :only => [:edit, :update, :setapernapadrao, :editpassword, :editfoto, :desconectarnegocio, :escritorio, :redepartner, :redeafiliadospartner, :extratostandardpartner, :extratopremiumpartner, :cadastrospendentespartner, :afiliadospartner, :afiliadospartnerrede, :redeafiliadosafiliado, :homepartner, :mensagem, :download]

	vexcecao_user=[:busca_users, :show, :mural, :new, :create, :validalogin, :validapatrocinador, :validaemail, :validacpf, :validacnpj]

	before_filter :require_user, :except =>vexcecao_user
	before_filter :require_admin, :only => [:extornarpa, :extornarpc, :saqueregistra]
	
	layout :layoutpadrao
  # GET /users
  # Get /users.xml
	def index
		logger.debug 'entrou'
		vconditions=[]
		vconditions<<"users.nome like '%#{params[:nome]}%' or users.namereal like '%#{params[:nome]}%' " if !params[:nome].blank?	
		@users = User.where(vconditions.join(' and ')).order('LENGTH( picture_file_name ) >0 DESC, last_sign_in_at DESC, nome').limit(10).offset(params[:voffset])	
		
		if params[:voffset]
			if @users.count==0
				render :text=>'vazio'
			else
				app_registra_atividade :nomeatividade=>current_user.nome+' exibiu a relação de usuários'#, :objeto=>@users
				render :layout=>false, :template=>'users/index_paginate' 
			end
		end			
	end

	def busca_users
		@users = User.paginate :page => params[:page],  :per_page => 10,:conditions => ['nome like ? and status= ?', '%'+params[:nome_pesquisar]+'%', true], :order=>'nome'
		@ramoatividades = Ramoatividade.find(:all, :order=>'name')	
		respond_to do |format|
			format.html { render :action => 'index.html.erb' } 
			format.xml {render :xml => @users}
		end
	end	
  
  # GET /users/1 
  # GET /users/1.xml
    def show
    	logger.debug 'entrou no users.show'
    	params[:id]=params[:id].sub('$', '')
    	
		@user = User.find_by_login(params[:id])
		if @user
			if @user.status
				if (current_user and @user.partner and (current_user==@user or current_user_admin?))
					@mensagemsrecebidasnaolidas=Mensagem.where('userpara_id'=> @user.id, :status=>nil).order('created_at desc')	

					@existeticketaberto=(@user.tickets.joins(:ticketnotes).where("tickets.status is null and ticketnotes.user_id=1").count>0)
					
					@exibirpopupmensagens=(!@mensagemsrecebidasnaolidas.blank? or @existeticketaberto)

					@ofertacoletivas=Ofertacoletiva.joins(:negocio).where("negocios.user_id=#{@user.id}")
				else
					#redirect_back_or_default root_path	
				end
			else
				flash[:notice] = 'Usuario desativado.'
				redirect_back_or_default root_path			
			end
		else
			flash[:notice] = 'Usuario nao cadastrado.'
			redirect_back_or_default root_path
		end
    end
	
  # GET /users/1 
  # GET /users/1.xml
    def escritorio
		@user = User.find_by_login(params[:id])
		if @user
			if @user.status
				if (current_user and @user.partner and (current_user==@user or current_user_admin?))
					@mensagemsrecebidasnaolidas=Mensagem.find(:all, :conditions=>{'userpara_id'=> @user.id, :status=>nil}, :order=>'created_at desc')	

					@existeticketaberto=(@user.tickets.joins(:ticketnotes).where("tickets.status is null and ticketnotes.user_id=1").count>0)
					
					@exibirpopupmensagens=(@mensagemsrecebidasnaolidas.count>0 or @existeticketaberto)

					@ofertacoletivas=Ofertacoletiva.joins(:negocio).where("negocios.user_id=#{@user.id}")
				else
					redirect_back_or_default root_path	
				end
			else
				flash[:notice] = 'Usuario desativado.'
				redirect_back_or_default root_path			
			end
		else
			flash[:notice] = 'Usuario nao cadastrado.'
			redirect_back_or_default root_path
		end
    end

  def mural
  	logger.debug 'entrou no mural'
    @user = User.find_by_login(params[:id])
	
	if @user
		# if params[:voffset]
			# voffset=params[:voffset]
		# else
			# voffset=0
		# end
		
		# negocios=[]
		# users<<@user.id.to_s	
		
		# @friends = Friend.find(:all, :conditions=>'(user_id='+@user.id.to_s+' or friend_id='+@user.id.to_s+') and status=1', :select=>'user_id, friend_id')
		# @friends.each do |friend|
			# users<< friend.friend_id if !users.include?friend.friend_id
			# users<< friend.user_id if !users.include?friend.user_id
		# end
		# muralpartialmenorque=''
		# muralpartialmenorque<<' id < '+params[:muralpartialmenorque]+' and ' if params[:muralpartialmenorque]
		@vrecarrega=params[:vrecarrega]
		logger.debug @vrecarrega
=begin
logger.debug 'desativado para mostrar as novidades'
		if !@vrecarrega and !@user.conexaos.blank?
			logger.debug 'x'
			vcondicao=[]
			vcondicao<<'registroatividades.id<'+params[:atividade_id].to_i.to_s if !params[:atividade_id].blank?
			vcondicao<<"negocio_id in ( #{@user.conexaos.map {|x|x.negocio.id}.join(',')}) "
			vcondicao<<"registravel_type is not null"
			# vcondicao<<"registravel_type='Negocio' "
			vcondicao<<"registravel_type<>'Comentario' "
			
			# @registroatividades = Registroatividade.find_by_sql("SELECT `registroatividades`.* FROM `registroatividades` force index (index_atividades_recentes) WHERE ( ( user_id in (#{users.join(', ')}) or muraluser_id in (#{users.join(', ')}) ) and (acao_type='Noticia' or acao_type='Fotouserpicture') and acao_type<>'Comentario' ) ORDER BY created_at desc LIMIT 3")
			# @registroatividades = Registroatividade.find_by_sql("SELECT `registroatividades`.* FROM `registroatividades` WHERE ( ( negocio_id in (#{users.join(', ')}) or muraluser_id in (#{users.join(', ')}) ) and (acao_type='Noticia' or acao_type='Fotouserpicture') and acao_type<>'Comentario' ) ORDER BY created_at desc LIMIT 3")
			
			@atividades = Registroatividade.where(vcondicao.join(' and ')).order('created_at desc').limit(3).includes(:registravel)
			@ultimaatividade_id= @atividades.last.id if @atividades.last
			logger.debug @atividades.blank?
		end		
=end
#		if @user.conexaos.blank? or @atividades.blank?
			logger.debug 'desativado para mostrar as novidades'

			logger.debug 'y'
			vcondicao=[]
			vcondicao<<'registroatividades.id<'+params[:atividade_id].to_i.to_s if !params[:atividade_id].blank?
=begin			
			if @vrecarrega
				vcondicao<<"negocio_id in ( #{Conexao.select('distinct negocio_id').map {|x| x.negocio_id}.join(',')}) "
			else
				vcondicao<<"negocio_id is not null "
			end
=end			
			vcondicao<<"registravel_type is not null"
			# vcondicao<<"registravel_type='Negocio' "
			vcondicao<<"registravel_type<>'Comentario' "
			vcondicao<<"registravel_type<>'User' "
			
			# @registroatividades = Registroatividade.find_by_sql("SELECT `registroatividades`.* FROM `registroatividades` force index (index_atividades_recentes) WHERE ( ( user_id in (#{users.join(', ')}) or muraluser_id in (#{users.join(', ')}) ) and (acao_type='Noticia' or acao_type='Fotouserpicture') and acao_type<>'Comentario' ) ORDER BY created_at desc LIMIT 3")
			# @registroatividades = Registroatividade.find_by_sql("SELECT `registroatividades`.* FROM `registroatividades` WHERE ( ( negocio_id in (#{users.join(', ')}) or muraluser_id in (#{users.join(', ')}) ) and (acao_type='Noticia' or acao_type='Fotouserpicture') and acao_type<>'Comentario' ) ORDER BY created_at desc LIMIT 3")
			
			@atividades = Registroatividade.where(vcondicao.join(' and ')).order('created_at desc').limit(3).includes(:registravel)

			if !@vrecarrega and !@atividades.blank?
				@atividades.each do |atividade|
					if atividade.registravel.is_a?Negocio and atividade.registravel.picture_file_name.blank?
						@vrecarrega=true
					end
				end
			end
			@ultimaatividade_id= @atividades.last.id if @atividades.last
#		end		
		logger.debug 'desativado para mostrar as novidades'
		
		logger.debug 'prepara retorno'
		if params[:atividade_id]
			logger.debug 'tem atividade_id'
			logger.debug @atividades.count
			logger.debug @atividades.blank?
			if @atividades.blank?
				render :text=>params[:callback]+'({"id":0, "resultado":"vazio"});'
				# render :text=>'vazio'
			else



				# render :layout=>false, :template=>'users/muralaction'
				# vretorno=params[:callback]+'({"id":'+@ultimaatividade_id.to_s+',"data":['+ render_to_string('users/muralaction', :layout => false)+']});'
		# logger.debug vretorno
		# render :text=>vretorno				
				logger.debug 'retorna json'
				# logger.debug vretorno
				# render :text=>vretorno
				
				ActiveRecord::Base.include_root_in_json = false
			#render :text=>params[:callback]+'({"quantResults":'+ @atividades_length.to_s+', "resultado":'+ @atividades_json+'});'
			# render :text=>vretorno
				if defined? @vrecarrega
					vrecarrega=', "recarrega":1 ' 
				else
					vrecarrega=''
				end
				render :text=>params[:callback]+'({"id":'+ @ultimaatividade_id.to_s+vrecarrega+', "resultado":['+ render_to_string('users/muralaction', :layout => false).to_json+']});'
			
				ActiveRecord::Base.include_root_in_json = true	
			
				# render :json => {:id=>@ultimaatividade_id, :data => render_to_string('users/muralaction', :layout => false) }
			end
		else
			app_registra_atividade :nomeatividade=>current_user.nome+' exibiu o mural de '+@user.nome, :objeto=>@user
			@mensagemsrecebidasnaolidas=Mensagem.where({'userpara_id'=> current_user.id, :status=>nil}).order('created_at desc')
			
			# app_registraacesso @user
		end

		if params[:ajax]
			@ajax=true
			render :layout=>false 
		end
	else
		flash[:notice] = 'Usuário não localizado.'
		#redirect_to user_path(current_user)
		render :text=>'Usuário não localizado.'
	end
  end	
  # GET /users/new 
  # GET /users/new.xml
    def new
		logger.debug 'entrou no new'
		@user = User.new
		# @ramoatividades = Ramoatividade.find(:all, :order=>"name")
		@negocio=Negocio.find_by_codigo(params[:negocio]) if params[:negocio]
		
		if params[:afiliado_id]
			logger.debug 'procura o partner'
			@userpartner=User.find_by_login params[:afiliado_id].downcase
			logger.debug @userpartner
			@partner=@userpartner.partner if @userpartner
			logger.debug @partner
			logger.debug 'procurou o partner'
			if @partner
				session[:patrocinador]=params[:afiliado_id].downcase
			else
				flash[:notice] = 'Patrocinador não cadastrado. Se não tiver um Patrocinador, use speedflash.  Permitido apenas durante o período de pré-cadastro.' if !@partner
				session[:patrocinador]=nil
			end
		elsif session[:patrocinador]
			logger.debug 'session[:patrocinador]'
			logger.debug session[:patrocinador].downcase
		elsif request.path.include?'novoafiliado'
			if current_user and current_user.partner
				flash[:notice] = 'Você já é um Afiliado.'
			else
				@novoafiliado=true
				@novoafiliado_ja_user=current_user
				@user=current_user if current_user
			end
		end
		if request.path.include?'novoafiliado' and  current_user and current_user.partner
			redirect_to root_path
		else
			respond_to do |format|
				format.html # new.html.erb
				format.xml { render :xml => @user }
			end
		end
    end
  # GET /users/1/edit
    def edit
		logger.debug "entrou no edit"

		logger.debug current_user.login
		logger.debug params[:id]
		#@user=User.find_by(params[:id])
		
		if (( current_user.login == params[:id] ) or current_user.admin)
			logger.debug 'pode alterar'
			@ramoatividades = Ramoatividade.find(:all, :order=>"name")

			@user = User.find_by_login(params[:id])
			#@user=User.find(params[:id])
			@venda=Venda.find(params[:venda]) if params[:venda] 
			if @user.cidade
				@estado = Estado.find(@user.cidade.estado)
				@cidades = @estado.cidades.collect{|c| [c.nome, c.id]}
			end
			@negocio=Negocio.find_by_codigo(params[:negocio]) if params[:negocio]
			#render :layout=>@negocio.layout if @negocio			
		else
			logger.debug 'Impossivel alterar dados de outro usuario.'
			flash[:notice] = 'Impossivel alterar dados de outro usuario.'
			redirect_back_or_default  user_path(current_user.login) #login_path
		end
		render :layout=>false if request and request.xhr?  #chamou via ajax #@user.partner
    end

  # GET /users/1/editpassword
  def editpassword
    if !params[:id]
        params[:id]=current_user.login
    end

	if current_user.login==params[:id] or current_user.admin

		@user = User.find_by_login(params[:id])

		render :layout=>false if request and request.xhr?  #chamou via ajax #@user.partner
	else
		flash[:error] = 'Impossivel alterar senha de outro usuario.'
		redirect_back_or_default user_path(current_user.id) #login_path
	end	
  end  

  # PUT /users/1 
  # PUT /users/1.xml
  def editpasswordconfirma
  	logger.debug "entrou no editpasswordconfirma "
  	@user = User.find(params[:id])
  	if current_user and (current_user==@user or current_user_admin?)
		params[:user].delete(:password) if params[:user][:password].blank?
		params[:user].delete(:password_confirmation) if params[:user][:password_confirmation].blank?	

		logger.debug 'vai gravar'
	  	if @user.update_columns(params[:user])
			logger.debug 'gravou'
	  		
	  		logger.debug  'Dados atualizados com sucesso.'
			flash[:notice] = 'Dados atualizados com sucesso.'
	  		#redirect_to logout_path
	  		redirect_to(login_path, :flash => { :notice => 'Senha alterada com sucesso.'} ) and return
=begin	  		
	  		if @user.partner
	  			redirect_to escritorio_user_path(@user.login)
	  		else
				redirect_to user_path(@user.login, :negocio=>params[:negocio])
			end
=end			
	  	else
			logger.debug  @user.errors.full_messages
			flash[:error] = @user.errors.full_messages
			
			respond_to do |format|
				format.html { render :action => "edit" }
				format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
			end
	  	end
	else
		error
	end
  end    

    # GET /users/1/editfoto
  def editfoto
		logger.debug 'entrou no editfoto'
		logger.debug params[:id]
		if !params[:id]
			params[:id]=current_user.login
		end

		if current_user.login.to_s==params[:id] || current_user.admin
			logger.debug 'procura o user'
			@user = User.find_by_login(params[:id])
		else
			logger.debug 'nao procura o user'
			flash[:notice] = 'Impossivel alterar logomarca de outro usuario.'
			redirect_back_or_default  user_path(current_user.id, :negocio=>params[:negocio]) #login_path
		end	
		render :layout=>false if request and request.xhr?  #chamou via ajax #@user.partner
		#@negocio=Negocio.find_by_codigo(params[:negocio]) if params[:negocio]
		#render :layout=>@negocio.layout if @negocio
  end  
  
  def editfotoconfirma
  	logger.debug "entrou no editfotoconfirma "
  	@user = User.find(params[:id])
  	if current_user and (current_user==@user or current_user_admin?)

		logger.debug 'vai gravar'
	  	if @user.update_columns(params[:user])
			logger.debug 'gravou'
	  		
	  		logger.debug  'Dados atualizados com sucesso.'
	  		if @user.partner
	  			redirect_to escritorio_user_path(@user.login)
	  		else
				redirect_to user_path(@user.login, :negocio=>params[:negocio])
			end
	  	else
			logger.debug  @user.errors.full_messages
			flash[:error] = @user.errors.full_messages
			
			respond_to do |format|
				format.html { render :action => "edit" }
				format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
			end
	  	end
	else
		error
	end
  end   

  # GET /users/1/ativar
  def ativar
        @user = User.find_by_login(params[:id])
        if @user.update_attribute('status', true)
            flash[:notice] = 'Ativado com sucesso.'
            redirect_to users_path
        else
            format.html { render :action => "edit" }
            format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
  end

  # GET /users/1/desativar
  def desativar
    	@user = User.find_by_login(params[:id])
        if @user.update_attribute('status', false)
            flash[:notice] = 'Desativado com sucesso.'
            redirect_to users_path
        else
            format.html { render :action => "edit" }
            format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
  end

  # GET /users/1/desativar
  def desconectarnegocio  
		logger.debug 'desconectar_negocio'
		logger.debug params[:negocio]
		negocio=Negocio.find_by_codigo(params[:negocio])
		logger.debug negocio
		negocio.conexaos.find_by_user_id(current_user.id).delete
		redirect_to user_path current_user.login
  end
  
  # POST /users 
  # POST /users.xml
  def create
  	logger.debug "entrou no create.1"
  	if params[:id] 
  		logger.debug 'tem id'
		@user = User.find(params[:id])
	  	if current_user and (current_user==@user or current_user_admin?)
	  		params[:user]=params

			if params[:user][:nome].blank? and !params[:user][:name].blank?
				params[:user][:nome]=params[:user][:name]
			end

			if params[:user][:telefone1].blank? and !params[:user][:telefone].blank?
				params[:user][:telefone1]=params[:user][:telefone]
			end

			if params[:user_login].blank? and !params[:user][:login].blank?
				params[:user_login]=params[:user][:login]
			end
			
			if params[:user_email_cadastro].blank? and !params[:user][:email].blank?
				params[:user_email_cadastro]=params[:user][:email]
			end	

			if params[:user_password_cadastro].blank? and !params[:user][:password].blank?
				params[:user_password_cadastro]=params[:user][:password]
			end		

		  	@user.codigo=@user.login
			logger.debug 'vai gravar'
		  	if @user.update_attributes(f_profile_parameters)
				logger.debug 'gravou'
				vcontinua=true
				# render :json=>@user.to_json, :status => :created
			    render json: {
			        # data: @resource.as_json(methods: :calculate_operating_thetan, only: [:id, :login, :telefone1, :nome, :datanascimento, :telefone1])
			        # data: @resource.as_json(methods: :calculate_operating_thetan, only: [:id, :login, :telefone1, :name=>@resource.nome, :datanascimento])
			        data:{
			          	:success => true, 
			          	:status => :updated,
			          	:user => { id:@user.id, login:@user.login, telefone:@user.telefone1, datanascimento:@user.datanascimento.to_s_br, :email => @user.email, :name=>@user.nome, :sexo_id=>@resource.sexo_id  } 
			        }
			    }				
		  	else
				render :json =>{ :error => @user.errors.full_messages, status: :unprocessable_entity}
		  	end
		else
			render :json =>{ :error => @user.errors.full_messages, status: :unprocessable_entity}
		end
  	else
  		logger.debug 'nao tem id'
	  	params[:user]=params
		logger.debug params[:negocio]
		

		logger.debug params[:user]

	# {"user"=>{"email"=>"teste1801@teste.com.br", "login"=>"teste1801", "password"=>"123onbit", "name"=>"teste 1801", "datanascimento"=>"12/12/1912", "telefone"=>"84988296900"}

		if params[:user][:nome].blank? and !params[:user][:name].blank?
			params[:user][:nome]=params[:user][:name]
		end

		if params[:user][:telefone1].blank? and !params[:user][:telefone].blank?
			params[:user][:telefone1]=params[:user][:telefone]
		end

		if params[:user_login].blank? and !params[:user][:login].blank?
			params[:user_login]=params[:user][:login]
		end
		
		if params[:user_email_cadastro].blank? and !params[:user][:email].blank?
			params[:user_email_cadastro]=params[:user][:email]
		end	

		if params[:user_password_cadastro].blank? and !params[:user][:password].blank?
			params[:user_password_cadastro]=params[:user][:password]
		end		
	  	# @ramoatividades = Ramoatividade.find(:all, :order=>"name")
	  	@user = User.new(f_profile_parameters)
	  	# @user.tipousuario_id=3 if @user.admin?  
	  	@user.tipousuario_id=0
	  	logger.debug 'impede que o usuario tente cadastrar-se como admin'
	  	# logger.debug '3 = partnerjunior'

	  	#@user.cpf=nil if @user.tipoperfilusuario==:usuario

		if Rails.env.development?
		# 	@user.contasuper='teste@teste.com.br' 
		# 	@user.datanascimento=Time.now.to_date-20.years
			@user.confirmed_at=Time.now
		end
		
	  	@user.login = params[:user_login].downcase.delete '@./?'  #Remove caracteres que podem causar problema  	

	  	@user.codigo=@user.login
	  	@user.status=true

		@user.email=params[:user_email_cadastro]
		@user.password=params[:user_password_cadastro]

		logger.debug 'necessario para ng-auth-token-inicio'
		@user.uid=Time.now.to_f.to_s.parameterize
		@user.provider='email'
		logger.debug 'necessario para ng-auth-token-fim'

		logger.debug "respondendo"
		if @user.save
			logger.debug 'salvou o user'
			logger.debug "salvou"
			# @user.atualizacliente
			if params[:negocio]
				logger.debug 'vai conectar logo o negocio'
				@negocio = Negocio.find_by_codigo(params[:negocio])
				@negocio.conexaos.create({:negocio_id=>@negocio.id, :user_id=>@user.id})		
			end
			@user.update_attributes :confirmed_at=>Time.now
			# render :json=>@user.to_json, :status => :created
		    render json: {
		        # data: @resource.as_json(methods: :calculate_operating_thetan, only: [:id, :login, :telefone1, :nome, :datanascimento, :telefone1])
		        # data: @resource.as_json(methods: :calculate_operating_thetan, only: [:id, :login, :telefone1, :name=>@resource.nome, :datanascimento])
		        data:{
		          	:success => true, 
		          	:status => :created,
		          	:user => { id:@user.id, login:@user.login, telefone:@user.telefone1, datanascimento:@user.datanascimento.to_s_br, :email => @user.email, :name=>@user.nome, :sexo_id=>@user.sexo_id  } 
		        }
		    }				
		else
			# logger.debug @user.errors
			# logger.debug @user.errors.to_hash
			# logger.debug @user.errors.map{|e| e}
			# logger.debug @user.errors.messages
			logger.debug @user.errors.values.join(',').split(',').map{|e| e}
			# logger.debug @user.errors.details
			# logger.debug @user.errors.map{|e| e}
			# render :json =>{ :error => @user.errors.full_messages, status: 401}
			verrorsfull_messages=[]
			@user.errors.full_messages.each do |e|
				verrorsfull_messages<<e if e!="Email address is already in use"
			end

			render json: {
				status: 'error',
				# data:   @user.as_json,
				errors: @user.errors.to_hash.merge(full_messages: verrorsfull_messages)
			}, status: 403			
		end
	end
  end
  # PUT /users/1 
  # PUT /users/1.xml
  def update
  	logger.debug "entrou no update "
  	logger.debug params
  	@user = User.find(params[:id])
  	if current_user and (current_user==@user or current_user_admin?)
  		params[:user]=params
	  	# @ramoatividades = Ramoatividade.all.order("name")
		
	#	@user.login = @user.email
	  	#@user.login = @user.login.downcase.delete '@.'  #Remove caracteres que podem causar problema  	  

		if params[:user][:nome].blank? and !params[:user][:name].blank?
			params[:user][:nome]=params[:user][:name]
		end

		if params[:user][:telefone1].blank? and !params[:user][:telefone].blank?
			params[:user][:telefone1]=params[:user][:telefone]
		end

		if params[:user_login].blank? and !params[:user][:login].blank?
			params[:user_login]=params[:user][:login]
		end
		
		if params[:user_email_cadastro].blank? and !params[:user][:email].blank?
			params[:user_email_cadastro]=params[:user][:email]
		end	

		if params[:user_password_cadastro].blank? and !params[:user][:password].blank?
			params[:user_password_cadastro]=params[:user][:password]
		end		

	  	# @user.login = params[:user_login].downcase.delete '@./?' if params[:user_login]  #Remove caracteres que podem causar problema  	

	  	@user.codigo=@user.login

		# @user.email=params[:user_email_cadastro] if params[:user_email_cadastro] 
		
	  	#@negocio=Negocio.find_by_codigo(params[:negocio]) if params[:negocio]
		
		# params[:user].delete(:password) if params[:user][:password].blank?
		# params[:user].delete(:password_confirmation) if params[:user][:password_confirmation].blank?	
		# params[:user].delete(:login) if params[:user][:login].blank?
	  	  
		# if params[:geoname] and params[:geoname][:id]
		# 	unless Geoname.exists? params[:geoname][:id]
		# 		@geoname=Geoname.new
		# 		@geoname.id=params[:geoname][:id]
		# 		@geoname.pais=params[:geoname][:pais]
		# 		@geoname.estado=params[:geoname][:estado]
		# 		@geoname.cidade=params[:geoname][:cidade]
		# 		@geoname.lat=params[:geoname][:lat]
		# 		@geoname.lng=params[:geoname][:lng]

		# 		@geoname.save
		# 	end
		# 	@user.geoname_id=params[:geoname][:id]
			
		# 	if params[:user]["endereco"].length>0 
		# 		require 'open-uri'

		# 		file=open(URI.escape("http://maps.google.com/maps/api/geocode/json?sensor=false&address=#{params[:user]["endereco"]},#{params[:user]["numero"]},#{params[:user]["bairro"]},#{params[:geoname][:cidade]},#{params[:geoname][:estado]}"))

		# 		teste = JSON.parse(file.read)
				  
		# 		@user.geocodelat=teste['results'][0]['geometry']['location']['lat'] if teste['results'][0]
		# 		@user.geocodelng=teste['results'][0]['geometry']['location']['lng'] if teste['results'][0]
		# 	end			
		# end	  
		logger.debug 'vai gravar'
		# params[:user][:tipousuario_id]=='0' if params[:user][:tipousuario_id]=='1'
	  	if @user.update_attributes(f_profile_parameters)
			logger.debug 'gravou'
			# @user.atualizacliente
			vcontinua=true
# 			if @user.patrocinador
# 				@patrocinador=@user.patrocinador
# 			elsif !params[:patrocinador].blank? #or @user.tipousuario.partner? 
# 				@patrocinador=User.where(:login=>params[:patrocinador].downcase).first.partner
# 			end
# 			vcontinua=@patrocinador
		
# 			logger.debug 'verifica se continua'

# 			# if vcontinua and @user.tipousuario and (@user.tipousuario.partner? or @user.tipousuario.partnerjunior?) and !@user.partner
# 			if vcontinua and @user.tipousuario and !@user.partner
# 				logger.debug 'vcontinua'
# 				if @patrocinador
# 					logger.debug 'cria o cadastro do partner'
# #					if Partner.criapartner :patrocinador=>@patrocinador, :user=>@user
# 					@fvproduto=Fvproduto.find(params[:fvproduto_id])
# 					if Partnerpendente.criapartnerpendente :patrocinador=>@patrocinador, :user=>@user, :fvproduto=>@fvproduto, :quantcargainicial=>params[:quantidadeperfilprofissional]
# 						flash[:notice] = 'Bem vindo ao time dos Afiliados '+Principal.name+'!'
# 					else
# 						flash[:error] = 'Erro ao registrar o Afiliado.'
# 					end
# 				else
# 					flash[:notice] = 'Dados atualizados com sucesso.'
# 				end
# 			else
# 				flash[:notice] = 'Dados atualizados com sucesso.'
# 			end
			
	  		
# 	  		logger.debug  'Dados atualizados com sucesso.'
# 	  		if @user.partner
# 	  			redirect_to escritorio_user_path(@user.login)
# 	  		else
# 				redirect_to user_path(@user.login, :negocio=>params[:negocio])
# 			end
			render :json=>@user.to_json, :status => :created
	  	else
			# logger.debug  @user.errors.full_messages
			# flash[:error] = @user.errors.full_messages
			
			# respond_to do |format|
			# 	format.html { render :action => "edit" }
			# 	format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
			# end
			render :json =>{ :error => @user.errors.full_messages, status: :unprocessable_entity}
	  	end
	else
		# flash[:error] = @user.errors.full_messages
		render :json =>{ :error => @user.errors.full_messages, status: :unprocessable_entity}
	end
  end  

  def load_cidades
	   unless params[:estado_id].blank?
	     @estado = Estado.find(params[:estado_id])
	     @cidades = @estado.cidades.collect { |c| [c.nome, c.id] }
	     render :layout => false
	   end
  end
  
  def validalogin
	logger.debug 'entrou no validalogin'
	logger.debug params
	
	if params[:user] and params[:user][:login]
		vparametro=params[:user][:login]
	elsif params[:user_login]
		vparametro=params[:user_login]
	end

	if vparametro
		if vparametro.length<5
			vloginvalido=false
		else
			vloginvalido=!(User.exists? :login=>vparametro)

			#vloginvalido=true if !vloginvalido and params[:tipoacao]=='edit' and params[:loginoriginal]==params[:user_login]
			vloginvalido=true if !vloginvalido and params[:loginoriginal]==params[:user_login]
		end
	else
		vloginvalido=false
	end
	render :text=>vloginvalido
  end
  
  def validapatrocinador
	logger.debug 'entrou no validapatrocinador'
	logger.debug params
	
	if params[:patrocinador]
		if params[:patrocinador].length<5
			vpatrocinadorvalido=false
		else
			@user=User.find_by_login params[:patrocinador]
			if @user
				# if @user.partner
					vpatrocinadorvalido=true
				# else
				# 		vpatrocinadorvalido=false
				# end
			else
				vpatrocinadorvalido=false
			end
			
		end
	else
		vpatrocinadorvalido=false
	end
	render :text=>vpatrocinadorvalido
  end
  
  def validaemail
	logger.debug 'entrou no validaemail'
	logger.debug params
	if params[:user] and params[:user][:email]
		vparametro=params[:user][:email]
	elsif params[:user_email_cadastro]
		vparametro=params[:user_email_cadastro]
	end
	
	if vparametro
		if vparametro.length<5
			vemailvalido=false
		else
			vemailvalido=!(User.exists? :email=>vparametro)

			vemailvalido=true if !vemailvalido and params[:tipoacao]=='edit' and params[:emailoriginal]==params[:user_email_cadastro]
		end
	else
		vemailvalido=false
	end
	render :text=>vemailvalido
  end  

  def validacpf
	logger.debug 'entrou no validacpf'
	logger.debug params
	if params[:user] and params[:user][:cpf]
		vparametro=params[:user][:cpf]
	elsif params[:user_cpf]
		vparametro=params[:user_cpf]
	end

	if vparametro
		logger.debug 'aaa'
		if (User.exists? :cpf=>vparametro)	
			logger.debug 'bbb'
			vcpfvalido=false

			#vcpfvalido=true if !vcpfvalido and params[:tipoacao]=='edit' and params[:cpforiginal]==params[:user_cpf]
			vcpfvalido=true if !vcpfvalido and params[:cpforiginal]==params[:user_cpf]
		else
			logger.debug 'ccc'
			vcpfvalido=false
			nulos = %w{12345678909 11111111111 22222222222 33333333333 44444444444 55555555555 66666666666 77777777777 88888888888 99999999999 00000000000}
			
			# nulos = %w{010101010101}
			valor = vparametro.scan /[0-9]/
			if valor.length == 11
				logger.debug 'ddd'
				unless nulos.member?(valor.join)
					logger.debug 'eee'
					valor = valor.collect{|x| x.to_i}
					soma = 10*valor[0]+9*valor[1]+8*valor[2]+7*valor[3]+6*valor[4]+5*valor[5]+4*valor[6]+3*valor[7]+2*valor[8]
					soma = soma - (11 * (soma/11))
					resultado1 = (soma == 0 or soma == 1) ? 0 : 11 - soma
					if resultado1 == valor[9]
						logger.debug 'ffff'
						soma = valor[0]*11+valor[1]*10+valor[2]*9+valor[3]*8+valor[4]*7+valor[5]*6+valor[6]*5+valor[7]*4+valor[8]*3+valor[9]*2
						soma = soma - (11 * (soma/11))
						resultado2 = (soma == 0 or soma == 1) ? 0 : 11 - soma
						vcpfvalido=  (resultado2 == valor[10]) # CPF válido
					else
						vcpfvalido=false
					end
				else
					vcpfvalido=false
				end
			else
				logger.debug 'ggg'
				vcpfvalido=false # CPF inválido	
			end
		end
	else
		logger.debug 'hhh'
		vcpfvalido=false
	end
	logger.debug 'vai sair'
	logger.debug vcpfvalido
	render :text=>vcpfvalido
  end  

  def validacnpj
	logger.debug 'entrou no validacnpj'
	logger.debug params
	if params[:user] and params[:user][:cnpj]
		vparametro=params[:user][:cnpj]
	elsif params[:user_cnpj]
		vparametro=params[:user_cnpj]
	end

	if vparametro
		logger.debug 'aaa'
		if (User.exists? :cnpj=>vparametro)	
			logger.debug 'bbb'
			vcnpjvalido=false

			vcnpjvalido=true if !vcnpjvalido and params[:tipoacao]=='edit' and params[:cnpjoriginal]==params[:user_cnpj]
		else
			#return false if vparametro.nil?
			logger.debug 'ccc'
			vcnpjvalido=false

			nulos = %w{11111111111111 22222222222222 33333333333333 44444444444444 55555555555555 66666666666666 77777777777777 88888888888888 99999999999999 00000000000000}
			valor = vparametro.scan /[0-9]/
			if valor.length == 14
				logger.debug 'ddd'
				unless nulos.member?(valor.join)
					logger.debug 'eee'
					valor = valor.collect{|x| x.to_i}
					soma = valor[0]*5+valor[1]*4+valor[2]*3+valor[3]*2+valor[4]*9+valor[5]*8+valor[6]*7+valor[7]*6+valor[8]*5+valor[9]*4+valor[10]*3+valor[11]*2
					soma = soma - (11*(soma/11))
					resultado1 = (soma==0 || soma==1) ? 0 : 11 - soma
					if resultado1 == valor[12]
						logger.debug 'ffff'
						soma = valor[0]*6+valor[1]*5+valor[2]*4+valor[3]*3+valor[4]*2+valor[5]*9+valor[6]*8+valor[7]*7+valor[8]*6+valor[9]*5+valor[10]*4+valor[11]*3+valor[12]*2
						soma = soma - (11*(soma/11))
						resultado2 = (soma == 0 || soma == 1) ? 0 : 11 - soma
						vcnpjvalido = (resultado2 == valor[13]) # CNPJ válido
					else
						vcnpjvalido=false
					end
				else
					vcnpjvalido=false
				end
			else
				logger.debug 'ggg'
				vcnpjvalido=false # CPF inválido	
			end
		end
	else
		logger.debug 'hhh'
		vcnpjvalido=false
	end
	logger.debug 'vai sair'
	logger.debug vcnpjvalido
	render :text=>vcnpjvalido
  end  

  def setapernacadastropendente
  	@partnerpendente=Partnerpendente.find params[:partnerpendente_id]
	#if !@partnerpendente.partner and (@partnerpendente.patrocinador=current_user.partner or current_user_admin?)
	if !@partnerpendente.partner and (current_user_admin?)
		#solucao temporaria para apenas o admin corrigir
		if(@partnerpendente.update_columns :perna=>params[:pernapadrao])
			render :text=>'ok'
		else
		 	render :text=>'Erro!'
		end
	else
		render :text=>'Erro!'
	end
  end

  def setapernapadrao
	if current_user.partner
		if(current_user.partner.update_columns :pernapadrao=>params[:pernapadrao])
			render :text=>'ok'
		else
			render :text=>'Erro!'
		end
	end
  end
  
  def redepartner
	# if current_user_partner?
	@user=User.find_by_login params[:id]
	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		@partner=@user.partner
	# end  
		render :layout => false
	else
		render :nothing=>true
	end
  end

  def redeafiliadospartner
 #  	@partner=Partner.find params[:id]
 #  	@user=@partner.user  # User.find params[:id]
  	
 #  	if current_user and @user.partner# and (current_user==@user or current_user_admin?)
 #  		@partner=@user.partner#Partner.joins(:user).where("users.login='#{params[:id]}'").first
	# 	render :layout => false
	# else
	# 	render :nothing=>true
	# end		
  	logger.debug 'redeafiliadospartner.entrou'
  	logger.debug params
  	logger.debug 'params[:id] eh o id do partner a procurar'
  	logger.debug 'params[:userpartnerid] eh o id do partner que procura'
  	# @user=User.find_by_login params[:id]
  	@userpartner=Partner.find params[:userpartnerid]
  	if params[:userpartnerid]==params[:id]
  		@partner=@userpartner
  	else
	  	@partner=Partner.find params[:id]
	end
	@user=@partner.user
  	logger.debug current_user.login
  	logger.debug @partner.login
  	logger.debug @partner.user.login
  	logger.debug current_user_admin?
  	
  	if current_user and @partner# and (current_user==@user or current_user_admin?)
  	# if (current_user and @partner and (current_user.partners.include?(@userpartner) or  current_user_admin?))# and (@userpartner.procurareferido(@partner.login_literal))
  		# @partner=@user.partner#Partner.joins(:user).where("users.login='#{params[:id]}'").first
		render :layout => false
	else
		render :nothing=>true
	end	
  end
  
  def extrato
	@user=User.find_by_login params[:id]
	# if current_user and @user.partner and (current_user==@user or current_user_admin?)
	if current_user and (current_user==@user or current_user_admin?)
		render :layout => false
	else
		render :nothing=>true
	end			
  end    
  
  def extratopa
	@user=User.find_by_login params[:id]
	if current_user and (current_user==@user or current_user_admin?)
		if params[:periodoselecionado]=='hoje'
			vcondicao="data='#{Time.now.to_date}'"
		elsif !params[:periodoselecionado] or params[:periodoselecionado]=='ultimos3dias'
			vcondicao="data>'#{Time.now.to_date-3.days}'"
		elsif params[:periodoselecionado]=='ultimos7dias'
			vcondicao="data>'#{Time.now.to_date-7.days}'"			
		elsif params[:periodoselecionado]=='ultimos15dias'
			vcondicao="data>'#{Time.now.to_date-15.days}'"
		elsif params[:periodoselecionado]=='ultimos30dias'
			vcondicao="data>'#{Time.now.to_date-30.days}'"
		elsif params[:periodoselecionado]=='ultimos60dias'
			vcondicao="data>'#{Time.now.to_date-60.days}'"
		else
			vcondicao='1'
		end

		if !params[:periodoselecionado] or params[:periodoselecionado]=='ultimos10'
			vlimit=10
		end

		@extratopartneratividades=@user.extratopartneratividades.where(vcondicao).includes(:tipolancamentoextratopartner, :partnerrelacionado=>[:user]).order("id desc").limit(vlimit)	#tandards
		render :layout => false
	else
		render :nothing=>true
	end			
  end   

	def estornarpa
		@user=User.find_by_login params[:id]
		@partner=@user.partner
		@extratopartneratividade=Extratopartneratividade.find params[:extratopartneratividade_id]
		if current_user_admin? and @extratopartneratividade and @partner
			@tipolancamentoextrato=Tipolancamentoextratopartner.find 20  #Estorno de atividade
			vvalor=@extratopartneratividade.valor
			Extratopartneratividade.registralancamento :partner=>@partner, :partnerrelacionado_id=>@partner.id, :tipolancamentoextrato=>@tipolancamentoextrato, :valor=>vvalor, :relacionado=>@extratopartneratividade, :descricao=>"Extorno de atividade"
			render :text => 'ok'
		else
			render :text => 'Erro!'
		end				
	end	

  def extratopb
	@user=User.find_by_login params[:id]
	if current_user and (current_user==@user or current_user_admin?)
		
		if params[:periodoselecionado]=='hoje'
			vcondicao="data='#{Time.now.to_date}'"
		elsif !params[:periodoselecionado] or params[:periodoselecionado]=='ultimos3dias'
			vcondicao="data>'#{Time.now.to_date-3.days}'"
		elsif params[:periodoselecionado]=='ultimos7dias'
			vcondicao="data>'#{Time.now.to_date-7.days}'"			
		elsif params[:periodoselecionado]=='ultimos15dias'
			vcondicao="data>'#{Time.now.to_date-15.days}'"
		elsif params[:periodoselecionado]=='ultimos30dias'
			vcondicao="data>'#{Time.now.to_date-30.days}'"
		elsif params[:periodoselecionado]=='ultimos60dias'
			vcondicao="data>'#{Time.now.to_date-60.days}'"
		else
			vcondicao='1'
		end

		if !params[:periodoselecionado] or params[:periodoselecionado]=='ultimos10'
			vlimit=10
		end

		@extratopartners=@user.extratopartners.where(vcondicao).includes(:tipolancamentoextratopartner, :partnerrelacionado=>[:user]).order("id desc").limit(vlimit)
		render :layout => false
	else
		render :nothing=>true
	end			
  end    

  def extratopc
  	logger.debug 'extratopc.entrou'
	@user=User.find_by_login params[:id]
	if current_user and (current_user==@user or current_user_admin?)
		logger.debug 'pode continuar'
		if params[:periodoselecionado]=='hoje'
			vcondicao="data='#{Time.now.to_date}'"
		elsif !params[:periodoselecionado] or params[:periodoselecionado]=='ultimos3dias'
			vcondicao="data>'#{Time.now.to_date-3.days}'"
		elsif params[:periodoselecionado]=='ultimos7dias'
			vcondicao="data>'#{Time.now.to_date-7.days}'"			
		elsif params[:periodoselecionado]=='ultimos15dias'
			vcondicao="data>'#{Time.now.to_date-15.days}'"
		elsif params[:periodoselecionado]=='ultimos30dias'
			vcondicao="data>'#{Time.now.to_date-30.days}'"
		elsif params[:periodoselecionado]=='ultimos60dias'
			vcondicao="data>'#{Time.now.to_date-60.days}'"
		else
			vcondicao='1'
		end

		if !params[:periodoselecionado] or params[:periodoselecionado]=='ultimos10'
			vlimit=10
		end

		@extratopartnercreditos=@user.extratopartnercreditos.where(vcondicao).order("id desc").includes(:tipolancamentoextratopartner, :user).order("id desc").limit(vlimit)
		render :layout => false
	else
		render :nothing=>true
	end			
  end     

  def extratopremiumpartner
	@user=User.find_by_login params[:id]
	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		@extratopartners=@user.partner.extratopartners
		render :layout => false
	else
		render :nothing=>true
	end			
  end  

  def cadastrospendentespartner
	@user=User.find_by_login params[:id]
	# if current_user and @user.partner and (current_user==@user or current_user_admin?)
	if current_user and (current_user==@user or current_user_admin?)
		#@partner=@user.partner
		@cadastrospendentes=@user.cadastrospendentes #.includes(:venda, :user=>[:partner])

		render :layout => false
	else
		render :nothing=>true
	end			
  end

  def cadastropartnerpendente
  	logger.debug 'entrou no cadastropartnerpendente'
	@user=User.find_by_login params[:id]
	@userpartner=User.find_by_login params[:partner]

	if current_user and @userpartner.partnerpendente and (current_user==@userpartner.patrocinador.user or current_user_admin?)
		logger.debug 'pode continuar'

		@partnerpendente=@userpartner.partnerpendente
		render :layout => false
	else
		render :nothing=>true
	end			
  end
  
  def afiliadospartner
	@user=User.find_by_login params[:id]
	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		@partner=@user.partner
		render :layout => false
	else
		render :nothing=>true
	end			
  end

  def afiliadospartnerrede
	@user=User.find_by_login params[:id]
	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		@partner=@user.partner
		render :layout => false
	else
		render :nothing=>true
	end			
  end  

  def redeafiliadosafiliado
	@user=User.find_by_login params[:id]
	if current_user and (@user.partner  or current_user_admin?)
		@partner=@user.partner
		render :layout => false
	else
		render :nothing=>true
	end			
  end  

  def inicio
	@user=User.find_by_login params[:id]
	if true #current_user and @user.partner and (current_user==@user or current_user_admin?)
		@partner=@user.partner
		#@existeticketaberto=@user.tickets.where("status<>1 or status is null").count>0
		#@existeticketaberto=@user.tickets.joins(:ticketnotes).where("tickets.status is null and ticketnotes.user_id=1").count>0
=begin
		if !@user.conexaos.blank?
			vcondicao=[]
			vcondicao<<'registroatividades.id<'+params[:atividade_id].to_i.to_s if !params[:atividade_id].blank?
			vcondicao<<"negocio_id in ( #{@user.conexaos.map {|x|x.negocio.id}.join(',')}) "
			vcondicao<<"registravel_type is not null"
			# vcondicao<<"registravel_type='Negocio' "
			vcondicao<<"registravel_type<>'Comentario' "
			
			# @registroatividades = Registroatividade.find_by_sql("SELECT `registroatividades`.* FROM `registroatividades` force index (index_atividades_recentes) WHERE ( ( user_id in (#{users.join(', ')}) or muraluser_id in (#{users.join(', ')}) ) and (acao_type='Noticia' or acao_type='Fotouserpicture') and acao_type<>'Comentario' ) ORDER BY created_at desc LIMIT 3")
			# @registroatividades = Registroatividade.find_by_sql("SELECT `registroatividades`.* FROM `registroatividades` WHERE ( ( negocio_id in (#{users.join(', ')}) or muraluser_id in (#{users.join(', ')}) ) and (acao_type='Noticia' or acao_type='Fotouserpicture') and acao_type<>'Comentario' ) ORDER BY created_at desc LIMIT 3")
			
			@atividades = Registroatividade.where(vcondicao.join(' and ')).order('created_at desc').limit(3)
			@ultimaatividade_id= @atividades.last.id if @atividades.last
		end		
		
		@mensagemsrecebidasnaolidas=Mensagem.find(:all, :conditions=>{'userpara_id'=> current_user.id, :status=>nil}, :order=>'created_at desc')	
=end
		render :layout => false
	else
		render :nothing=>true
	end			
  end

  def geraboletopartnerpendente
  	@user=User.find_by_login params[:id]

  	if @user and !@user.partnerpendente.venda
		@venda=Venda.new
		@venda.data=Time.now.to_date
		@venda.user=@user
		@venda.partner=@patrocinador
		@venda.fvproduto_id=Fvproduto.perfilprofissional_id
		@venda.quant=@user.partnerpendente.quantcargainicial
		@venda.total=@user.partnerpendente.quantcargainicial*Fvproduto.where(:id=>Fvproduto.perfilprofissional_id).pluck(:preco)[0]
		@venda.save

		@pagcliente=Pagcliente.new
		@pagcliente.venda=@venda
		@pagcliente.dataapagar=@venda.data
		@pagcliente.valorapagar=@venda.total
		@pagcliente.save

		@pagcliente.update_columns :digest_md5_hexdigest=>@pagcliente.id.to_s+SecureRandom.hex(2)

		@user.partnerpendente.update_columns :venda_id=>@venda.id  		
	end
	redirect_to boleto_path(@user.partnerpendente.venda.pagclientes.first.digest_md5_hexdigest )
  end

  def mensagem
	@user=User.find_by_login params[:id]
	if current_user and (current_user==@user or current_user_admin?)
=begin	
	@enviado=params[:enviado]
	if @enviado
		@mensagems=Mensagem.find(:all, :conditions=>{'user_id'=>@user.id}, :order=>'created_at desc')
	else
		@mensagems=Mensagem.find(:all, :conditions=>{'userpara_id'=> @user.id}, :order=>'created_at desc')		
	end
=end		
		#@mensagems=Mensagem.where("userpara_id= #{@user.id} or user_id=#{@user.id}").order('created_at desc')
		
		render :layout => false
	else
		render :nothing=>true
	end			

  end

  def download
	render :layout => false
  end  

  def pagamentos
	@user=User.find_by_login params[:id]
	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		#@saldoextratopartner=(@user.partner.extratopartners.count>0 ? @user.partner.extratopartners.last.saldo.real : 0.real)

		#@saldoextratopartner=200
		if params[:idpagamento]
			@pagcliente=Pagcliente.find_by_digest_md5_hexdigest params[:idpagamento].strip
			if @pagcliente
				@venda=@pagcliente.venda
				if @pagcliente.venda.partner==@user.partner
					@comissao=@pagcliente.venda.comissao.to_f	#@pagcliente.venda.quant*@pagcliente.venda.fvproduto.pb
				else
					@comissao=0
				end
			else
				@mensagem="Nao localizado" 
			end
		end
		render :layout => false
	else
		render :nothing=>true
	end	
  end      

  def transferencia
	@user=User.find_by_login params[:id]
	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		if params[:loginparceirocredito]
			@usercredito=User.where(:login=>params[:loginparceirocredito], :cpf=>params[:cpfparceirocredito]).first
			if @usercredito
				@partnercredito=@usercredito.partner
			else
				@mensagem="Destinatário não localizado" 
			end
		end
		render :layout => false
	else
		render :nothing=>true
	end	
  end

  def usertransferenciaconfirma
  	logger.debug 'entrou no usertransferenciaconfirma'
	@user=User.find params[:user_id]
	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		logger.debug 'pode'
		vvalortransferir=params[:valortransferir].to_i
		if vvalortransferir>0
			@usercredito=User.find_by_login params[:loginparceirocredito]
			if @usercredito
				@tipolancamentoextrato=Tipolancamentoextratopartner.find 31  #Transferência - débito
				logger.debug 'debita 1% de taxa de transferencia'
				vretornodebitopontos=Pagcliente.debitapontos :user=>@user, :valorapagar=>(vvalortransferir*1.01), :relacionado=>@usercredito.partner, :tipolancamentoextrato=>@tipolancamentoextrato
				if vretornodebitopontos=='ok'
					@tipolancamentoextrato=Tipolancamentoextratopartner.find 32  #Transferência - crédito
					vvalor=vvalortransferir
					
					Extratopartnercredito.registralancamento :partner=>@usercredito.partner, :partnerrelacionado_id=>@user.partner.id, :tipolancamentoextrato=>@tipolancamentoextrato, :valor=>vvalor, :relacionado=>@user, :descricao=>"Transferência"
					render :text=>'{"status":"ok"}'
				else
					render :text=>'{"status":"'+vretornodebitopontos+'"}'
				end
			else
				render :text=>'{"status":"Não localizado"}'
			end
		else
			render :text=>'{"status":"Valor inválido"}'
		end
	else
		render :text=>'{"status":"Impossível registrar o pgamento com os bonus de outro parceiro!"}'
	end	
  end  

  def vendas
	@user=User.find_by_login params[:id]
	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		#@vendas=@user.partner.vendas.includes(:negocio, :fvproduto, :cliente, :partner=>[:user]).order('created_at desc')
		@vendas=@user.partner.vendas.includes(:negocio, :fvproduto, :cliente, :partner=>[:user]).order('created_at desc')
		@fvprodutos=Fvproduto.where('pb is not null').order('name')
		render :layout => false
	else
		render :nothing=>true
	end	
  end    

  def venda
  	logger.debug 'entrou no venda'
	@user=User.find_by_login params[:id]

	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		logger.debug 'pode continuar'

		@venda=Venda.find params[:venda]
		render :layout => false
	else
		render :nothing=>true
	end			
  end  

  def compras
	@user=User.find_by_login params[:id]
	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		#@vendas=@user.partner.vendas.includes(:negocio, :fvproduto, :cliente, :partner=>[:user]).order('created_at desc')
		@compras=@user.compras.includes(:negocio, :fvproduto, :cliente, :partner=>[:user]).order('created_at desc')
		#@fvprodutos=Fvproduto.where('pb is not null').order('name')
		render :layout => false
	else
		render :nothing=>true
	end	
  end    

  def compra
  	logger.debug 'entrou no compra'
	@user=User.find_by_login params[:id]

	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		logger.debug 'pode continuar'

		@compra=Venda.find params[:compra]
		render :layout => false
	else
		render :nothing=>true
	end			
  end  

  def ofertacoletivas
	@user=User.find_by_login params[:id]
	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		@ofertacoletivas=Ofertacoletiva.joins(:negocio).where("negocios.user_id=#{@user.id}")
		render :layout => false
	else
		render :nothing=>true
	end	
  end    

  def ofertacoletiva
  	logger.debug 'entrou no ofertacoletiva'
	@user=User.find_by_login params[:id]

	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		logger.debug 'pode continuar'

		@ofertacoletiva=Ofertacoletiva.find_by_codigo params[:ofertacoletiva]
		@itensvendidos=@ofertacoletiva.itensvendidos.joins(:venda=>:cupom).includes(:venda=>[:cliente, :cupom])
		render :layout => false
	else
		render :nothing=>true
	end			
  end  

  def estoque
  	logger.debug 'entrou no estoque'
	@user=User.find_by_login params[:id]

	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		logger.debug 'pode continuar'
		logger.debug @user.partner.partnerestoques
		@partner=@user.partner

		@perfilultimos12meses=@user.vendas.joins(:pagclientes).where("fvproduto_id=#{Fvproduto.perfilprofissional_id} and vendas.created_at>'#{Time.now.to_date-12.month}'").order('vendas.created_at desc').includes(:pagclientes)

	 	@pagamentopendente=@user.vendas.joins(:pagclientes).where("fvproduto_id=#{Fvproduto.perfilprofissional_id} and vendas.created_at>'#{Time.now.to_date-12.month}' and pagclientes.valorpago is null").count>0
	 	@quantperfiladquiridoultimos12meses=@user.vendas.joins(:pagclientes).where("fvproduto_id=#{Fvproduto.perfilprofissional_id} and vendas.created_at>'#{Time.now.to_date-12.month}' and pagclientes.valorpago is null").sum(:quant)

		@partnerestoques=@user.partner.partnerestoques

		@partnerhabilitados=@user.partner.vendas.where :estoquedopartner=>true
		render :layout => false
	else
		render :nothing=>true
	end			
  end    

  def tickets
  	logger.debug 'entrou no tickets'
	@user=User.find_by_login params[:id]

	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		logger.debug 'pode continuar'
		
		@tickets=@user.tickets
		render :layout => false
	else
		render :nothing=>true
	end			
  end   

  def ticket
  	logger.debug 'entrou no ticket'
  	redirect_to ticket_path(params[:ticket_id], :escritorio=>true)
  end  

  def recargas
	@user=User.find_by_login params[:id]
	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		@partner=@user.partner
		@perfilultimos12meses=@user.vendas.joins(:pagclientes).where("fvproduto_id=#{Fvproduto.perfilprofissional_id} and vendas.created_at>'#{Time.now.to_date-12.month}'").order('vendas.created_at desc').includes(:pagclientes)

	 	@pagamentopendente=@user.vendas.joins(:pagclientes).where("fvproduto_id=#{Fvproduto.perfilprofissional_id} and vendas.created_at>'#{Time.now.to_date-12.month}' and pagclientes.valorpago is null").count>0
	 	@quantperfiladquiridoultimos12meses=@user.vendas.joins(:pagclientes).where("fvproduto_id=#{Fvproduto.perfilprofissional_id} and vendas.created_at>'#{Time.now.to_date-12.month}' and pagclientes.valorpago is null").sum(:quant)

		render :layout => false
	else
		render :nothing=>true
	end			
  end  

  def recarga
	@user=User.find_by_login params[:id]
	if current_user and @user.partner and (current_user==@user or current_user_admin?) and params[:quantidadeperfilprofissional].to_i>0
		@partner=@user.partner

		@venda=Venda.new
		@venda.data=Time.now.to_date

		logger.debug 'Nesta venda nao ha partner.  Quem vendeu eh o user, nao o patrocinador.  Sei quem eh o patrocinador fazendo venda.user.partnerpendente.patrocinador'
		logger.debug 'ou venda.partnerpendente.patrocinador'

		@venda.user=@user 	
		#@venda.partner=@patrocinador
		@venda.fvproduto_id=Fvproduto.perfilprofissional_id	#1		#Perfil Profissional
		@venda.quant=params[:quantidadeperfilprofissional]
		@venda.total=@venda.quant*Fvproduto.where(:id=>1).pluck(:preco)[0]
		@venda.save

		@pagcliente=Pagcliente.new
		@pagcliente.venda=@venda
		@pagcliente.dataapagar=@venda.data
		@pagcliente.valorapagar=@venda.total
		@pagcliente.save

		@pagcliente.update_columns :digest_md5_hexdigest=>@pagcliente.id.to_s+SecureRandom.hex(2)


		@user.partnerpendente.update_columns :venda_id=>@venda.id, :quantcargainicial=>@venda.quant if @user.partnerpendente and !@user.partnerpendente.venda

		render :text => 'ok'
	else
		render :text => 'Erro!'
	end			
  end  

  def contabancaria
	@user=User.find_by_login params[:id]
	# if current_user and @user.partner and (current_user==@user or current_user_admin?)
	if current_user and (current_user==@user or current_user_admin?)
		# @partner=@user.partner
		@bancos=Banco.all

		render :layout => false
	else
		render :nothing=>true
	end			
  end 

  def contabancariaconfirma
	@user=User.find_by_login params[:id]
	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		@partner=@user.partner
		@partner.banco_id=params[:banco_id]
		@partner.agencia=params[:agencia]
		@partner.agenciadigito=params[:agenciadigito]
		@partner.conta=params[:conta]
		@partner.contadigito=params[:contadigito]
		@partner.save

	 	redirect_to contabancaria_user_path @user.login
		#render :layout => false
	else
		render :nothing=>true
	end			
  end 

  def saque
	@user=User.find_by_login params[:id]
	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		@partner=@user.partner
		@saldopb=@user.partner.saldopb.real
		@saque=@partner.saques.last

		render :layout => false
	else
		render :nothing=>true
	end			
  end 

  def saqueconfirma
	@user=User.find_by_login params[:id]
	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		@partner=@user.partner
		if params[:valorliquido].to_f>=100 and params[:valorliquido].to_f<=@user.partner.saldopb
			@saque=Saque.new
			@saque.partner=@partner
			@saque.valorbruto=params[:valorbruto]
			@saque.valorliquido=params[:valorliquido]
			@saque.save
		end
	 	redirect_to saque_user_path @user.login
		#render :layout => false
	else
		render :nothing=>true
	end			
  end 

  def saqueregistra
		@user=User.find_by_login params[:id]
		@partner=@user.partner
		#@extratopartner=Extratopartner.find params[:extratopartneratividade_id]
		if current_user_admin? and @partner and @partner.saques and !@partner.saques.last.confirmado
			@tipolancamentoextrato=Tipolancamentoextratopartner.find 23  #Saque
			vvalor=@partner.saques.last.valorbruto
			Extratopartner.registralancamento :partner=>@partner, :partnerrelacionado_id=>@partner.id, :tipolancamentoextrato=>@tipolancamentoextrato, :valor=>vvalor, :relacionado=>@partner.saques.last, :descricao=>"Saque"
			@partner.saques.last.update_columns :confirmado=>true
			render :text => 'ok'
		else
			render :text => 'Erro!'
		end		
  end 

  def negocios
  	logger.debug 'entrou em negocios'
	@user=User.find_by_login params[:id]
	if current_user and (current_user==@user or current_user_admin?)
		@negocios=@user.negocios
		render :layout => false
	else
		render :nothing=>true
	end	 	
  end

  def divulgacao
  	logger.debug 'entrou em divulgacao'
	@user=User.find_by_login params[:id]
	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		render :layout => false
	else
		render :nothing=>true
	end	 	
  end

  def atividades
  	logger.debug 'entrou em atividades'
	@user=User.find_by_login params[:id]
	if current_user and @user.partner and (current_user==@user or current_user_admin?)
		@partner=@user.partner
		logger.debug 'consulta as atividades de hoje'
		logger.debug 'Converte PA em PB'

		logger.debug 'cria as atividades de hoje'
		@atividades=Atividade.includes(:relacionado).where(:data=>Time.now.to_date)
		if @atividades.blank?
			logger.debug 'nao encontrou atividades de hoje'
			Partner.convertepa(Time.now.to_date-30.days)
			
			
			@links=Link.joins(:venda=>[:pagclientes]).where("pagclientes.valorpago is not null")
			if @links.blank?
				logger.debug 'nao encontrou links disponiveis.  Usa os recorrentes'
				logger.debug 'Os links recorrentes nao precisam de venda'


				@links=Link.where :recorrente=>true
				logger.debug 'seleciona os links recorrentes'
=begin				
				@linksrecorrentes=Link.where :recorrente=>true
				vmaxlinksrecorrentes=@linksrecorrentes.count
				logger.debug vmaxlinksrecorrentes

				if vmaxlinksrecorrentes>0
					logger.debug 'tem links recorrentes'
					vcondicao=[]
					while (vcondicao.count<1 and vcondicao.count<vmaxlinksrecorrentes)
						logger.debug vcondicao.count
						
						vrand=rand(vmaxlinksrecorrentes)
						vcondicao<<@linksrecorrentes[vrand].id if !vcondicao.include?@linksrecorrentes[vrand].id
						
						logger.debug vcondicao
					end
					logger.debug 'vcondicao'
					logger.debug vcondicao
					
					@links = Link.where("id in (#{vcondicao.join(', ')})")
					logger.debug @links.count
				end
=end				
				logger.debug 'verificou os links recorrentes'
			end
			@links.each do |link|
				@atividade=Atividade.new
				@atividade.data=Time.now.to_date
				@atividade.relacionado=link
				@atividade.save
			end

			if Date.today.end_of_week==Date.today
				vlink=Link.find 19 #Clique neste link para registrar o cadastro do negócio

				@atividade=Atividade.new
				@atividade.data=Time.now.to_date
				@atividade.relacionado=vlink
				@atividade.save
			end

			@atividades=Atividade.includes(:relacionado).where :data=>Time.now.to_date

			logger.debug 'aproveita para diminuir o preco dos itens do leilaoreverso'
			vleilaoreverso_sem_click_desde_ontem=Click.select("distinct relacionado_id").where("created_at>'#{(DateTime.now-1.day).beginning_of_day.utc.strftime('%Y-%m-%d %H:%M:%S')}'").map{|c| c.relacionado_id}.join(",")
			ActiveRecord::Base.connection.execute("update leilaoreversos set precovenda=precovenda-valorreverso where leilaoreversos.precovenda>1 and leilaoreversos.id not in (#{vleilaoreverso_sem_click_desde_ontem}) and datainicio<'#{(DateTime.now).beginning_of_day.utc.strftime('%Y-%m-%d %H:%M:%S')}'")
			ActiveRecord::Base.connection.execute("update leilaoreversos set precovenda=1 where leilaoreversos.precovenda<1")
		end

		@quantatividadesconcluidashoje=Atividade.select("distinct atividades.id").joins("inner join clicks on clicks.relacionado_id=atividades.id and clicks.relacionado_type='Atividade'").where("user_id=#{current_user.id} and atividades.data='#{Time.now.to_date}'").count
		logger.debug 'restantes'
		logger.debug @atividades.count
		logger.debug @quantatividadesconcluidashoje


		@quantatividadesrestantes=@atividades.count-@quantatividadesconcluidashoje
		logger.debug @quantatividadesrestantes

		@extratopartneratividades=@user.partner.extratopartneratividades.where("data='#{Time.now.to_date}'").includes(:tipolancamentoextratopartner, :partner=>[:user])
		render :layout => false
	else
		render :nothing=>true
	end		

  end

  def users_select
    @users = User.find_by_sql(
      "SELECT 
      users.id, 
      users.nome,
      users.login
      FROM 
      users
      WHERE 1 and (users.nome like '%#{params[:q].upcase}%' ) order by nome asc") 
    ActiveRecord::Base.include_root_in_json = false
    render :text=>params[:callback]+'({"quantResults":1, "resultado":'+ @users.to_json+'});'
    ActiveRecord::Base.include_root_in_json = true
  end 	
private
  def f_profile_parameters
    logger.debug 'f_profile_parameters'
    logger.debug params
    # params.require(:user).permit(:tipousuario_id, :nome, :datanascimento, :sexo_id, :cep, :cep_id, :endereco, :numero, :complemento, :bairro, :municipio, :uf, :pontoreferencia, :telefone1, :telefone2, :password_confirmation, :picture)
    params.require(:user).permit(:nome, :datanascimento, :sexo_id, :cep, :cep_id, :endereco, :numero, :complemento, :bairro, :municipio, :uf, :pontoreferencia, :telefone1, :telefone2, :password_confirmation, :picture)
  end

end



# encoding: utf-8

class User < ActiveRecord::Base
  # Include default devise modules.
  # devise :database_authenticatable, :registerable,
  #         :recoverable, :rememberable, :trackable, :validatable,
  #         :confirmable, :omniauthable
  	
	require 'normalizepicturefilename'
	include Normalizepicturefilename
=begin
  #devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :token_authenticatable, :validatable, :lockable, :timeoutable
  
  devise :database_authenticatable, :registerable, :recoverable, :trackable
	#:confirmable,

  # Setup accessible (or protected) attributes for your model
  #rails4attr_accessible :name, :datanascimento, :sexo_id, :email, :password, :password_confirmation, :remember_me, :confirmed_at, :reset_password_sent_at
=end
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
	devise :database_authenticatable, :registerable, :recoverable, :trackable, :confirmable, :rememberable, :validatable	#Deprecated, :token_authenticatable
	devise :omniauthable, :omniauth_providers => [:facebook]

	include DeviseTokenAuth::Concerns::User
  # Setup accessible (or protected) attributes for your model
  #rails4#rails4attr_accessible :email, :password, :password_confirmation, :remember_me, :tipousuario_id, :login, :nome, :cpf, :sexo_id, :endereco, :complemento, :bairro, :telefone1, :telefone2, :cep, :captcha, :captcha_key, :datanascimento, :home, :lastnegocio_id, :patrocinador_id, :picture, :tipoperfil_id, :tipopatrocinador_id, :cep_id, :numero, :pontoreferencia, :municipio, :uf
  
##	has_many :galerias
#	has_many :noticias
#	has_many :classificados

	belongs_to :sexo
	# belongs_to :geoname
	# belongs_to :ramoatividade
	# belongs_to :cidade
	belongs_to :tipousuario
	# belongs_to :lastnegocio, :class_name => "Negocio", :foreign_key => "lastnegocio_id"   
	# belongs_to :patrocinador, :class_name => "Partner", :foreign_key => "patrocinador_id"
	# belongs_to :patrocinador, :class_name => "User", :foreign_key => "patrocinador_id"
	# belongs_to :tipoperfil
	
	# has_many :cadastrospendentes, :class_name => "User", :foreign_key => "patrocinador_id"

# 	has_many :negocios
# 	has_many :recados
# 	has_many :imagems
# 	has_many :videos
# 	has_many :registroatividades
# 	has_many :animals
# 	has_many :classificados
# 	has_many :clicks

# 	has_many :fotousers
# 	has_many :fotouserpictures	

# #	has_and_belongs_to_many :negocios
# 	has_many :conexaos
# 	has_many :negociosconectados, :through => :conexaos, :source=>:negocio

# 	has_many :vendas
# 	has_many :compras, :class_name => "Venda", :foreign_key => "cliente_id"

# 	has_many :tickets

# 	has_many :carts

# 	has_one :partner

# 	has_many :extratopartners, :dependent => :destroy
# 	has_many :extratopartneratividades, :dependent => :destroy
# 	has_many :extratopartnercreditos, :dependent => :destroy
		
# 	has_one :partnerpendente
# 	has_one :cliente
#has_attached_file :img, :styles => {:large => "600x600>",  :medium => "400x400>", :small => "200x200>", :thumb => "100x100>", :icon => "50x50>" }
	has_attached_file :picture, 	:styles => {:icon=>"50x50>", :thumb => "100x100>", :small => "200x200>" }, :default_url => "/assets/no_pictures/:style/photo.jpg"
	# has_attached_file :picturehome1,:styles => {:thumb => "100x100>", :medium => "400x400>"}, :default_url => "/assets/no_pictures/:style/missing.jpg"
	# has_attached_file :picturehome2,:styles => {:thumb => "100x100>", :medium => "400x400>"}, :default_url => "/assets/no_pictures/:style/missing.jpg"
	validates_attachment_content_type :picture, :content_type => ["image/jpg", "image/jpeg", "image/png"]

	validates_presence_of :login, :message=> "faltou o login"
	validates_presence_of :email, :message=> "faltou o email"
	
	validates_uniqueness_of :email, :message => "Já cadastrado!", :on=>:create
	validates_uniqueness_of :login, :message => "Já cadastrado!", :on=>:create
	
	validates_length_of :login, :minimum => 4, :message => "o login tem que ter mais de 5 caracteres" #, :on => :create

	validates_presence_of :password, :message => "faltou a senha", :on=>:create
	validates_length_of :password, :minimum => 5, :message => "a senha tem que ter mais de 5 caracteres", :on=>:create #, :on => :update

	validates_presence_of :nome, :message=> "faltou o nome"
	validates_length_of :nome, :minimum => 5, :message => "o nome tem que ter mais de 5 caracteres" #, :on => :create
	# validates_presence_of :geoname_id, :message => "Informe a cidade"	

	# scope :by_nomecodificado, lambda {|nome| {:conditions => ["nome = TRIM(?)", nome] }}

	#rails4	scope :sites_destaque, :limit=>6, :include=>:ramoatividade, :order=>'rand()', :conditions=>{:destaque=>true}
	# scope :sites_destaque, -> { where(:destaque=>true).order('rand()').include(:ramoatividade).limit(6) }

	# def to_param
		# #"#{self.id}-#{self.titulo}".parameterize
		# "$#{self.codigo}".parameterize
	# end	
	
	def self.new_with_session(params, session)
  		logger.debug 'new_with_session.entrou'
	    super.tap do |user|
	      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
	        user.email = data["email"] if user.email.blank?
	      end
	    end
  	end	
	def self.from_omniauth(auth)
	  logger.debug 'from_omniauth.entrou' 
	  where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
	    user.email = auth.info.email
	    user.password = Devise.friendly_token[0,20]
	    user.nome = auth.info.name   # assuming the user model has a name
	    # user.picture = auth.info.image # assuming the user model has an image
		if auth.info.image.present?
		   avatar_url = process_uri(auth.info.image)
		   user.picture= URI.parse(avatar_url)
		end	 
		user.save   
	  end
	end

	def facebook
		logger.debug 'facebook.entrou'
		begin
			if self.facebook_expires_at.blank? or self.facebook_expires_at < Time.now-24.hours
				logger.debug 'expirado'
				oauth = Koala::Facebook::OAuth.new(Principal.facebook_appId, Principal.facebook_appSecret)
				logger.debug 'tenta renovar'
				new_access_info = oauth.exchange_access_token_info self.facebook_token

				logger.debug 'tenta renovar.1'
				new_access_token = new_access_info["access_token"]
				logger.debug 'renovado'
				new_access_expires_at = DateTime.now + new_access_info["expires"].to_i.seconds
				logger.debug 'atualiza no banco'
				self.update_columns(:facebook_token => new_access_token,:facebook_expires_at => new_access_expires_at )
			end
		
			@facebook ||= Koala::Facebook::API.new(self.facebook_token)
			block_given? ? yield(@facebook) : @facebook
		rescue Koala::Facebook::APIError => e
			logger.debug e.to_s
			#nil
			e.to_s
		end
	end

# 	def cidade_name_literal
# 		if geoname
# 			geoname.nameliteral
# 		elsif cidade
# 			cidade.nome+'/'+cidade.estado.sigla 
# 		end
# 	end

# 	def enderecoliteral
# 		# endereco=self.endereco+', '+self.numero+', '+self.complemento+', '+self.bairro+', '+self.cep if self.endereco && self.numero && self.complemento && self.bairro && self.cep
# 		# endereco=endereco+', '+self.geoname.cidade+', '+self.geoname.estado   if self.geoname && endereco
# 		# return endereco
		
# 		endereco=[]
# 		endereco << self.endereco if !self.endereco.blank?
# 		endereco << self.numero if !self.numero.blank?
# 		endereco << self.complemento if !self.complemento.blank?
# 		endereco << self.bairro if !self.bairro.blank?
# 		endereco << self.cep if !self.cep.blank?
# 		endereco << self.cidade_name_literal
# 		#endereco << self.geoname.estado if self.geoname
# 		endereco << self.pontoreferencia
# 		return endereco.join(', ')		
# 	end  	

# 	def telefoneliteral
# 		telefone=[]
# 		telefone<<self.telefone1 if !self.telefone1.blank?
# 		telefone<<self.telefone2 if !self.telefone2.blank?
# 		return telefone.to_sentence
# 	end
	
# 	def self.atividades(user_id)
# 		User.find_by_sql [%q{( select recados.created_at, "recados" as tipo, recados.id, users.login, negocios.codigo from (recados inner join users on users.id=recados.user_id ) inner join negocios on negocios.id=recados.negocio_id where users.id= :user_id) union (select imagems.created_at, "imagems" as tipo, imagems.id, users.login, negocios.codigo from ((imagems inner join users on users.id=imagems.user_id ) inner join galerias on galerias.id=imagems.galeria_id) inner join negocios on negocios.id=galerias.negocio_id where users.id= :user_id ) order by 1 desc}, {:user_id=>user_id}]
# 	end

# 	def self.atividades_all
# #		User.find_by_sql '( select recados.created_at, "recados" as tipo, recados.id, users.login, negocios.codigo from (recados inner join users on users.id=recados.user_id ) inner join negocios on negocios.id=recados.negocio_id ) union (select imagems.created_at, "imagems" as tipo, imagems.id, users.login, negocios.codigo from ((imagems inner join users on users.id=imagems.user_id ) inner join galerias on galerias.id=imagems.galeria_id) inner join negocios on negocios.id=galerias.negocio_id ) order by 1 desc'
		
# 		User.find_by_sql '( select recados.created_at, "recados" as tipo, recados.id, users.login, negocios.codigo from (recados inner join users on users.id=recados.user_id ) inner join negocios on negocios.id=recados.negocio_id ) '+
# 			' union  '+
# 			' (select imagems.created_at, "imagems" as tipo, imagems.id, users.login, negocios.codigo from ((imagems inner join users on users.id=imagems.user_id ) inner join galerias on galerias.id=imagems.galeria_id) inner join negocios on negocios.id=galerias.negocio_id )  '+
# 			' union  '+
# 			' (select comentarios.created_at, "comentario_recados" as tipo, comentarios.id, users.login, negocios.codigo from ((comentarios inner join users on (users.id=comentarios.user_id and comentarios.comentavel_type="Recado")) inner join recados on recados.id=comentarios.comentavel_id) inner join negocios on negocios.id=recados.negocio_id ) '+
# 			' union  '+
# 			' (select comentarios.created_at, "comentario_noticias" as tipo, comentarios.id, users.login, negocios.codigo from ((comentarios inner join users on (users.id=comentarios.user_id and comentarios.comentavel_type="Noticia")) inner join noticias on noticias.id=comentarios.comentavel_id) inner join negocios on negocios.id=noticias.negocio_id ) '+
# 			' union  '+
# 			' (select videos.created_at, "videos" as tipo, videos.id, users.login, negocios.codigo from (videos inner join users on users.id=videos.user_id )  inner join negocios on negocios.id=videos.negocio_id )  '+
# 			' union  '+
# 			' (select conexaos.created_at, "conexaos" as tipo, conexaos.id, users.login, negocios.codigo from (conexaos inner join users on users.id=conexaos.user_id )  inner join negocios on negocios.id=conexaos.negocio_id )  '+
# 			' union  '+
# 			' (select negocios.created_at, "negocios" as tipo, negocios.id, users.login, negocios.codigo from negocios inner join users on users.id=negocios.user_id ) '+			
# 			' union '+
# 			' ( select users.created_at, "users" as tipo, users.id, users.login, users.codigo from  users ) '+			
# 			' order by 1 desc' +
# 			' limit 10 '
# 	end
	
	#Nao funciona acts_as_textiled  :home
	
#	acts_as_authentic
=begin	
	acts_as_authentic do |c|
#		c.validate_login_field = false
		c.validates_uniqueness_of_email_field_options = {:if => "false"}
	end 	
	
	def deliver_password_reset_instructions!
		reset_perishable_token!
	end
=end	
	def admin?
		tipousuario_id==1
	end

	def partner?
		Partner.exists? :user_id=>self.id
	end

	def tipoperfilusuario
		if self.tipousuario_id==1
			:admin
		elsif self.partner? 
			if self.partner.perfil_ativo?
				:partnerpleno
			else
				:partnerjunior
			end
		else
			:usuario
		end
	end
	
	def tipoperfilusuario_id
		if self.tipousuario_id==1
			1
		elsif self.partner? 
			if self.partner.perfil_ativo?
				2
			else
				3
			end
		else
			0
		end
	end

	def tipoperfilusuario_nameliteral
		self.tipoperfilusuario==:admin ? 'Administrador' : 
		(self.tipoperfilusuario==:partnerpleno ? 'Parceiro Pleno' : 
			(self.tipoperfilusuario==:partnerjunior ? 'Parceiro': (self.tipoperfilusuario==:usuario ? 'Usuário' : '')))
	end	

  def cpf_apenasnumeros
	   self.cpf.gsub('.','').gsub('-','')
  end
  def cnpj_apenasnumeros
	   self.cnpj.gsub('.','').gsub('-','')
  end	  

  def tipopessoa_name_literal	#(args)
    self.tipopessoa_id==2 ? 'Pessoa Jurídica' : 'Pessoa Física'
  end

  def self.tipopessoa_id_coleccion
  	varray=[]
  	varray<<["Pessoa Física", "1"]
  	varray<<["Pessoa Jurídica", "2"]
  	return varray
  end  

# new function to set the password without knowing the current password used in our confirmation controller. 
 def attempt_set_password(params)
 	#http://bladeronline.wordpress.com/2012/11/27/setting-2-step-confirmation-using-devise-in-rails/
	 p = {}
	 p[:password] = params[:password]
	 p[:password_confirmation] = params[:password_confirmation]
	 update_columns(p)
 end
 # new function to return whether a password has been set
 def has_no_password?
 	#http://bladeronline.wordpress.com/2012/11/27/setting-2-step-confirmation-using-devise-in-rails/
 	self.encrypted_password.blank?
 end
# new function to provide access to protected method unless_confirmed
 def only_if_unconfirmed
 	#http://bladeronline.wordpress.com/2012/11/27/setting-2-step-confirmation-using-devise-in-rails/
 	pending_any_confirmation {yield}
 end  


	# def atualizacliente
	#  	@user=self
	#  	if @user.cliente
	#  		@cliente=@user.cliente
	#  	else
	# 		@cliente=Cliente.new
	#  		@cliente.user_id=@user.id
	#  	end
	# 	@cliente.email=@user.email
	# 	@cliente.name=@user.nome
	# 	@cliente.datanascimento=@user.datanascimento
	# 	@cliente.sexo_id=@user.sexo_id
	# 	@cliente.cep=@user.cep
	# 	@cliente.cep_id=@user.cep_id
	# 	@cliente.endereco=@user.endereco
	# 	@cliente.numero=@user.numero
	# 	@cliente.complemento=@user.complemento	
	# 	@cliente.bairro=@user.bairro
	# 	@cliente.municipio=@user.municipio
	# 	@cliente.uf=@user.uf
	# 	@cliente.pontoreferencia=@user.pontoreferencia
	# 	@cliente.telefone1=@user.telefone1
	# 	@cliente.telefone2=@user.telefone2
	# 	@cliente.geoname_id=@user.geoname_id
	# 	@cliente.geocodelat=@user.geocodelat
	# 	@cliente.geocodelng=@user.geocodelng 	
	# 	@cliente.save
	# end
 
	# def saldopa
	# 	vextrato=self.extratopartneratividades.last
	# 	(vextrato.blank? ? 0 : vextrato.saldo )
	# end	
	# def saldopb		
	# 	vextrato=self.extratopartners.last
	# 	(vextrato.blank? ? 0 : vextrato.saldo )
	# end	
	# def saldopc
	# 	vextrato=self.extratopartnercreditos.last
	# 	(vextrato.blank? ? 0 : vextrato.saldo )
	# end		
	# def saldopaa
	# 	self.saldopa*Taxapapb.last.taxa#*0.9
	# end	
	# def saldopd
	# 	self.saldopb+self.saldopaa+self.saldopc
	# 	#self.saldopb+self.saldopa+self.saldopc
	# end		
private
  def self.process_uri(uri)
    require 'open-uri'
    require 'open_uri_redirections'
    open(uri, :allow_redirections => :safe) do |r|
      r.base_uri.to_s
    end
  end
end
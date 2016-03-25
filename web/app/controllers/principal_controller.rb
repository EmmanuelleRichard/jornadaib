# encoding: utf-8

class PrincipalController < ApplicationController
	#skip_before_filter :verify_authenticity_token, :only => [:cria_negocio_s2, :consultaspeedflash]

	def oportunidade
	end
	
	def index
	    logger.debug 'entrou no index'
# @file = render_to_string :file => 'app/assets/mobile/www/index.html'
		#@retornoconsulta_geral = Negocio.all
	end	
=begin	
  def registras2online
		logger.debug 'registras2online.entrou'

		vdado=params[:dado]
		vdado=JSON vdado
		logger.debug vdado

#negocio_id:integer tipo_integer chave:integer dado:text 		

		logger.debug '------'
		logger.debug vdado["negocio"].to_s
		logger.debug '------'
		negocio=Negocio.find_by_single_access_token vdado["negocio"].to_s
		
		logger.debug negocio.id
		if vdado["tipo"].to_s=='1'  #boletim escolar
			vdado["parametros"].each do |p|
				s2online=S2online.find_by_chave p["registro"].to_i, :conditions=>{:negocio_id=>negocio.id}, :include=>:negocio

				if !s2online
					logger.debug 'nao encontrou'
					s2online=S2online.new		
				end
				s2online.tipo=vdado["tipo"].to_i  #1=boletim escolar
				s2online.negocio_id=negocio.id
				s2online.chave=p["registro"].to_i
				logger.debug 'data'
				logger.debug p
				s2online.dado=p.to_json

				#@Ordemservico.from_json vdado
				logger.debug s2online

				s2online.save		
			
			end
		elsif vdado["tipo"].to_s=='2'  #
		
		end

		logger.debug 'salvou'
		render :json => 'concluido'

		logger.debug 'registras2online.faltou'
  end 	

	def consultas2online 
		logger.debug 'consultas2online.entrou'
		@s2online = S2online.find_by_chave params[:chave].to_i, :conditions => ['negocio_id= ? and tipo=?', params[:negocio_id], params[:tipo]] 
		if @s2online
			render :layout=>false
		else
			render :inline=> 'nada encontrado'
		end
	end
	
  def cria_negocio_s2
		logger.debug "entrou no cria_negocio_s2"
	
		vdado=params[:dado]
	
		logger.debug vdado
#{"login": "onbitnomedefantasia", "email": "onbitrazaosocial@onbit.com.br", "telefone1": "8488210491", "programa": "COMERCIO", "nome": "ONBIT NOME DE FANTASIA"}
		
		jdado=ActiveSupport::JSON.decode(vdado)
		logger.debug '------'
		@user=User.find_by_email jdado["email"]
		if !@user
			@user=User.new
			@user.login=jdado["login"]
			@user.email=jdado["email"]
			@user.telefone1=jdado["telefone1"]
			@user.nome=jdado["nome"]
			@codigonegocio=@user.login.downcase.delete('@./')  #Remove caracteres que podem causar problema  	
			#@user.login = @codigonegocio
	#		@user.login = @user.login.downcase
		
			#Verifica se ha outro usuario ja cadastrado com o login solicitado 
			user_quant=User.count(:conditions => ["login LIKE ? ", "#{'admin'+@codigonegocio}%"])

			#Verifica se h? outro negocio ja cadastrado com o login solicitado 
			negocio_quant=Negocio.count(:conditions => ["codigo LIKE ? ", "#{@codigonegocio}%"])
		
			if negocio_quant>user_quant 
				user_quant=negocio_quant		
			end
		
			if user_quant>0
				@codigonegocio=@codigonegocio+(user_quant+1).to_s
			end
			logger.debug @codigonegocio

			@user.login = 'admin'+@codigonegocio
			
			@user.codigo=@user.login
			@user.password=Principal.codigo
			@user.status=true
			@user.patrocinador_id=1
			@user.s2=true
		end
		logger.debug "respondendo"
		logger.debug "nao esta logado"
		if @user.save(:validate=>false) #_without_session_maintenance
			# @user.reset_single_access_token!
			# @user.reset_authentication_token! if !@user.authentication_token
			#send_email_active_user
		
			# Cria o negocio no Ah!Tah!
			@negocio=Negocio.new
			@negocio.codigo=@codigonegocio
			@negocio.email=@user.email
			@negocio.telefone1=@user.telefone1
			@negocio.telefone2=@user.telefone2			
			@negocio.status=true
			@negocio.nome=@user.nome
			@negocio.s2=@user.s2
	
			@negocio.user_id=@user.id
			# e sempre nil
			@negocio.single_access_token=@user.authentication_token
			@negocio.single_access_token=Base64::encode64(Time.now.to_f.to_s)
			
			@negocio.dado='{"programa":"'+jdado["programa"]+'"}'
			@negocio.programa=jdado["programa"]
		
			@negocio.save
			#app_registra_atividade(negocio, user, objeto, descricao)
			logger.debug '@user.login'
			logger.debug @user.login
			logger.debug '@negocio.codigo'
			logger.debug @negocio.codigo
			#app_registra_atividade( :negocio=>@negocio, :user=>@user, :objeto=>@negocio, :descricao=>@user.login+' cadastrou o negocio '+@negocio.codigo)	
			
			logger.debug @negocio.to_json
			render :json => @negocio
		else
			logger.debug "nao salvou"
			render :json => @negocio.errors
		end		
  end  	
	#processar
	#informaquantexecucao
	#retornartokenspeedflash
	def consultaspeedflash
		logger.debug 'consultaspeedflash'
		vdado=params[:dado]
		logger.debug vdado
#{"processar": "informaquantexecucao", "codigo": "onbitnomedefantasia", "quantexecucao": "4", "login": "onbitnomedefantasia", "email": "onbitrazaosocial@onbit.com.br", "telefone1": "8488210491", "programa": "COMERCIO", "nome": "ONBIT NOME DE FANTASIA"}
		
		jdado=JSON vdado


		logger.debug jdado
		logger.debug jdado['quantexecucao']
		
		negocio=Negocio.find_by_single_access_token jdado["single_access_token"].to_s if jdado["single_access_token"].length>1
		negocio=Negocio.find_by_codigo jdado["codigo"].to_s if !negocio
		
		negocio=Negocio.find_by_email jdado["email"].to_s if !negocio
		
		
		if jdado["processar"]=='retornartokenspeedflash'
			if negocio
				render :json=>{:single_access_token=>negocio.single_access_token, :codigo=>jdado["codigo"].to_s}
			else
				render :json=>{:erro=>'naolocalizado'}
			end
		elsif jdado["processar"]=='informaquantexecucao'
			logger.debug 'informaquantexecucao'
			if negocio
				logger.debug 'encontrou o negocio'
				if negocio.dado
					logger.debug 'negocio.dado'
					logger.debug negocio.dado
					negociodado=ActiveSupport::JSON.decode(negocio.dado) 
					logger.debug 'negocio.dado[dado]'		#		
					# logger.debug negocio.dado["dado"]
=#begin
					if negocio.dado
						xdado= negocio.dado["dado"]
					else
						#xdado=JSON "codigo"=>vdado["codigo"]
						xdado= vdado
					end
					
					if xdado
						xdado['quantexecucao']=jdado['quantexecucao']
					else
						xdado={:quantexecucao=>jdado['quantexecucao']}
					end
					exemplos de uso abaixo
					a=j.decode n.dado
					a["quantexecucao"]
=#end				
					
					#logger.debug xdado
					logger.debug 'vdado'
					logger.debug jdado['quantexecucao']
					logger.debug 'vai setar'
					#xdado=xdado.from_json
					logger.debug 'setou'
					xdado=Hash[:codigo=>negocio.codigo, :quantexecucao=>jdado['quantexecucao']]
					negociodado["quantexecucao"]=jdado['quantexecucao']
					logger.debug 'xdado'
					logger.debug xdado
					#xdado=ActiveSupport::JSON.encode(negociodado) 
					xdado=negociodado 
					#logger.debug xdado.to_json
					# negocio.update_attribute :dado, xdado.to_json, :quantexecucao=>jdado['quantexecucao']
					
					negocio.update_columns :dado=>xdado.to_json, :quantexecucao=>jdado['quantexecucao']
				else
					# negocio.update_attribute :dado, '{"quantexecucao":"'+jdado['quantexecucao']+'"}'
					negocio.update_columns :dado=> '{"quantexecucao":"'+jdado['quantexecucao']+'"}', :quantexecucao=>jdado['quantexecucao']
				end
				
				
				render :json=>{:codigo=>negocio.codigo}
			else
				render :json=>{:erro=>'naolocalizado'}
			end			
		end
	end
=end	
	def pesquisageral
		logger.debug 'entrou na pesquisa geral'
=begin		
		if params[:ramoatividade]
			@negocios_destaque=Negocio.find(:all, :limit=>5, :order=>'rand()', :conditions=>"(id in (select negocio_id from negocios_ramoatividades where ramoatividade_id='#{params[:ramoatividade]}')) and temsite=1 ")
			@negocios_geral=Negocio.paginate(:page => params[:page],  :per_page => 10,  :order=>'rand()', :conditions=>"(id in (select negocio_id from negocios_ramoatividades where ramoatividade_id='#{params[:ramoatividade]}')) and  picture_file_name <>'' ")
			
			@classificados_destaque = Classificado.find(:all, :order=>'rand()',:conditions=>"(categoria_id = (select id from categorias where nome = '#{params[:ramoatividade]}')) ",:order=>'rand()', :limit=>4, :include => [:classificadofotos, :negocio]) #, :include=>:user)
			@classificados_geral = Classificado.paginate(:page => params[:page],  :per_page => 10, :joins=>:categoria, :order=>'rand()',:conditions=>"(categoria_id = (select id from categorias where nome = '#{params[:ramoatividade]}')) ",:order=>'rand()', :include => [:classificadofotos, :negocio]) #, :include=>:user)		
		else
			@negocios_destaque=Negocio.find(:all, :limit=>5, :order=>'rand()', :joins=>:ramoatividades, :conditions=>"(nome like '%#{params[:pesquisa]}%' or codigo like '%#{params[:pesquisa]}%' or home like '%#{params[:pesquisa]}%' or ramoatividades.name like '%#{params[:pesquisa]}%') and temsite=1 ")
			@negocios_geral=Negocio.paginate(:page => params[:page],  :per_page => 10,  :joins=>:ramoatividades, :order=>'rand()', :conditions=>"(nome like '%#{params[:pesquisa]}%' or home like '%#{params[:pesquisa]}%' or codigo like '%#{params[:pesquisa]}%' or ramoatividades.name like '%#{params[:pesquisa]}%') and negocios.picture_file_name <>'' ")
			
			@classificados_destaque = Classificado.find(:all, :joins=>:categoria, :order=>'rand()',:conditions => "titulo like '%#{params[:pesquisa]}%' or descricao like '%#{params[:pesquisa]}%' or categorias.nome like '%#{params[:pesquisa]}%' or categorias.nome like '%#{params[:pesquisa]}%'",:order=>'rand()', :limit=>4, :include => [:classificadofotos, :negocio]) #, :include=>:user)
			@classificados_geral = Classificado.paginate(:page => params[:page],  :per_page => 10, :joins=>:categoria, :order=>'rand()',:conditions => "titulo like '%#{params[:pesquisa]}%' or descricao like '%#{params[:pesquisa]}%' or categorias.nome like '%#{params[:pesquisa]}%' or categorias.nome like '%#{params[:pesquisa]}%'",:order=>'rand()', :include => [:classificadofotos, :negocio]) #, :include=>:user)		
		end
=end		
=begin
=end
	end
	
	
	def processarelatorio
		logger.debug 'processarelatorio.entrou'
		@negocios=Negocio.all
		@negocios.each  do |negocio|
				#Email.deliver_padrao(:corpo => corpo, :assunto => subject, :para => @negocio.email)
				#fv_envia_email(negocio, user_para, assunto, mensagem)
				mensagem='Relat&oacute;rio de Acessos<br/>'
				
				for i in 1..8 do
					data=(DateTime.now-i).to_date
					logger.debug data
					acesso=negocio.negocioacessos.find(:all, :conditions=>{:data=> data})
					if acesso.count>0
						mensagem=mensagem+acesso.data.strftime("%d/%m/%Y")+': '+acesso.quant.to_s+' acessos<br/>'					
					else
						mensagem=mensagem+data.strftime("%d/%m/%Y")+': 0 acesso<br/>'					
					end
				end

				#fv_envia_email(negocio, negocio.email, '[Ah!Tah!] Relatorio de Atividades', mensagem)
				fv_envia_email(negocio, 'rick@onbit.com.br', '[Ah!Tah!] Relatorio de Atividades', mensagem, 'Ah!Tah!')
		end
		render :nothing => true
		logger.debug 'processarelatorio.saiu'
	end	
	def cep_select
		logger.debug 'cep_select.entrou'
		if !params[:cep].blank?
			@cep=Cep.find_by_codigo params[:cep].somente_numeros
			if !@cep
				require "open-uri"
				enderecoinicial="http://cep.republicavirtual.com.br/web_cep.php?cep=#{params[:cep]}&formato=json"
				
				logger.debug enderecoinicial
				doc = open(enderecoinicial).read
				j=JSON.parse doc
				logger.debug doc
				logger.debug j["tipo_logradouro"]
				logger.debug j["logradouro"]
				logger.debug j["bairro"]				
				logger.debug j["cidade"]
				logger.debug j["uf"]

				if j["resultado"]== "1"
					@uf=Uf.find_by_name j["uf"]
					@uf=Uf.create :name=>j["uf"] if !@uf

					@cidade=Cidade.where(:name=>params[:cidade], :uf_id=>@uf.id).first
					@cidade=Cidade.create :name=>j["cidade"], :uf_id=>@uf.id if !@cidade

					@bairro=Bairro.where(:name=>params[:bairro], :cidade_id=>@cidade.id).first
					@bairro=Bairro.create :name=>j["bairro"], :cidade_id=>@cidade.id if !@bairro

					@tipologradouro=Tipologradouro.find_by_name j["tipo_logradouro"]
					@tipologradouro=Tipologradouro.create :name=>j["tipo_logradouro"] if !@tipologradouro

					@cep=Cep.new
					@cep.codigo=params[:cep].somente_numeros
					@cep.name=params[:cep]			
					@cep.tipologradouro_id=@tipologradouro.id
					@cep.logradouro=j["logradouro"]
					@cep.bairro_id=@bairro.id

					@cep.save	
				end
			end
		end
		if @cep 
			vresultado='"id":"'+@cep.id.to_s+'", "cep":"'+@cep.name+'","tipo_logradouro":"'+@cep.tipologradouro.name+'","logradouro":"'+@cep.logradouro+'","bairro":"'+@cep.bairro.name+'","cidade":"'+@cep.bairro.cidade.name+'","uf":"'+@cep.bairro.cidade.uf.name+'"'
			render :text=>'{"status":"ok", '+ vresultado+'}'
		else
			render :text=>'{"status":"CEP não localizado."}'
		end
	end	
	
	def geonames_select
		logger.debug 'geonames_select.entrou'
		#require "hpricot" # need hpricot and open-uri
		require "open-uri"
		enderecoinicial="http://ws.geonames.org/searchJSON?featureClass=#{params[:featureClass]}&style=full&maxRows=#{params[:maxRows]}&name_startsWith='#{CGI::escape params[:name_startsWith]}'&country=#{params[:country]}"
		
		logger.debug enderecoinicial
#require 'open-uri'
		doc = open(enderecoinicial).read
#		doc=doc.split('(')[1].split(')')[0]
		j=JSON.parse doc
		
		vresultado=[]
		j['geonames'].each do |objeto|
			vresultado<<'{"geonameId":'+objeto['geonameId'].to_s+',"name":"'+objeto['name'].to_s+'","countryName":"'+objeto['countryName'].to_s+'","adminName1":"'+objeto['adminName1'].to_s+'","lng":"'+objeto['lng'].to_s+'","lat":"'+objeto['lat'].to_s+'"}'
		end
		ActiveRecord::Base.include_root_in_json = false
#		render :text=>params[:callback]+'({"quantResults":1, "resultado":'+ @objetos.to_json+'});'

		vretorno=params[:callback]+'({"totalResultsCount":'+j['totalResultsCount'].to_s+',"geonames":['+ vresultado.join(',')+']});'
		logger.debug vretorno
		render :text=>vretorno
		ActiveRecord::Base.include_root_in_json = true	
=begin

#		doc = Hpricot(open(enderecoinicial))
		logger.debug doc
		logger.debug 'xxx'
		vsql=
			"SELECT 
			geonames.id, 
			geonames.cidade, 
			geonames.pais, 
			geonames.estado, 
			geonames.lng, 
			geonames.lat
			FROM 
			geonames
			WHERE upper(geonames.cidade) like '%#{params[:name_startsWith].upcase}%'
			"

		vsql=vsql+" order by geonames.cidade asc"
		@objetos = Geoname.find_by_sql(vsql)
		
		vresultado=[]
		@objetos.each do |objeto|
			vresultado<<'{"geonameId":'+objeto.id.to_s+',"name":'+objeto.cidade.to_json+',"countryName":'+objeto.pais.to_json+',"adminName1":'+objeto.estado.to_json+',"lng":"'+objeto.lng+'","lat":"'+objeto.lat+'"}'
		end
#[{"id":49,"name":"Alanna M\u00e1rnea Ara\u00fajo Chagas - Alanna","pessoa_id":4040}]
		
		ActiveRecord::Base.include_root_in_json = false
#		render :text=>params[:callback]+'({"quantResults":1, "resultado":'+ @objetos.to_json+'});'
		render :text=>params[:callback]+'({"totalResultsCount":'+@objetos.count.to_s+',"geonames":['+ vresultado.join(',')+']})'
		ActiveRecord::Base.include_root_in_json = true	
=end		
	end	
end
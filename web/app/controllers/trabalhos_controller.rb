class TrabalhosController < ApplicationController
	before_filter :require_user, :except=>[:index, :show]

	respond_to :json
	def index
    if params[:q]
      @trabalhos=Trabalho.where("name LIKE ? or turma like ? or coordenadores like ? or componentes like ?", "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%")


      # where("name like '%string%' or turma like '%: string, coordenadores: string, componentes: text, local")
    else
  		@trabalhos=Trabalho.all

    end
    if @trabalhos
      vtrabalhos=[]
      @trabalhos.each do |trabalho|
        vtrabalho=[]
        vtrabalho<<'"id":'+trabalho.id.to_json
        vtrabalho<<'"name":'+trabalho.name.to_json
        vtrabalho<<'"turma":'+trabalho.turma.to_json
        vtrabalho<<'"coordenadores":'+trabalho.coordenadores.to_json
        vtrabalho<<'"componentes":'+trabalho.componentes.to_json
        vtrabalho<<'"local":'+trabalho.local.to_json

        vtrabalhos<<'{'+vtrabalho.join(',')+'}'
      end
      render json: "[#{vtrabalhos.join(',')}]"   
    else
      render json: "nada localizado"   
    end
	end

  # def listagem
  #   @negocio = Negocio.find_by_codigo(params[:negocio_id])
  #   if fv_responsavel?(@negocio) 
  #     @produtos = Produto.find(:all, :include=>[:negocio, :categoria, :variacoes, :opcionais], :conditions => ["negocio_id=?", @negocio.id])    
  #     render :layout=> @negocio.layout
  #   else
  #     flash[:error] = 'Não permitido.'
  #     redirect_to @negocio
  #   end    
  # end

  # def listasegundametade
  #   @negocio = Negocio.find_by_codigo(params[:negocio_id])
  #   @produtoprimeirametade = @negocio.produtos.find(app_extrai_codigo_id(params[:id]))
  #   @produtossegundametade = @negocio.produtos.where("produtos.categoria_id=#{@produtoprimeirametade.categoria_id} #{'or produtos.categoria_id='+@produtoprimeirametade.categoria.categoria_id if @produtoprimeirametade.categoria.categoria_id} ")
  # end

  # GET /trabalhos/1
  # GET /trabalhos/1.xml
  def show
    logger.debug 'show.entrou'
    if current_user
      logger.debug 'current_user'
    else
      logger.debug 'sem current_user'
    end
    logger.debug current_user
    @trabalho = Trabalho.find(params[:id])

    vjson=[]
    # vjson<<"'id':#{@produto.id}"
    vjson<<'"id":'+@trabalho.id.to_json
    vjson<<'"name":'+@trabalho.name.to_json
    vjson<<'"turma":'+@trabalho.turma.to_json
    vjson<<'"coordenadores":'+@trabalho.coordenadores.to_json
    vjson<<'"componentes":'+@trabalho.componentes.to_json
    vjson<<'"local":'+@trabalho.local.to_json

    render text: "{#{vjson.join(',')}}"
  end

  # # GET /produtos/new
  # # GET /produtos/new.xml
  # def new
  #   @negocio=Negocio.find_by_codigo params[:negocio_id]
  #   if fv_responsavel?(@negocio) 
  #     @produto = Produto.new
  #     @categorias = @negocio.categorias.select('DISTINCT categorias.id, categorias.nome, categorias.categoria_id')
  #     @variacoesprincipais = @negocio.variacoes.where("variacao_id is null")
  #     @variacoessecundarias = @negocio.variacoes.where("variacao_id is not null")
  #     @variacoes = @negocio.variacoes

  #     @opcionaisprincipais = @negocio.opcionais.where("opcional_id is null")
  #     @opcionaissecundarios = @negocio.opcionais.where("opcional_id is not null")
  #     @opcionais = @negocio.opcionais
  #   else
  #     flash[:error] = 'Não permitido.'
  #     redirect_to @negocio
  #   end
  # end

  # # GET /produtos/1/edit
  # def edit
  #   @negocio=Negocio.find_by_codigo params[:negocio_id]
  #   if fv_responsavel?(@negocio)     
		#   @produto = Produto.find(app_extrai_codigo_id(params[:id]))
  #     @categorias = @negocio.categorias.select('DISTINCT categorias.id, categorias.nome, categorias.categoria_id')
  #     @variacoesprincipais = @negocio.variacoes.where("variacao_id is null")
  #     @variacoessecundarias = @negocio.variacoes.where("variacao_id is not null")
  #     @variacoes = @negocio.variacoes

  #     @opcionaisprincipais = @negocio.opcionais.where("opcional_id is null")
  #     @opcionaissecundarios = @negocio.opcionais.where("opcional_id is not null")
  #     @opcionais = @negocio.opcionais
  #   else
  #     flash[:error] = 'Não permitido.'
  #     redirect_to @negocio
  #   end      
  # end

  # POST /produtos
  # POST /produtos.xml
  def create
    logger.debug 'create.entrou'
    params[:trabalho]=params
    params[:trabalho]
    logger.debug 'trabalho'
    logger.debug params[:trabalho]

    @trabalho = Trabalho.new(trabalho_params)
    if @trabalho.save
      render :json=>@trabalho.to_json
    else
      render :json =>{ :error => @trabalho.errors, status: :unprocessable_entity}
    end
  end

  # def recursive_symbolize_keys! hash
  #   hash.symbolize_keys!
  #   hash.values.select{|v| v.is_a? Hash}.each{|h| recursive_symbolize_keys!(h)}
  # end

  # PUT /produtos/1
  # PUT /produtos/1.xml
  def update
    logger.debug 'entrou no update'
    logger.debug 'params'
    vparam=params
    logger.debug params
# params= JSON.parse(vparam, :symbolize_names => true) 


    logger.debug params

    params[:trabalho]=params
    logger.debug 'trabalho'
    logger.debug params



    @trabalho = Trabalho.find(params[:id])
    if  (@trabalho)
      
      if @trabalho.update_columns(trabalho_params)
        render :json=>@trabalho.to_json
      else
        render :json =>{ :error => @trabalho.errors, status: :unprocessable_entity}
      end
    else
      render :json =>{ :error => 'Não permitido'}
    end
  end

  # DELETE /produtos/1
  # DELETE /produtos/1.xml
  def destroy
    @trabalho = Trabalho.find(params[:id])
    if @trabalho.destroy
      render :text => 'ok'
    else
      render :json =>{ :error => @trabalho.errors, status: :unprocessable_entity}
    end
  end
private
    def trabalho_params
      params.require(:trabalho).permit(:name, :turma, :coordenadores, :componentes, :local)
    end
end


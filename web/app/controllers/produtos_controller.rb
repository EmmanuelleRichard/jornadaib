# encoding: utf-8

# class ProdutosController < InheritedResources::Base
class ProdutosController < ApplicationController
  before_filter :require_user, :except=>[:index, :show, :update]
  # belongs_to :negocio

  respond_to :json
  # GET /produtos
  # GET /produtos.xml
  def index
    if params[:negocio]
  		@negocio = Negocio.find_by_codigo(params[:negocio])
  		@produtos = Produto.include(:negocio).where(["negocio_id=?", @negocio.id])	
      render :layout=> @negocio.layout
    else	
      @produtos=Produto.all
      # render @produtos
      # render :json => @produtos
      # @produtos

      vprodutos=[]
      @produtos.each do |produto|
        vproduto=[]
        vproduto<<'"id":'+produto.codigo.to_json
        vproduto<<'"codigo":'+produto.codigo.to_json
        vproduto<<'"name":'+produto.name.to_json
        vproduto<<'"description":'+produto.description.to_json
        # vproduto<<'"preco":'+produto.preco.to_json
        vproduto<<'"ofertapreco":'+produto.preco.real.to_s.to_json
        vproduto<<'"ofertapor":'+produto.precopromocional.real.to_s.to_json
        vproduto<<'"src":'+('http://192.168.57.101:3000'+produto.picture.url(:small)).to_json


        vprodutos<<'{'+vproduto.join(',')+'}'
      end
      render json: "[#{vprodutos.join(',')}]"
		end
  end

  def listagem
    @negocio = Negocio.find_by_codigo(params[:negocio_id])
    if fv_responsavel?(@negocio) 
      @produtos = Produto.find(:all, :include=>[:negocio, :categoria, :variacoes, :opcionais], :conditions => ["negocio_id=?", @negocio.id])    
      render :layout=> @negocio.layout
    else
      flash[:error] = 'Não permitido.'
      redirect_to @negocio
    end    
  end

  def listasegundametade
    @negocio = Negocio.find_by_codigo(params[:negocio_id])
    @produtoprimeirametade = @negocio.produtos.find(app_extrai_codigo_id(params[:id]))
    @produtossegundametade = @negocio.produtos.where("produtos.categoria_id=#{@produtoprimeirametade.categoria_id} #{'or produtos.categoria_id='+@produtoprimeirametade.categoria.categoria_id if @produtoprimeirametade.categoria.categoria_id} ")
  end

  # GET /produtos/1
  # GET /produtos/1.xml
  def show
    logger.debug 'show.entrou'
    if current_user
      logger.debug 'current_user'
    else
      logger.debug 'sem current_user'
    end
    logger.debug current_user
    @produto = Produto.find(app_extrai_codigo_id(params[:id]))
    # @negocio=Negocio.includes(:categorias).find(@produto.negocio_id)

    @produtoprimeirametade=Produto.find(app_extrai_codigo_id(params[:primeirametade_id])) if params[:primeirametade_id]
    if @produtoprimeirametade and @produtoprimeirametade==current_cart.line_items.last.produto
      @lineitemprimeirametade=current_cart.line_items.last
      @variacoesprimeiraparteandsql=" and variacoes.id in (#{@lineitemprimeirametade.variacoes}) "
    end

    @variacoesprincipaisid = @produto.variacoes.select('distinct variacoes.variacao_id as id')
    @variacoesprincipais = Variacao.where(:id=>@variacoesprincipaisid)

    @opcionaisprincipaisid = @produto.opcionais.select('distinct opcionais.opcional_id as id')
    @opcionaisprincipais = Opcional.where(:id=>@opcionaisprincipaisid)    

    # respond_to do |format|
    #   format.html # show.html.erb
    #   format.xml  { render :xml => @produto }
    # end

    vjson=[]
    # vjson<<"'id':#{@produto.id}"
    vjson<<'"id":'+@produto.codigo.to_json
    vjson<<'"codigo":'+@produto.codigo.to_json
    vjson<<'"name":'+@produto.name.to_json
    vjson<<'"description":'+@produto.description.to_json
    vjson<<'"preco":'+@produto.preco.to_json
    vjson<<'"ofertapreco":'+@produto.ofertapreco.to_json
    vjson<<'"ofertapor":'+@produto.ofertapor.to_json
    vjson<<'"fracaomeia":'+@produto.fracaomeia.to_json
    vjson<<'"picturesmall":'+@produto.picturesmall.to_json
    vjson<<'"picture":'+@produto.picturesmall.to_json
    vjson<<'"picturelarge":'+@produto.picturelarge.to_json
    vjson<<'"disponivel":'+@produto.disponivel.to_json
    vjson<<'"empromocao":'+@produto.empromocao.to_json
    vjson<<'"especificacoes":'+@produto.especificacoes.to_json
    vjson<<'"categoria_id":'+@produto.categoria_id.to_json
    vjson<<'"tipomedida_id":'+@produto.tipomedida_id.to_json
    vjson<<'"fv_responsavel":'+fv_responsavel?(@produto.negocio).to_json
    # vjson<<'"fv_responsavel":'+true.to_json
    
    client_id = request.headers['client']
    token = request.headers['access-token']

    logger.debug client_id
    logger.debug token

    # logger.debug valid_token?(token, client_id)
    
    user = User.find_by_uid(request.headers["uid"])

    # vjson<<'"fv_responsavel":'+(user.valid_token?(token, client_id)).to_json
    vjson<<'"exibirmensagemimgilust":'+true.to_json


    if @produtoprimeirametade
      vprodutoprimeirametade=[]
      vprodutoprimeirametade<<'"name":'+@produtoprimeirametade.name.to_json
      vprodutoprimeirametade<<'"picturethumb:'+@produtoprimeirametade.picturethumb.to_json

      vjson<<'"produtoprimeirametade":'+"{#{vprodutoprimeirametade.join(',')}}"
    end

    if @variacoesprincipais
      vvariacoesprincipais=[]
      
      @variacoesprincipais.each do |variacaoprincipal|
        vvariacaoprincipal=[]
        vvariacaoprincipal<<'"name":'+variacaoprincipal.name.to_json
        vvariacaoprincipal<<'"id":'+variacaoprincipal.id.to_json

        vvariacoessecundarias=[]
        @produto.produtos_variacoes.joins("inner join variacoes on variacoes.id=produtos_variacoes.variacao_id").where("variacoes.variacao_id = #{variacaoprincipal.id} #{@variacoesprimeiraparteandsql}").order('produtos_variacoes.id').each do |produtovariacao|
            vprodutovariacao=[]
            vprodutovariacao<<'"variacao_id":'+produtovariacao.variacao_id.to_json
            vprodutovariacao<<'"influenciapreco_id":'+produtovariacao.influenciapreco_id.to_json
            # vprodutovariacao<<'"precoatual":'+(produtovariacao.empromocao ? produtovariacao.precopromocional : produtovariacao.preco).to_json
            
            if produtovariacao.precopromocional and produtovariacao.precopromocional.to_f>0 and produtovariacao.preco.to_f>produtovariacao.precopromocional.to_f
              vprodutovariacao<<'"empromocao":'+true.to_json
              vprodutovariacao<<'"precoatual":'+produtovariacao.precopromocional.to_json
            else
              vprodutovariacao<<'"precoatual":'+produtovariacao.preco.to_json
            end
            vprodutovariacao<<'"preco":'+produtovariacao.preco.real.to_s.to_json
            vprodutovariacao<<'"precopromocional":'+produtovariacao.precopromocional.real.to_s.to_json

            vsaux=''
            if produtovariacao.influenciapreco_id.to_i==0

            else
              if produtovariacao.influenciapreco_id==1
                vsaux+=': '
              elsif produtovariacao.influenciapreco_id==2
                vsaux+='+ '
              elsif produtovariacao.influenciapreco_id==3
                vsaux+='- '
              end
              # if produtovariacao.empromocao
              if produtovariacao.precopromocional and produtovariacao.precopromocional.to_f>0 and produtovariacao.preco.to_f>produtovariacao.precopromocional.to_f
                vsaux+=' de R$ '+produtovariacao.preco.real.to_s
                vsaux+=' por R$ '+produtovariacao.precopromocional.real.to_s
              else
                vsaux+='R$ '+produtovariacao.preco.real.to_s
              end
            end
            vprodutovariacao<<'"variacao_name":'+(produtovariacao.variacao.name+vsaux).to_json

            vvariacoessecundarias<<'{'+vprodutovariacao.join(',')+'}'
# produtovariacao.influenciapreco_id.to_i
# produtovariacao.precoatual.real
# produtovariacao.variacao.name
# produtovariacao.empromocao
# produtovariacao.preco.real
# produtovariacao.precopromocional.real


        end
        vvariacaoprincipal<<'"variacoessecundarias":['+vvariacoessecundarias.join(',')+']'

        vvariacoesprincipais<<'{'+vvariacaoprincipal.join(',')+'}'
      end

      vjson<<'"variacoesprincipais":'+"[#{vvariacoesprincipais.join(',')}]"      
    end

# #########################
    if @opcionaisprincipais
      vopcionaisprincipais=[]
      
      @opcionaisprincipais.each do |opcionalprincipal|
        vopcionalprincipal=[]
        vopcionalprincipal<<'"name":'+opcionalprincipal.name.to_json
        vopcionalprincipal<<'"id":'+opcionalprincipal.id.to_json

        vopcionaissecundarios=[]
        # @produto.produtos_variacoes.joins("inner join variacoes on variacoes.id=produtos_variacoes.variacao_id").where("variacoes.variacao_id = #{vopcionalprincipal.id} #{@variacoesprimeiraparteandsql}").order('produtos_variacoes.id').each do |produtovariacao|
        @produto.opcionais_produtos.joins("inner join opcionais on opcionais.id=opcionais_produtos.opcional_id").where("opcionais.opcional_id = #{opcionalprincipal.id}").order('opcionais_produtos.id').each do |produtoopcional|
            vprodutoopcional=[]
            vprodutoopcional<<'"opcional_id":'+produtoopcional.opcional_id.to_json
            vprodutoopcional<<'"influenciapreco_id":'+produtoopcional.influenciapreco_id.to_json
            # vprodutoopcional<<'"precoatual":'+produtoopcional.precoatual.to_json
            
            # vprodutoopcional<<'"empromocao":'+produtoopcional.empromocao.to_json
            vprodutoopcional<<'"preco":'+produtoopcional.preco.real.to_s.to_json
            # vprodutoopcional<<'"precopromocional":'+produtoopcional.precopromocional.real.to_s.to_json

            vsaux=''
            if produtoopcional.influenciapreco_id.to_i==0

            else
              if produtoopcional.influenciapreco_id==1
                vsaux+=' : '
              elsif produtoopcional.influenciapreco_id==2
                vsaux+=' + '
              elsif produtoopcional.influenciapreco_id==3
                vsaux+=' - '
              end
              vsaux+='R$ '+produtoopcional.preco.real.to_s
            end
            vprodutoopcional<<'"opcional_name":'+(produtoopcional.opcional.name+vsaux).to_json

            vopcionaissecundarios<<'{'+vprodutoopcional.join(',')+'}'

        end
        vopcionalprincipal<<'"opcionaissecundarios":['+vopcionaissecundarios.join(',')+']'

        vopcionaisprincipais<<'{'+vopcionalprincipal.join(',')+'}'
      end

      vjson<<'"opcionaisprincipais":'+"[#{vopcionaisprincipais.join(',')}]"   if !vopcionaisprincipais.blank?   
    end

    # vjson<<"'name':#{@produto.name.to_json}"
    # vjson<<"'description':#{@produto.description.to_json}"
    # vjson<<"'ofertapreco':#{@produto.ofertapreco.to_json}"
    # vjson<<"'ofertapor':#{@produto.ofertapor.to_json}"
    # vjson<<"'src':#{@produto.src.to_json}"

    # render json: @produto #.to_json
    if @produto.negocio
      @negocio=@produto.negocio



##################33
      # vjson<<'"negocio":'+"{#{vnegocio.join(',')}}"
      logger.debug 'negocioretornado'
      vnegocio=@negocio.to_json(:produto=>@produto)
      logger.debug vnegocio
      vjson<<'"negocio":'+"{#{vnegocio}}"
    end

    render text: "{#{vjson.join(',')}}"
  end

  # GET /produtos/new
  # GET /produtos/new.xml
  def new
    @negocio=Negocio.find_by_codigo params[:negocio_id]
    if fv_responsavel?(@negocio) 
      @produto = Produto.new
      @categorias = @negocio.categorias.select('DISTINCT categorias.id, categorias.nome, categorias.categoria_id')
      @variacoesprincipais = @negocio.variacoes.where("variacao_id is null")
      @variacoessecundarias = @negocio.variacoes.where("variacao_id is not null")
      @variacoes = @negocio.variacoes

      @opcionaisprincipais = @negocio.opcionais.where("opcional_id is null")
      @opcionaissecundarios = @negocio.opcionais.where("opcional_id is not null")
      @opcionais = @negocio.opcionais
    else
      flash[:error] = 'Não permitido.'
      redirect_to @negocio
    end
  end

  # GET /produtos/1/edit
  def edit
    @negocio=Negocio.find_by_codigo params[:negocio_id]
    if fv_responsavel?(@negocio)     
		  @produto = Produto.find(app_extrai_codigo_id(params[:id]))
      @categorias = @negocio.categorias.select('DISTINCT categorias.id, categorias.nome, categorias.categoria_id')
      @variacoesprincipais = @negocio.variacoes.where("variacao_id is null")
      @variacoessecundarias = @negocio.variacoes.where("variacao_id is not null")
      @variacoes = @negocio.variacoes

      @opcionaisprincipais = @negocio.opcionais.where("opcional_id is null")
      @opcionaissecundarios = @negocio.opcionais.where("opcional_id is not null")
      @opcionais = @negocio.opcionais
    else
      flash[:error] = 'Não permitido.'
      redirect_to @negocio
    end      
  end

  # POST /produtos
  # POST /produtos.xml
  def create
    logger.debug 'create.entrou'
    params[:produto]=params
    params[:produto]
    logger.debug 'produto'
    logger.debug params[:produto]
    logger.debug 'negocio'
    logger.debug params[:produto][:negocio]

    @negocio=Negocio.find_by_codigo params[:negocio][:codigo]
    if fv_responsavel?(@negocio)     
      #@produto = Produto.new(params[:produto])
      @produto = Produto.new(f_produto_profile_parameters)
      @produto.negocio=@negocio
      
      logger.debug 'picture'
      logger.debug params[:picture]
      signature = Paperclip.io_adapters.for(params[:picture])
      signature.original_filename = "something.png"

      # Attempt to submit image through Paperclip
      @produto.picture = signature
              
      if @produto.save
        logger.debug 'trata as variações'
        @produto.variacoes.clear
        logger.debug params[:produto][:negocio]
        logger.debug params[:produto][:negocio][:negociovariacoesprincipais]
        params[:produto][:negocio][:negociovariacoesprincipais].each do  |variacaoprincipal|
          logger.debug 'variacaoprincipal'
          logger.debug variacaoprincipal
          logger.debug variacaoprincipal[:variacoessecundarias]
          variacaoprincipal[:variacoessecundarias].each do |variacaosecundaria|
            logger.debug 'variacaosecundaria'
            logger.debug variacaosecundaria
            if variacaosecundaria["selecionado"]
              logger.debug 'selecionado'
              pv=ProdutosVariacoes.new
              pv.produto=@produto
              pv.variacao_id=variacaosecundaria["id"]
              pv.influenciapreco_id=variacaosecundaria["influenciapreco_id"]
              pv.preco=variacaosecundaria["preco"]
              pv.precopromocional=variacaosecundaria["precopromocional"]
              pv.save              
            end
          end
        end
        logger.debug 'trata os opcionais'
        @produto.opcionais.clear
        logger.debug params[:produto][:negocio]
        logger.debug params[:produto][:negocio][:negocioopcionaisprincipais]
        params[:produto][:negocio][:negocioopcionaisprincipais].each do  |opcionalprincipal|
          logger.debug 'opcionalprincipal'
          logger.debug opcionalprincipal
          logger.debug opcionalprincipal[:opcionaissecundarios]
          opcionalprincipal[:opcionaissecundarios].each do |opcionalsecundario|
            logger.debug 'opcionalsecundario'
            logger.debug opcionalsecundario
            if opcionalsecundario["selecionado"]
              logger.debug 'selecionado'
              pv=OpcionaisProdutos.new
              pv.produto=@produto
              pv.opcional_id=opcionalsecundario["id"]
              pv.influenciapreco_id=opcionalsecundario["influenciapreco_id"]
              pv.preco=opcionalsecundario["preco"]
              pv.precopromocional=opcionalsecundario["precopromocional"]
              pv.save              
            end
          end
        end

        render :json=>@produto.to_json
      else
        render :json =>{ :error => @produto.errors, status: :unprocessable_entity}
      end
    else
      render :json =>{ :error => 'Não permitido'}
    end
  end

  def recursive_symbolize_keys! hash
    hash.symbolize_keys!
    hash.values.select{|v| v.is_a? Hash}.each{|h| recursive_symbolize_keys!(h)}
  end

  # PUT /produtos/1
  # PUT /produtos/1.xml
  def update
    logger.debug 'entrou no update'
    logger.debug 'params'
    vparam=params
    logger.debug params
# params= JSON.parse(vparam, :symbolize_names => true) 


    logger.debug params

    vproduto=params
    # params={}
    params[:produto]=vproduto
    logger.debug 'produto'
    logger.debug params
    # logger.debug params[:produto]
    # logger.debug params[:produto][:name]



    @produto = Produto.find_by_codigo(params[:id])
    # @produto = Produto.find_by_codigo(params[:produto][:id])
    if true or (@produto and fv_responsavel?(@produto.negocio))
      
      if @produto.update_columns(f_produto_profile_parameters)
        logger.debug 'picture'
        logger.debug params[:picture]
        signature = Paperclip.io_adapters.for(params[:picture])
        signature.original_filename = "something.png"

        # Attempt to submit image through Paperclip
        @produto.picture = signature
        @produto.save

        logger.debug 'trata as variações'
        @produto.variacoes.clear
        logger.debug params[:produto][:negocio]
        logger.debug params[:produto][:negocio][:negociovariacoesprincipais]
        params[:produto][:negocio][:negociovariacoesprincipais].each do  |variacaoprincipal|
          logger.debug 'variacaoprincipal'
          logger.debug variacaoprincipal
          logger.debug variacaoprincipal[:variacoessecundarias]
          variacaoprincipal[:variacoessecundarias].each do |variacaosecundaria|
            logger.debug 'variacaosecundaria'
            logger.debug variacaosecundaria
            if variacaosecundaria["selecionado"]
              logger.debug 'selecionado'
              pv=ProdutosVariacoes.new
              pv.produto=@produto
              pv.variacao_id=variacaosecundaria["id"]
              pv.influenciapreco_id=variacaosecundaria["influenciapreco_id"]
              pv.preco=variacaosecundaria["preco"]
              pv.precopromocional=variacaosecundaria["precopromocional"]
              pv.save              
            end
          end
        end
        logger.debug 'trata os opcionais'
        @produto.opcionais.clear
        logger.debug params[:produto][:negocio]
        logger.debug params[:produto][:negocio][:negocioopcionaisprincipais]
        params[:produto][:negocio][:negocioopcionaisprincipais].each do  |opcionalprincipal|
          logger.debug 'opcionalprincipal'
          logger.debug opcionalprincipal
          logger.debug opcionalprincipal[:opcionaissecundarios]
          opcionalprincipal[:opcionaissecundarios].each do |opcionalsecundario|
            logger.debug 'opcionalsecundario'
            logger.debug opcionalsecundario
            if opcionalsecundario["selecionado"]
              logger.debug 'selecionado'
              pv=OpcionaisProdutos.new
              pv.produto=@produto
              pv.opcional_id=opcionalsecundario["id"]
              pv.influenciapreco_id=opcionalsecundario["influenciapreco_id"]
              pv.preco=opcionalsecundario["preco"]
              pv.precopromocional=opcionalsecundario["precopromocional"]
              pv.save              
            end
          end
        end

        render :json=>@produto.to_json
      else
        render :json =>{ :error => @produto.errors, status: :unprocessable_entity}
      end
    else
      render :json =>{ :error => 'Não permitido'}
    end
  end

  # DELETE /produtos/1
  # DELETE /produtos/1.xml
  def destroy
    @produto = Produto.find(params[:id])
    @produto.destroy

    respond_to do |format|
      #format.html { redirect_to(produtos_url) }
	  format.html { redirect_to :action => "index", :negocio_id => @produto.negocio_id }	  
      format.xml  { head :ok }
    end
  end

  # def adicionavariacao
  #   logger.debug 'entrou no adicionavariacao'
  #   logger.debug params
  #   @negocio=Negocio.find_by_codigo params[:negocio_id]
  #   if fv_responsavel?(@negocio)
  #     @produto = Produto.find(app_extrai_codigo_id(params[:id]))
  #     @produto.variacoes.clear
  #     params[:chkboxvariacao].each do |v_id|
  #       pv=ProdutosVariacoes.new
  #       pv.produto=@produto
  #       pv.variacao_id=v_id
  #       pv.influenciapreco_id=params['influencianoprecovariacao'+v_id.to_s]
  #       pv.preco=params['precovariacao'+v_id.to_s]
  #       pv.precopromocional=params['precopromocionalvariacao'+v_id.to_s]
  #       pv.save
  #     end

  #     @produto.save
  #     redirect_to edit_negocio_produto_path(@negocio.codigo, @produto.codigo)
  #   else
  #     flash[:error] = 'Não permitido.'
  #     redirect_to @produto.negocio
  #   end    
  # end

  # def adicionaopcional
  #   logger.debug 'entrou no adicionaopcional'
  #   logger.debug params
  #   @negocio=Negocio.find_by_codigo params[:negocio_id]
  #   if fv_responsavel?(@negocio)
  #     @produto = Produto.find(app_extrai_codigo_id(params[:id]))
  #     @produto.opcionais.clear
  #     if params[:chkboxopcional]
  #       params[:chkboxopcional].each do |o_id|
  #         po=OpcionaisProdutos.new
  #         po.produto=@produto
  #         po.opcional_id=o_id
  #         po.influenciapreco_id=params['influencianoprecoopcional'+o_id.to_s]
  #         po.preco=params['precoopcional'+o_id.to_s]
  #         po.precopromocional=params['precopromocionalopcional'+o_id.to_s]
  #         po.save
  #       end
  #     end

  #     @produto.save
  #     redirect_to edit_negocio_produto_path(@negocio.codigo, @produto.codigo)
  #   else
  #     flash[:error] = 'Não permitido.'
  #     redirect_to @produto.negocio
  #   end    
  # end  
private
  def f_produto_profile_parameters
    logger.debug 'f_produto_profile_parameters.entrou'
    # vparams=params
    logger.debug params
    logger.debug 'produto'
    # params={}
    
    # params[:produto]=vparams
    logger.debug params[:produto]
    params.require(:produto).permit(:disponivel, :name, :referencia, :exibirmensagemimgilust, :categoria_id, :tipomedida_id, :preco, :precopromocional, :fracaomeia, :especificacoes)
  end
end
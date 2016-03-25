class TransacaoClassificadosController < ApplicationController
  # GET /transacao_classificados
  # GET /transacao_classificados.xml
  def index
    @transacao_classificados = TransacaoClassificado.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @transacao_classificados }
    end
  end

  # GET /transacao_classificados/1
  # GET /transacao_classificados/1.xml
  def show
    @transacao_classificado = TransacaoClassificado.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @transacao_classificado }
    end
  end

  # GET /transacao_classificados/new
  # GET /transacao_classificados/new.xml
  def new
    @transacao_classificado = TransacaoClassificado.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @transacao_classificado }
    end
  end

  # GET /transacao_classificados/1/edit
  def edit
    @transacao_classificado = TransacaoClassificado.find(params[:id])
  end

  # POST /transacao_classificados
  # POST /transacao_classificados.xml
  def create
    @transacao_classificado = TransacaoClassificado.new(params[:transacao_classificado])

    respond_to do |format|
      if @transacao_classificado.save
        format.html { redirect_to(@transacao_classificado, :notice => 'TransacaoClassificado was successfully created.') }
        format.xml  { render :xml => @transacao_classificado, :status => :created, :location => @transacao_classificado }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @transacao_classificado.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /transacao_classificados/1
  # PUT /transacao_classificados/1.xml
  def update
    @transacao_classificado = TransacaoClassificado.find(params[:id])

    respond_to do |format|
      if @transacao_classificado.update_columns(params[:transacao_classificado])
        format.html { redirect_to(@transacao_classificado, :notice => 'TransacaoClassificado was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @transacao_classificado.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /transacao_classificados/1
  # DELETE /transacao_classificados/1.xml
  def destroy
    @transacao_classificado = TransacaoClassificado.find(params[:id])
    @transacao_classificado.destroy

    respond_to do |format|
      format.html { redirect_to(transacao_classificados_url) }
      format.xml  { head :ok }
    end
  end
end

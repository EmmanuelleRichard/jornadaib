class TokenValidationsController < DeviseTokenAuth::TokenValidationsController
  def validate_token
    logger.debug 'validate_token.entrou'
    # @resource will have been set by set_user_by_token concern
    if @resource
      logger.debug '@resource'
      logger.debug @resource

      render json: {
        # data: @resource.as_json(methods: :calculate_operating_thetan, only: [:id, :login, :telefone1, :nome, :datanascimento, :telefone1])
        # data: @resource.as_json(methods: :calculate_operating_thetan, only: [:id, :login, :telefone1, :name=>@resource.nome, :datanascimento])
        data:{
          :success => true, 
          :user => { id:@resource.id, login:@resource.login, telefone:@resource.telefone1, datanascimento:@resource.datanascimento.to_s_br, :email => @resource.email, :name=>@resource.nome, :sexo_id=>@resource.sexo_id  } 
        }
      }
    else
      render json: {
        success: false,
        errors: ["Invalid login credentials"]
      }, status: 401
    end
  end
end
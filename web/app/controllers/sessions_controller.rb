class SessionsController < DeviseTokenAuth::SessionsController
	def create
	    # Check
	    field = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys).first

	    @resource = nil
	    if field
	        q_value = resource_params[field]

	        if resource_class.case_insensitive_keys.include?(field)
	          q_value.downcase!
	        end

	        q = "#{field.to_s} = ? AND provider='email'"

	        if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
	          q = "BINARY " + q
	        end

	        @resource = resource_class.where(q, q_value).first
	    end

	    if @resource and valid_params?(field, q_value) and @resource.valid_password?(resource_params[:password]) and (!@resource.respond_to?(:active_for_authentication?) or @resource.active_for_authentication?)
	        # create client id
	        @client_id = SecureRandom.urlsafe_base64(nil, false)
	        @token     = SecureRandom.urlsafe_base64(nil, false)

	        @resource.tokens[@client_id] = {
				token: BCrypt::Password.create(@token),
				expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
	        }
	        @resource.save

	        sign_in(:user, @resource, store: false, bypass: false)

	        yield if block_given?

	        # render_create_success
		    render json: {
		        # data: @resource.as_json(methods: :calculate_operating_thetan, only: [:id, :login, :telefone1, :nome, :datanascimento, :telefone1])
		        # data: @resource.as_json(methods: :calculate_operating_thetan, only: [:id, :login, :telefone1, :name=>@resource.nome, :datanascimento])
		        data:{
		          :success => true, 
		          :user => { id:@resource.id, login:@resource.login, telefone:@resource.telefone1, datanascimento:@resource.datanascimento.to_s_br, :email => @resource.email, :name=>@resource.nome, :sexo_id=>@resource.sexo_id } 
		        }
		    }   
	    elsif @resource and not (!@resource.respond_to?(:active_for_authentication?) or @resource.active_for_authentication?)
			render json: {
				success: false,
				errors: [ I18n.t("devise_token_auth.sessions.not_confirmed", email: @resource.email) ]
			}, status: 401
	    else
		    render json: {
		    	errors: [I18n.t("devise_token_auth.sessions.bad_credentials")]
		    }, status: 401
	    end
	end
end
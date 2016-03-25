# class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
  	logger.warn 'facebook.entrou'
  	logger.warn request.env["omniauth.auth"]
  	logger.warn request.env["omniauth.auth"]["extra"]
  	logger.warn request.env["omniauth.auth"]["extra"]["raw_info"]
  	logger.warn request.env["omniauth.auth"]["extra"]["raw_info"]["birthday"]
  	logger.warn request.env["omniauth.auth"]["extra"]["raw_info"]["email"]
  	logger.warn request.env["omniauth.auth"]["extra"]["raw_info"]["name"]
  	logger.warn request.env["omniauth.auth"]["uid"]
  	logger.warn 'credentials'
  	logger.warn request.env["omniauth.auth"]["credentials"]
  	logger.warn request.env["omniauth.auth"]["credentials"]["expires_at"]
  	logger.warn request.env["omniauth.auth"]["credentials"]["token"]

  	vfacebookexpires_at=request.env["omniauth.auth"]["credentials"]["expires_at"].to_i
  	logger.warn vfacebookexpires_at
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
    	logger.warn 'user persistido'
    	sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
    	set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    elsif !request.env["omniauth.auth"]["extra"]["raw_info"]["email"].blank?
      	logger.warn 'user nao persistido'
      	@user=User.find_by_email request.env["omniauth.auth"]["extra"]["raw_info"]["email"]
      	if @user
      		@user.update_columns :uid=>request.env["omniauth.auth"]["uid"], :provider=>request.env["omniauth.auth"]["provider"], :facebook_expires_at=>Time.at(vfacebookexpires_at), :facebook_token=>request.env["omniauth.auth"]["credentials"]["token"]
      		sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      	else
      		session["devise.facebook_data"] = request.env["omniauth.auth"]
      		# redirect_to new_user_registration_url
          @user=User.new
          @user.tipousuario_id=3 if @user.admin? or !params[:tipousuario_id]
          logger.debug 'impede que o usuario tente cadastrar-se como admin'
          logger.debug '3 = partnerjunior'

          #@user.cpf=nil if @user.tipoperfilusuario==:usuario

          vlogin=request.env["omniauth.auth"]["extra"]["raw_info"]["name"].delete(' ').parameterize
          vquantlogin=User.where(:login=>vlogin).count
          vlogin+=vquantlogin.to_s if vquantlogin>0

          @user.login = vlogin.downcase.delete '@./?'  #Remove caracteres que podem causar problema    

          @user.codigo=@user.login
          @user.nome=request.env["omniauth.auth"]["extra"]["raw_info"]["name"]
          @user.status=true

          @user.email=request.env["omniauth.auth"]["extra"]["raw_info"]["email"]
          @user.password=request.env["omniauth.auth"]["extra"]["raw_info"]["email"]
          
          @patrocinador=User.where(:login=>'richard').first.partner
          
          @user.patrocinador_id=@patrocinador.id
          @user.tipopatrocinador_id=@patrocinador.tipo  
          @user.confirmed_at=Time.now
          @user.uid=request.env["omniauth.auth"]["uid"]
          @user.provider=request.env["omniauth.auth"]["provider"]
          @user.facebook_expires_at=Time.at(vfacebookexpires_at)
          @user.facebook_token=request.env["omniauth.auth"]["credentials"]["token"]

          @user.save            

          sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      	end
    end
  end
end
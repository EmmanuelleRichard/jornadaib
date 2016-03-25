Jornadaib::Application.routes.draw do
  resources :trabalhos
	mount_devise_token_auth_for 'User', at: 'auth', controllers: {
		# registrations: 'user/create'
		registrations: 		'users' ,
		# sessions:           'devisetokens'
		sessions:           'sessions',
		token_validations:  'token_validations'
	}

	resources :tipousuarios
	resources :sexos
	root :to => "application#index"
	
	get "/views/:name", to: "views#serve", constraints: { name: /[\/\w\.]+/ }

	resources :users do

		member do
			# get :mural
			get :editpassword
			post :editpasswordconfirma

		end
		collection do
			get :validalogin
			get :validacpf
			get :validacnpj
			get :validaemail
		end		
		# resources :fotousers
	end	  

	
end

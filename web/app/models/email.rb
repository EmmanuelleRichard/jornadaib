class Email < ActionMailer::Base
 logger.info "classe email"
 #Email padrao
 def padrao(options = {})
	logger.info "chamou padrao"
	 email = Principal.emailcontato	#{}"contato@soesse.com"
	 recipients options[:para] || ""
	 from options[:from] || email
	 subject options[:assunto] || ""
	 reply_to options[:responder] || email
	 body :corpo => options[:corpo] || email
 end 
end

module Normalizepicturefilename
	def self.included(base)
		base.send :before_save, :normalize_filename
	end
	
# This class does normalization of any string passed into `normalize`.
# With help of `ActiveSupport#parameterize` all special characters that
# don't conform URL standard will be replaced by dashes.
# String passed will be also downcases.
#
# === Example
#
# Filename.normalize("Qwe%%ty 1.jPg")
# => "qwe-ty-1.jpg"
#
	class Filename

		def self.normalize(name)
			#logger.debug 'entrou no normalize'
			self.new(name).normalize
		end
		def initialize(name)
			@name = name
		end
		def normalize
			"#{file_name}#{ext_name}"
		end
		private
		def file_name
			# File.basename(@name, File.extname(@name)).downcase.parameterize if @name
			DateTime.now.strftime("%Y%m%d%H%M%S") if @name
		end
		def ext_name
			File.extname(@name).downcase if @name
		end
	end
	
	private

	def normalize_filename
		logger.debug 'entrou no normalize_filename'
		if defined? self.picture
			vpicture=self.picture
		end
		#logger.debug vpicture.attachment.instance_read(:file_name)

		if vpicture.instance_read(:file_name)
			logger.debug 'leu'
			logger.debug vpicture.instance_read(:file_name)
			if vpicture.instance_read(:file_name).split('.')[0].to_i==0	#Testa se numero
				vpicture.instance_write(
					:file_name,
					Filename.normalize(vpicture.instance_read(:file_name))
				)
			end
		else
			logger.debug 'vai limpar'
			vpicture.clear
		end
=begin
			logger.debug 'vai normalizar'
			logger.debug name
			logger.debug attachment
			logger.debug attachment.instance_read(:file_name)
			
			if attachment.instance_read(:file_name)
				if attachment.instance_read(:file_name).split('.')[0].to_i==0	#Testa se numero
					logger.debug 'vai normalizar.1'
					attachment.instance_write(
						:file_name,
						Filename.normalize(attachment.instance_read(:file_name))
					)
				end
			else
				logger.debug 'vai limpar'
				attachment.clear
			end
		end
=end
	end
	
end


# original_filename = attachment.instance_read(:file_name)
      # extension = File.extname(original_filename)
      # date_format = @attachment.options[:date_format] ||
                    # "%Y%m%d%H%M%S"
      # timestamp = DateTime.now.strftime(date_format)
      # new_filename = "#{timestamp}-#{original_filename}"
      # @attachment.instance_write(:file_name, new_filename)

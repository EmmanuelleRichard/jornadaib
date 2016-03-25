desc "Copy paperclip data"
task :copy_paperclip_data => :environment do
  @negocios = Negocio.all
  @negocios.each do |negocio|
    unless negocio.image_file_name.blank?
      filename = Rails.root.join('public', 'system', 'pictures', negocio.id.to_s, 'original', negocio.image_file_name)
 
      if File.exists? filename
        image = File.new filename
        negocio.image = image
        negocio.save
 
        image.close
      end
    end
  end
end
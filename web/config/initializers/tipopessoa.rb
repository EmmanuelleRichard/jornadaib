class Tipopessoa
   attr_reader :name, :codigo
#attr_reader :codigo

   def initialize(name, codigo)
      @name = name
      @codigo = codigo
   end
#   def initialize(codigo)
#      @codigo = codigo
#   end

   @@fisica = Tipopessoa.new('Pessoa Fisica', 1)
   @@juridica = Tipopessoa.new('Pessoa Juridica', 2)

   def self.fisica; @@fisica; end
   def self.juridica; @@juridica; end

   def self.find(codigo)
		case codigo
			when 1
				return @@fisica
			when 2
				return @@juridica
		end
   end
end
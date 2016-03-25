class Tipovinculoempresa
   attr_reader :name, :codigo
#attr_reader :codigo

   def initialize(name, codigo)
      @name = name
      @codigo = codigo
   end
#   def initialize(codigo)
#      @codigo = codigo
#   end

   @@administrador = Tipovinculoempresa.new('Administrador', 1)
   @@usuario = Tipovinculoempresa.new('Usuario', 2)
   @@vinculado = Tipovinculoempresa.new('Vinculado', 2)

   def self.administrador; @@administrador; end
   def self.usuario; @@usuario; end
   def self.vinculado; @@vinculado; end

   def self.find(codigo)
		case codigo
			when 1
				return @@administrador
			when 2
				return @@usuario
			when 3
				return @@vinculado
		end
   end
end
# =====================================================================
# tokenizador.rb
# =====================================================================
# Prepara a expressão para os parsers.
# Remove espaços e valida se todos os caracteres pertencem ao alfabeto
# da gramática: dígitos, operadores e parênteses.
# =====================================================================

class Token
  attr_reader :type, :value

  def initialize(type, value)
    @type = type
    @value = value
  end

  def to_s
    "#{type}(#{value})"
  end
end

module Tokenizador
  def self.preparar(expressao)
    entrada = expressao.gsub(' ', '')

    entrada.each_char.with_index do |ch, i|
      unless ch.match?(/[0-9+\-*\/\^()]/)
        raise "Caractere inválido '#{ch}' na posição #{i}"
      end
    end

    entrada
  end

  def self.tokenizar_cyk(expressao)
    entrada = expressao.gsub(/\s+/, '')
    
    # \d+ pega um ou mais números juntos. O resto pega operadores.
    tokens_str = entrada.scan(/\d+|[+\-*\/\^()]/)
    
    tokens_str.map do |t|
      if t.match?(/^\d+$/)
        Token.new(:NUMBER, t.to_i)
      else
        Token.new(:OP, t) # Operadores e Parênteses
      end
    end
  end
end
# =====================================================================
# tokenizador.rb
# =====================================================================
# Prepara a expressão para os parsers.
# Remove espaços e valida se todos os caracteres pertencem ao alfabeto
# da gramática: dígitos, operadores e parênteses.
# =====================================================================

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
    entrada = preparar(expressao)
    
    #d+ pega um ou mais dos numeros juntos, | (ou) o operador ou parenteses individual
    tokens = entrada.scan(/\d+|[+\-*\/\^()]/)
    tokens


end
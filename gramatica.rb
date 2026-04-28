# Uma regra tem:
# - lado esquerdo: normalmente um símbolo não-terminal
# - lado direito: sequência de símbolos que esse não-terminal pode gerar
# Exemplo:
# S -> A B
# esquerda = "S"
# direita = ["A", "B"]
class Regra
  attr_reader :esquerda, :direita
  # Construtor da classe Regra.
  def initialize(esquerda, direita)
    @esquerda = esquerda
    @direita = direita
  end

  # Converte a regra para texto.
  # Exemplo: esquerda = "S" direita = ["A", "B"]
  # Resultado:
  # S -> A B
  def to_s
    @esquerda + ' -> ' + @direita.join(' ')
  end
end

# Classe que representa a gramática completa.
# - todas as regras de produção
# - os símbolos iniciais da gramática
class Gramatica
  attr_reader :regras, :simbolos_iniciais
  #Construtor da classe Gramatica.
  def initialize(regras, simbolos_iniciais)
    @regras = regras
    @simbolos_iniciais = simbolos_iniciais
  end
end
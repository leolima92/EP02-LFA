require 'set'

# Classe que representa um estado do algoritmo Earley.
# Um estado guarda:
# - a regra gramatical
# - a posição do ponto dentro da regra
# - o índice onde essa regra começou
# - um comentário explicando como esse estado foi criado
class Estado
  attr_accessor :regra, :ponto, :inicio, :comentario

  def initialize(regra, ponto, inicio, comentario = '')
    @regra = regra
    @ponto = ponto
    @inicio = inicio
    @comentario = comentario
  end

  # Verifica se o estado está completo.
  # Um estado está completo quando o ponto chegou ao fim da parte direita da regra.
  #
  # Exemplo:
  # A -> a b •
  #
  # Nesse caso, o ponto está no final, então o estado está completo.
  def completo?
    ponto == regra.direita.length
  end

  # Retorna o próximo símbolo depois do ponto.
  #
  # Exemplo:
  # A -> a • b
  #
  # O próximo símbolo seria "b".
  def next_symbol
    regra.direita[ponto]
  end

  # Avança o ponto uma posição para a direita.
  # Esse método é usado normalmente na etapa de Scan do algoritmo Earley.
  #
  # Exemplo:
  # Antes: A -> a • b
  # Depois: A -> a b •
  def advance(k, regra_anterior)
    Estado.new(
      regra,
      ponto + 1,
      inicio,
      "Scan de S(#{k})(#{regra_anterior})"
    )
  end

  # Também avança o ponto uma posição para a direita,
  # mas é usado na etapa de Complete do algoritmo Earley.
  #
  # O Complete acontece quando uma regra foi reconhecida completamente
  # e isso permite avançar outra regra que estava esperando por ela.
  def complete(k, regra1, regra2)
    Estado.new(
      regra,
      ponto + 1,
      inicio,
      "Completo de #{regra1} e S(#{k})(#{regra2})"
    )
  end

  # Define quando dois estados são considerados iguais.
  # Aqui, dois estados são iguais se tiverem:
  # - a mesma regra
  # - a mesma posição do ponto
  # - o mesmo início
  def ==(other)
    regra.to_s == other.regra.to_s &&
      ponto == other.ponto &&
      inicio == other.inicio
  end

  # Método usado pelo Set para comparar igualdade entre objetos.
  # Ele precisa estar coerente com o método ==.
  def eql?(other)
    regra.to_s == other.regra.to_s &&
      ponto == other.ponto &&
      inicio == other.inicio
  end

  # Gera um código hash para o estado.
  # Isso é necessário para que o Set consiga identificar estados repetidos.
  def hash
    [regra.to_s, ponto, inicio].hash
  end

  # Converte o estado para texto.
  # Insere o símbolo "•" na posição atual do ponto.
  #
  # Exemplo:
  # Se a regra for A -> a b
  # e ponto = 1,
  # o resultado será:
  # A -> a • b
  def to_s
    partes = @regra.direita.dup
    partes.insert(ponto, '•')
    "#{@regra.esquerda} -> #{partes.join(' ')}"
  end
end


# No algoritmo Earley, temos conjuntos:
# S(0), S(1), S(2), ...
#
# Cada S(i) guarda os estados possíveis naquele ponto da entrada.
class S
  attr_reader :estados, :estados_visitados

  # Construtor da classe S.
  # index: número do conjunto, por exemplo S(0), S(1), S(2)
  # entrada: palavra ou sequência de símbolos analisada
  def initialize(index, entrada)
    @index = index

    # Guarda todos os estados desse conjunto.
    @estados = Set.new

    # Guarda os estados que já foram processados.
    @estados_visitados = Set.new

    # Guarda a entrada que está sendo analisada.
    @entrada = entrada
  end

  # Adiciona um estado ao conjunto S.
  # O estado só é adicionado se ainda não tiver sido visitado.
  # Isso evita processamento repetido.
  def <<(element)
    estados << element unless estados_visitados.include?(element)
  end

  # Pega um estado ainda não visitado para processar.
  # Primeiro calcula:
  # estados - estados_visitados
  # Ou seja, pega apenas os estados que ainda não foram processados.
  def take!
    taken = (estados - estados_visitados).take(1)

    # Marca o estado como visitado.
    estados_visitados << taken[0]

    # Retorna o estado escolhido.
    taken[0]
  end

  # Verifica se não existem mais estados pendentes de processamento.
  # Se todos os estados já foram visitados, retorna true.
  def empty?
    (estados - estados_visitados).empty?
  end

  # Converte o conjunto S para texto.
  # Mostra todos os estados dentro de S(index),
  # junto com o início e o comentário de cada estado.
  def to_s
    linhas = estados.map do |e|
      "  #{e}  (inicio: #{e.inicio}) #{e.comentario}"
    end

    "S(#{@index}):\n#{linhas.join("\n")}"
  end
end
# O parser de Earley trabalha com a gramática livre de contexto na sua
# forma original, ou seja, sem necessidade de converter para Forma
# Normal de Chomsky.
#
# Fluxo de execução:
#   1. Define a gramática sem forma normal.
#   2. Recebe uma expressão matemática.
#   3. Remove espaços e valida os caracteres com o Tokenizador.
#   4. Executa o parser de Earley.
#   5. Informa se a expressão foi aceita ou rejeitada.
#   6. Caso seja aceita, monta a árvore de saída da expressão.

require_relative 'earley'
require_relative 'gramatica'
require_relative 'Tokenizador'
#require_relative 'construtor_arvore'

# Define a gramática usada pelo parser de Earley.
# A ordem dos não-terminais controla a precedência:
#
# E -> soma/subtração
# T -> multiplicação/divisão
# P -> potência
# U -> negativo unário
# F -> parênteses/número
# N -> número com vários dígitos
def criar_regras
 [
    # Soma e subtração — associatividade à esquerda
    Regra.new('E', %w[E + T]),
    Regra.new('E', %w[E - T]),
    Regra.new('E', %w[T]),

    # Multiplicação e divisão — associatividade à esquerda
    Regra.new('T', %w[T * P]),
    Regra.new('T', %w[T / P]),
    Regra.new('T', %w[P]),

    # Potência — associatividade à direita
    Regra.new('P', %w[U ^ P]),
    Regra.new('P', %w[U]),

    # Negativo unário
    Regra.new('U', %w[- U]),
    Regra.new('U', %w[F]),

    # Parênteses e números
    Regra.new('F', %w[( E )]),
    Regra.new('F', %w[N]),

    # Número com um ou mais dígitos
    Regra.new('N', %w[D N]),
    Regra.new('N', %w[D]),

    # Dígitos
    Regra.new('D', %w[0]),
    Regra.new('D', %w[1]),
    Regra.new('D', %w[2]),
    Regra.new('D', %w[3]),
    Regra.new('D', %w[4]),
    Regra.new('D', %w[5]),
    Regra.new('D', %w[6]),
    Regra.new('D', %w[7]),
    Regra.new('D', %w[8]),
    Regra.new('D', %w[9])
  ]
end

# Prepara a expressão, executa o parser e mostra o resultado.
def reconhecer(expressao)
    entrada = Tokenizador.preparar(expressao)
    gramatica = Gramatica.new(criar_regras, 'E')
    parser = EarleyParser.new(gramatica)

    aceita = parser.parse(entrada)

    puts "Expressão: #{expressao}"
    if aceita
        puts "Status: ACEITA"
    else
        puts "Status: REJEITADA"
    end
    puts ""
end

# Testes válidos
puts " EARLEY — EXPRESSÕES VÁLIDAS"

reconhecer("(1 + 4) * 2^4")
reconhecer("7 / ( 1 - 3 )")
reconhecer("9^(1 * 6 / 2 + 4)")
reconhecer("2 + 4 ^ -4 / 4")
reconhecer("9^(1 * -2 + 3) - 3 / ( 6 + 3 )")

# Testes inválidos
puts " EARLEY — EXPRESSÕES INVÁLIDAS"

reconhecer("^ 2 + 4")
reconhecer("9 * 2 +")
reconhecer("9 + + 3")
reconhecer("( ) * 3")
reconhecer("( 3 + 3")
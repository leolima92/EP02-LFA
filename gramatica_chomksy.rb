# define a gramatica na forma normal de chomsky
# regras permitidas: A -> BC (Duas Variáveis) ou A -> a (Um Terminal)

require_relative 'gramatica'

def criar_regras_chomsky
  regras = []

  #terminais isolados
  regras << Regra.new('S_soma', ['+'])
  regras << Regra.new('S_subtracao', ['-'])
  regras << Regra.new('S_multiplicacao', ['*'])
  regras << Regra.new('S_divisao', ['/'])
  regras << Regra.new('S_potencia', ['^'])
  regras << Regra.new('S_abre_paren', ['('])
  regras << Regra.new('S_fecha_paren', [')'])

  #variaveis novas
  regras << Regra.new('X_soma', ['S_soma', 'T'])                   # representa: + T
  regras << Regra.new('X_subtracao', ['S_subtracao', 'T'])         # representa: - T
  regras << Regra.new('X_multiplicacao', ['S_multiplicacao', 'P']) # representa: * P
  regras << Regra.new('X_divisao', ['S_divisao', 'P'])             # representa: / P
  regras << Regra.new('X_potencia', ['S_potencia', 'P'])           # representa: ^ P
  regras << Regra.new('X_fecha_paren', ['E', 'S_fecha_paren'])     # representa: E )

  # eliminação das regras unitárias
  # num = numero, pro parser reconhecer o token 'NUM' como um numero válido

  # fator (F) - parenteses e numeros
  regras << Regra.new('F', ['S_abre_paren', 'X_fecha_paren']) # F -> ( E )
  regras << Regra.new('F', ['NUM'])                           # F -> numero

  # unario (U) - negativo unario
  regras << Regra.new('U', ['S_subtracao', 'U'])              # U -> - U
  # herança de F:
  regras << Regra.new('U', ['S_abre_paren', 'X_fecha_paren']) 
  regras << Regra.new('U', ['NUM'])

  # potencia (P)
  regras << Regra.new('P', ['U', 'X_potencia'])               # P -> U ^ P
  # herança de U:
  regras << Regra.new('P', ['S_subtracao', 'U'])
  regras << Regra.new('P', ['S_abre_paren', 'X_fecha_paren'])
  regras << Regra.new('P', ['NUM'])

  # termo (T) - multiplicação e divisão
  regras << Regra.new('T', ['T', 'X_multiplicacao'])          # T -> T * P
  regras << Regra.new('T', ['T', 'X_divisao'])                # T -> T / P
  # herança de P:
  regras << Regra.new('T', ['U', 'X_potencia'])
  regras << Regra.new('T', ['S_subtracao', 'U'])
  regras << Regra.new('T', ['S_abre_paren', 'X_fecha_paren'])
  regras << Regra.new('T', ['NUM'])

  # expressao (E) - inicial, soma e subtração
  regras << Regra.new('E', ['E', 'X_soma'])                   # E -> E + T
  regras << Regra.new('E', ['E', 'X_subtracao'])              # E -> E - T
  # herança de T:
  regras << Regra.new('E', ['T', 'X_multiplicacao'])
  regras << Regra.new('E', ['T', 'X_divisao'])
  regras << Regra.new('E', ['U', 'X_potencia'])
  regras << Regra.new('E', ['S_subtracao', 'U'])
  regras << Regra.new('E', ['S_abre_paren', 'X_fecha_paren'])
  regras << Regra.new('E', ['NUM'])

  regras
end
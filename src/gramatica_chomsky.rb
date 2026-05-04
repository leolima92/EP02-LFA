require_relative 'gramatica'

def criar_gramatica_chomsky
  regras = []

  # Terminais isolados
  regras << Regra.new('S_soma', ['+'])
  regras << Regra.new('S_subtracao', ['-'])
  regras << Regra.new('S_multiplicacao', ['*'])
  regras << Regra.new('S_divisao', ['/'])
  regras << Regra.new('S_potencia', ['^'])
  regras << Regra.new('S_abre_paren', ['('])
  regras << Regra.new('S_fecha_paren', [')'])

  # Variáveis novas
  regras << Regra.new('X_soma', ['S_soma', 'T'])                   # + T
  regras << Regra.new('X_subtracao', ['S_subtracao', 'T'])         # - T
  regras << Regra.new('X_multiplicacao', ['S_multiplicacao', 'P']) # * P
  regras << Regra.new('X_divisao', ['S_divisao', 'P'])             # / P
  regras << Regra.new('X_potencia', ['S_potencia', 'P'])           # ^ P
  regras << Regra.new('X_fecha_paren', ['E', 'S_fecha_paren'])     # E )

  # Fator (F)
  regras << Regra.new('F', ['S_abre_paren', 'X_fecha_paren'])      # ( E )
  regras << Regra.new('F', ['NUM'])

  # Unário (U)
  regras << Regra.new('U', ['S_subtracao', 'U'])                   # - U
  regras << Regra.new('U', ['S_abre_paren', 'X_fecha_paren'])
  regras << Regra.new('U', ['NUM'])

  # Potência (P)
  regras << Regra.new('P', ['U', 'X_potencia'])                    # U ^ P
  regras << Regra.new('P', ['S_subtracao', 'U'])
  regras << Regra.new('P', ['S_abre_paren', 'X_fecha_paren'])
  regras << Regra.new('P', ['NUM'])

  # Termo (T)
  regras << Regra.new('T', ['T', 'X_multiplicacao'])               # T * P
  regras << Regra.new('T', ['T', 'X_divisao'])                     # T / P
  regras << Regra.new('T', ['U', 'X_potencia'])
  regras << Regra.new('T', ['S_subtracao', 'U'])
  regras << Regra.new('T', ['S_abre_paren', 'X_fecha_paren'])
  regras << Regra.new('T', ['NUM'])

  # Expressão (E) - Símbolo Inicial
  regras << Regra.new('E', ['E', 'X_soma'])                        # E + T
  regras << Regra.new('E', ['E', 'X_subtracao'])                   # E - T
  regras << Regra.new('E', ['T', 'X_multiplicacao'])
  regras << Regra.new('E', ['T', 'X_divisao'])
  regras << Regra.new('E', ['U', 'X_potencia'])
  regras << Regra.new('E', ['S_subtracao', 'U'])
  regras << Regra.new('E', ['S_abre_paren', 'X_fecha_paren'])
  regras << Regra.new('E', ['NUM'])

  Gramatica.new(regras, 'E')
end
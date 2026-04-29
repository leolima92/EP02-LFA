require 'set'
require_relative 'gramatica'
require_relative 'estado'

class EarleyParser
  attr_reader :gramatica

  def initialize(gramatica)
    @gramatica = gramatica
    # Adiciona regra aumentada S' -> simbolo_inicial
    @gramatica.regras.unshift(Regra.new("S'", [gramatica.simbolo_inicial]))
  end

  def parse(entrada)
    @tabela = Array.new(entrada.length + 1) { |i| S.new(i, entrada) }

    # Seed: estado inicial S' -> • E
    @tabela[0] << Estado.new(@gramatica.regras[0], 0, 0, "Regra inicial")

    (0..entrada.size).each do |index|
      until @tabela[index].empty?
        estado = @tabela[index].take!

        if estado.completo?
          complete(estado, index)
        elsif estado.next_symbol == entrada[index]
          scan(estado, index)
        else
          predict(estado, index)
        end
      end
    end

    final_is_valid?(@tabela[entrada.length])
  end

  private

  def final_is_valid?(estado)
    estado.estados.select { |e| e.regra.esquerda == "S'" && e.completo? && e.inicio == 0 }.any?
  end

  # Expande regras cujo lado esquerdo casa com o próximo símbolo esperado
  def predict(estado, index)
    @gramatica.regras.each do |regra|
      if regra.esquerda == estado.next_symbol
        @tabela[index] << Estado.new(regra, 0, index, "Predito de #{estado}")
      end
    end
  end

  # Terminal casa com caractere atual — avança o ponto pro próximo conjunto
  def scan(estado, index)
    @tabela[index + 1] << estado.advance(index, estado)
  end

  # Estado completo — propaga pra quem estava esperando esse não-terminal
  def complete(estado, index)
    @tabela[estado.inicio].estados.each do |ec|
      if ec.next_symbol == estado.regra.esquerda
        @tabela[index] << ec.complete(index - 1, estado, ec)
      end
    end
  end
end
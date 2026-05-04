
require_relative "cyk"
require_relative "gramatica_chomsky"

gramatica = criar_gramatica_chomsky()
parser = CYKParser.new(gramatica)

testes = [
  "4+5*2",
  "(1 + 4) * 2^4",
  "9^(1 * 6 / 2 + 4)",
  "^ 2 + 4"
]

puts "========= PARSER CYK ========="
testes.each do |entrada|
  puts "Expressão: #{entrada}"
  parser.parse(entrada)

  if parser.aceito?
    puts "Status: Aceito"
    puts "Saída: #{parser.gerar_arvore.inspect}"
  else
    puts "Status: Não aceito"
  end
  puts "------------------------------"
end
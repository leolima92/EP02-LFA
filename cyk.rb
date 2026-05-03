
require_relative 'gramatica'
require_relative 'tokenizador'

class CYKParser
  attr_reader :tabela, :gramatica, :tokens

  def initialize(gramatica)
    @gramatica = gramatica
  end

  #executa o algoritmo cyk
  def parse(entrada)
    @tokens = Tokenizador.tokenizar_cyk(entrada)
    n = @tokens.length

    #cria a matriz/tabela do cyk
    @tabela = Array.new(n) { Array.new(n) { [] } }

    #preenche a parte nao utilizada com bolinha preta
    @tabela.each_with_index do |coluna, index|
      (0..index-1).each do |i|
        @tabela[index][i] << "⚫️"
      end
    end
    
    adiciona_terminais()
    adiciona_nao_terminais()

    tabela
  end

  def aceito?
    return false if @tokens.empty?
    #checa se o simoblo innicial esta no topo 
    tabela[0][-1].any? { |no| no.is_a?(Hash) && no[:variavel] == gramatica.simbolo_inicial }
  end

  def gerar_arvore
    #procura no raiz (E) na celula final de sucesso
    no_raiz = tabela[0][-1].find { |no| no.is_a?(Hash) && no[:variavel] == gramatica.simbolo_inicial }
    extrair_ast(no_raiz)
  end

  #(A-> a)
  def adiciona_terminais()
    @tokens.each_with_index do |token, i| 
      @gramatica.regras.each do |regra|
        #se a regra produz esse token
        if terminal?(regra.direita, token)
          #salva na diagonal principal o simbolo da variavel e o valor do token
          tabela[i][i] << { variavel: regra.esquerda, valor: token.value, filhos: nil }
        end
      end
    end
  end

  #(A-> BC)
  def adiciona_nao_terminais()
    n = @tokens.length
    
    for largura in 1...n #controla a largura da subpalavra 
      for inicio in 0...(n - largura) #controla o inicio da subpalavra
        fim = inicio + largura
        (inicio...fim).each do |meio| # divisao da subpalavra em 2
          @gramatica.regras.each do |regra| #teste das regras da gramatica
            nos_encontrados = match_de_nao_terminais?(inicio, meio, fim, regra)
            
            if nos_encontrados #checa se encontrou um par que correspondem a regra, adicionando o simbolo da variavel e os filhos encontrados
              tabela[inicio][fim] << { variavel: regra.esquerda, valor: nil, filhos: nos_encontrados }
            end
          end
        end
      end
    end
  end

  #func auxiliar para checar se as partes formam A->BC
  def match_de_nao_terminais?(inicio, meio, fim, regra)
    return nil if regra.direita.length < 2 

    primeira_direita = regra.direita[0]
    segunda_direita = regra.direita[1]

    #procura o b na celula esquerda
    no_esq = tabela[inicio][meio].find { |no| no.is_a?(Hash) && no[:variavel] == primeira_direita }
    #procura o c na celula de baixo/direita
    no_dir = tabela[meio + 1][fim].find { |no| no.is_a?(Hash) && no[:variavel] == segunda_direita }

    if no_esq && no_dir #se achou os dois retorna para conectar como filhos de A
      return [no_esq, no_dir]
    end
    nil
  end

  def terminal?(direita, token)
    return false unless direita.length == 1
    
    if direita[0] == 'NUM' && token.type == :NUMBER
      return true
    elsif direita[0] == token.value.to_s
      return true
    end
    false
  end

  def extrair_ast(no)
    return nil if no.nil?

    if no[:filhos].nil?
      return no[:valor].to_i if no[:valor].to_s.match?(/^\d+$/)
      return no[:valor]
    end

    esq = no[:filhos][0]
    dir = no[:filhos][1]

    case dir[:variavel]
    when 'X_soma'
      return ["soma", extrair_ast(esq), extrair_ast(dir[:filhos][1])]
    when 'X_subtracao'
      return ["diferenca", extrair_ast(esq), extrair_ast(dir[:filhos][1])]
    when 'X_multiplicacao'
      return ["multiplicacao", extrair_ast(esq), extrair_ast(dir[:filhos][1])]
    when 'X_divisao'
      return ["divisao", extrair_ast(esq), extrair_ast(dir[:filhos][1])]
    when 'X_potencia'
      return ["potencia", extrair_ast(esq), extrair_ast(dir[:filhos][1])]
    when 'X_fecha_paren' # para F -> ( E )
      return extrair_ast(dir[:filhos][0])
    end

    if esq[:variavel] == 'S_subtracao'
      return ["negativacao", extrair_ast(dir)]
    end

    nil
  end
end
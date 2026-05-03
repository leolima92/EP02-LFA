require_relative 'gramatica'
require_relative 'tokenizador'

class CYKParser
  attr_reader :tabela, :gramatica, :tokens

  # Inicializa o parser recebendo a gramática (já na Forma Normal de Chomsky)
  def initialize(gramatica)
    @gramatica = gramatica
  end

  # O método principal que executa o algoritmo CYK
  def parse(entrada)
    # 1. Transforma a string de entrada em uma lista de objetos Token
    @tokens = Tokenizador.tokenizar_cyk(entrada)
    n = @tokens.length

    # 2. Cria a matriz NxN do CYK (tabela de programação dinâmica)
    # Inicialmente, cada célula é um array vazio []
    @tabela = Array.new(n) { Array.new(n) { [] } }

    # 3. Preenche a parte "inútil" da matriz (abaixo da diagonal principal) com a bolinha preta.
    # O CYK só usa a diagonal principal e a parte de cima/direita dela.
    @tabela.each_with_index do |coluna, index|
      (0..index-1).each do |i|
        @tabela[index][i] << "⚫️"
      end
    end
    
    # 4. Passo 1 do CYK: Preencher a diagonal principal com os símbolos terminais (ex: números e operadores)
    adiciona_terminais()
    
    # 5. Passo 2 do CYK: Subir na tabela combinando as células para resolver regras do tipo A -> BC
    adiciona_nao_terminais()

    # Retorna a tabela preenchida
    tabela
  end

  # Verifica se a expressão pertence à linguagem
  def aceito?
    # Se não tiver tokens, já rejeita
    return false if @tokens.empty?
    
    # O CYK diz que uma palavra é aceita se o símbolo inicial (ex: 'E') 
    # estiver na célula do extremo superior direito: linha 0, última coluna (-1).
    tabela[0][-1].any? { |no| no.is_a?(Hash) && no[:variavel] == gramatica.simbolo_inicial }
  end

  # Inicia a extração da Árvore Sintática Abstrata (AST)
  def gerar_arvore
    # Procura o nó raiz (o símbolo inicial 'E') na célula final de sucesso
    no_raiz = tabela[0][-1].find { |no| no.is_a?(Hash) && no[:variavel] == gramatica.simbolo_inicial }
    # Desce desempacotando os filhos para montar aquele array do professor
    extrair_ast(no_raiz)
  end

  private

  # ETAPA 1 DO CYK: Variáveis que geram terminais (A -> a)
  def adiciona_terminais()
    # Para cada token (ex: '4', '+', '5') na posição 'i'
    @tokens.each_with_index do |token, i|
      # Varre todas as regras da gramática
      @gramatica.regras.each do |regra|
        # Se a regra produz exatamente este token
        if terminal?(regra.direita, token)
          # Salva na diagonal principal [i][i] um "Nó" (Hash).
          # Esse Hash é o que permite guardar os filhos e o valor real para montar a árvore depois!
          tabela[i][i] << { variavel: regra.esquerda, valor: token.value, filhos: nil }
        end
      end
    end
  end

  # ETAPA 2 DO CYK: Variáveis que geram duas variáveis (A -> BC)
  def adiciona_nao_terminais()
    n = @tokens.length
    
    # Lógica clássica de 3 laços (for) do algoritmo CYK:
    # 1º Laço: Controla o tamanho (largura) do pedaço da string que estamos analisando (de 2 até n)
    for largura in 1...n
      # 2º Laço: Controla onde esse pedaço começa
      for inicio in 0...(n - largura)
        fim = inicio + largura # Calcula onde o pedaço termina
        
        # 3º Laço: Tenta dividir esse pedaço em duas partes (esquerda e direita)
        (inicio...fim).each do |meio|
          
          # Testa todas as regras da gramática pra ver se alguma se encaixa nessas duas partes
          @gramatica.regras.each do |regra|
            # Verifica se as partes esquerda/direita formam o corpo (A -> BC) da regra
            nos_encontrados = match_de_nao_terminais?(inicio, meio, fim, regra)
            
            # Se encontrou um "match" (B e C existem nas posições corretas)
            if nos_encontrados
              # Adiciona a cabeça da regra (A) na célula atual [inicio][fim], 
              # guardando B e C como "filhos" para a nossa árvore.
              tabela[inicio][fim] << { variavel: regra.esquerda, valor: nil, filhos: nos_encontrados }
            end
          end
        end
      end
    end
  end

  # Método auxiliar para checar se a regra A -> BC existe nas células calculadas
  def match_de_nao_terminais?(inicio, meio, fim, regra)
    # Se a regra não tem duas partes (não é A -> BC), ignora (pois terminais já foram resolvidos)
    return nil if regra.direita.length < 2 

    primeira_direita = regra.direita[0] # O 'B' da regra A -> BC
    segunda_direita = regra.direita[1]  # O 'C' da regra A -> BC

    # Procura o 'B' na célula da esquerda [inicio][meio]
    no_esq = tabela[inicio][meio].find { |no| no.is_a?(Hash) && no[:variavel] == primeira_direita }
    # Procura o 'C' na célula de baixo/direita [meio + 1][fim]
    no_dir = tabela[meio + 1][fim].find { |no| no.is_a?(Hash) && no[:variavel] == segunda_direita }

    # Se achou tanto o 'B' quanto o 'C', retorna os dois nós para conectá-los como filhos de 'A'
    if no_esq && no_dir
      return [no_esq, no_dir]
    end
    
    nil # Retorna vazio se não formou a regra
  end

  # Método auxiliar que verifica se uma regra gera um token específico (ex: S_soma -> '+')
  def terminal?(direita, token)
    # Se o lado direito da regra tiver mais de 1 símbolo, não é regra de terminal (forma normal de Chomsky)
    return false unless direita.length == 1
    
    # Se a regra for F -> 'NUM' e o token lido for um número, é um match!
    if direita[0] == 'NUM' && token.type == :NUMBER
      return true
    # Se a regra produz o próprio símbolo lido (ex: '+' == '+')
    elsif direita[0] == token.value.to_s
      return true
    end
    
    false
  end

  # Método recursivo que desce no Hash gerado pelo CYK e formata do jeito que o professor pediu no print
  def extrair_ast(no)
    return nil if no.nil?

    # CONDIÇÃO DE PARADA: Se o nó não tem filhos, ele é a "folha" da árvore (um número ou operador)
    if no[:filhos].nil?
      # Retorna convertido para inteiro se for número, senão retorna o símbolo
      return no[:valor].to_i if no[:valor].to_s.match?(/^\d+$/)
      return no[:valor]
    end

    # Pega o filho da esquerda (E) e da direita (X_soma, por exemplo)
    esq = no[:filhos][0]
    dir = no[:filhos][1]

    # Transforma o nome feio das variáveis de Chomsky em palavras pro array final:
    # Formato final exigido: ["operacao", numero_esquerda, numero_direita]
    case dir[:variavel]
    when 'X_soma'
      # Se for soma, a esquerda é o número/expressão (esq) 
      # e a direita é o segundo filho do operador (dir[:filhos][1], o 'T' na regra X_soma -> + T)
      return ["soma", extrair_ast(esq), extrair_ast(dir[:filhos][1])]
    when 'X_subtracao'
      return ["diferenca", extrair_ast(esq), extrair_ast(dir[:filhos][1])]
    when 'X_multiplicacao'
      return ["multiplicacao", extrair_ast(esq), extrair_ast(dir[:filhos][1])]
    when 'X_divisao'
      return ["divisao", extrair_ast(esq), extrair_ast(dir[:filhos][1])]
    when 'X_potencia'
      return ["potencia", extrair_ast(esq), extrair_ast(dir[:filhos][1])]
    when 'X_fecha_paren' # para regra F -> ( E )
      # Parênteses não entram no array final, então só extraímos o miolo da expressão que está dentro dele
      return extrair_ast(dir[:filhos][0])
    end

    # Tratamento especial para o número negativo (Unário). Regra: U -> - U
    if esq[:variavel] == 'S_subtracao'
      return ["negativacao", extrair_ast(dir)]
    end

    nil
  end
end
# Reconhecedor de Expressões Aritméticas

Projeto que implementa dois reconhecedores sintáticos para expressões matemáticas: **Earley** e **CYK**.

O objetivo é verificar se uma expressão é válida de acordo com a gramática definida — não é necessário calcular o resultado.

## Operações reconhecidas

| Operação       | Tipo    | Exemplo | Precedência |
|----------------|---------|---------|-------------|
| Parênteses     | Unária  | `(3)`   | Maior       |
| Número         | Unária  | `56`    | ↑           |
| Negativação    | Unária  | `-1`    | ↑           |
| Potência       | Binária | `6^2`   | ↑           |
| Multiplicação  | Binária | `6*1`   | ↑           |
| Divisão        | Binária | `8/4`   | ↑           |
| Soma           | Binária | `5+3`   | ↑           |
| Diferença      | Binária | `3-1`   | Menor       |

## Como rodar

```bash
# Parser de Earley
ruby main_earley.rb

# Parser CYK
ruby main_cyk.rb
```

## Saída do reconhecedor

Quando uma expressão é aceita, o reconhecedor emite a árvore abstrata:

```
Expressão: 4+5*2
Status: Aceito
Saída: ["soma", 4, ["multiplicacao", 5, 2]]
```

Quando é rejeitada:

```
Expressão: ^ 2 + 4
Status: Não aceito
```

## Estrutura do projeto

```
├── docs/
│   └── gramatica.md           # Gramáticas + árvore de derivação
├── gramatica.rb               # Classes Regra e Gramatica
├── estado.rb                  # Classes Estado e S (chart do Earley)
├── tokenizador.rb             # Prepara entrada (remove espaços, tokeniza)
├── earley.rb                  # Parser de Earley
├── cyk.rb                     # Parser CYK
├── gramatica_chomsky.rb       # Gramática na Forma Normal de Chomsky
├── main_earley.rb             # Testes com o Earley
├── main_cyk.rb                # Testes com o CYK
└── README.md
```

## Gramática (Earley)

Gramática livre de contexto sem forma normal, usada pelo parser de Earley:

```
E -> E + T | E - T | T
T -> T * P | T / P | P
P -> U ^ P | U
U -> - U | F
F -> ( E ) | N
N -> D N | D
D -> 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
```

- Soma e subtração: associatividade à **esquerda** (recursão à esquerda)
- Multiplicação e divisão: associatividade à **esquerda**
- Potência: associatividade à **direita** (recursão à direita)
- Números sem limite de tamanho (`N -> D N | D`)

## Gramática (CYK)

Na Forma Normal de Chomsky, números são tokenizados como `NUM` e regras unitárias são eliminadas copiando as produções. Detalhes completos em `docs/gramatica.md`.

## Expressões de teste

**Válidas:**
```
(1 + 4) * 2^4
7 / (1 - 3)
9^(1 * 6 / 2 + 4)
2 + 4 ^ -4 / 4
9^(1 * -2 + 3) - 3 / (6 + 3)
```

**Inválidas:**
```
^ 2 + 4
9 * 2 +
9 + + 3
() * 3
(3 + 3
```
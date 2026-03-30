function y = upsampling(x, L)
  % x: sinal original (vetor)
  % L: fator de upsampling (inteiro)

  if L < 1
    error("O fator L deve ser um inteiro positivo.");
  end

  % 1. Calcula o novo tamanho
  n_original = length(x);
  n_novo = n_original * L;

  % 2. Cria um vetor de zeros
  y = zeros(1, n_novo);

  % 3. Insere as amostras originais nas posições corretas (1, 1+L, 1+2L...)
  y(1:L:end) = x;
end

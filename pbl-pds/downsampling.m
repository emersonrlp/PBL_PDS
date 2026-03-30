function y = downsample(x, M)
  % x: sinal original (vetor)
  % M: fator de downsampling (inteiro)

  if M < 1
    error("O fator M deve ser um inteiro positivo.");
  end

  % Seleciona do primeiro elemento até o fim, pulando de M em M
  y = x(1:M:end);
end

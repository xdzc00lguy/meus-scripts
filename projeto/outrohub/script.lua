local taxa = 0.1
local epoch = 1000
local neuronios_ocultos = 0
local entradas = {}
local saidas = {}
local dados = {}

local function tamanho(x)
    local q = 0
    for _ in pairs(x) do
        q += 1
    end
    return q
end

local function calcularOcultos(n1, n2)
    local x = (2/3 * n1) + n2
    return math.floor(x + 0.5)
end

neuronios_ocultos = calcularOcultos(tamanho(entradas), tamanho(saidas))

local function sigmoid(x)
    return 1 / (1 + math.exp(-x))
end

local function derivado(x)
    return x * (1 - x)
end

local function criarNeuronio(entrada)
    local neuronio = { pesos = {}, bias = math.random() * 2 - 1 }
    for nome, valor in pairs(entrada) do
        neuronio.pesos[nome] = math.random() * 2 - 1
    end
    return neuronio
end

local function calculo(neuronio, entrada)
    local soma = neuronio.bias
    for nome, valor in pairs(entrada) do
        soma += valor * neuronio.pesos[nome]
    end
    return sigmoid(soma)
end

local ocultos = {}
for i = 0, neuronios_ocultos do
    ocultos[i] = criarNeuronio(entradas)
end

local entradaSaidas = {}
for i = 0, neuronios_ocultos do
    entradaSaidas[i] = 0
end

for nome, neuronio in pairs(saidas) do
    saidas[nome] = criarNeuronio(entradaSaidas)
end

local function prever(entrada)
    local oculta = {}
    for i = 0, neuronios_ocultos do
        oculta[i] = calculo(ocultos[i], entrada)
    end
    local resultado = {}
    for nome, neuronio in pairs(saidas) do
        resultado[nome] = calculo(neuronio, entrada)
    end
    return resultado, oculta
end

local function recompensar(entrada, acao, recompensa)
    local resultado, oculta = prever(entrada)
    local alvo = recompensa > 0 and 1 or 0
    local neuronio = saidas[acao]
    local erro = (alvo - resultado[acao]) * derivado(resultado[acao])
    if erro ~= 0 then
        for i = 0, neuronios_ocultos do
            neuronio.pesos[i] += erro * taxa * oculta[i]
        end
        neuronio.bias += erro * taxa
        local erros_ocultos = {}
        for i = 0, neuronios_ocultos do
            erros_ocultos[i] = erro * neuronio.pesos[i] * derivado(oculta[i])
        end
        for i = 0, neuronios_ocultos do
            local erro_h = erros_ocultos[i]
            for nome, valor in pairs(entradas) do
                ocultos[i].pesos[nome] += erro_h * taxa * entrada[nome]
                ocultos[i].bias += erro_h * taxa
            end
        end
    end
end

local function embaralhar(x)
    for y = #x, 2, -1 do
        local z = math.random(y)
        x[y], x[z] = x[z], x[y]
    end
end

for i = 0, epoch do
    embaralhar(dados)
    for _, dado in pairs(dados) do
        local resultado, oculta = prever(dado.entrada)
        local acao
        local confianca = -math.huge
        for nome, valor in pairs(resultado) do
            if valor > confianca then
                confianca = valor
                acao = nome
            end
        end
        if acao == dado.esperado then
            recompensar(dado.entrada, acao, 1)
        else
            recompensar(dado.entrada, acao, -1)
        end
    end
end
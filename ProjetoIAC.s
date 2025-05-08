#
# IAC 2023/2024 k-means
# 
# Grupo: 15
# Campus: Alameda
#
# Autores:
# 109886, Miguel Morais
# 109852, Pedro Vicente
# 109606, Gabriel Santos
#
# Tecnico/ULisboa


# ALGUMA INFORMACAO ADICIONAL PARA CADA GRUPO:
# - A "LED matrix" deve ter um tamanho de 32 x 32
# - O input e' definido na seccao .data. 
# - Abaixo propomos alguns inputs possiveis. Para usar um dos inputs propostos, basta descomentar 
#   esse e comentar os restantes.
# - Encorajamos cada grupo a inventar e experimentar outros inputs.
# - Os vetores points e centroids estao na forma x0, y0, x1, y1, ...


# Variaveis em memoria
.data

#Input A - linha inclinada
#n_points:    .word 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8

#Input B - Cruz
#n_points:    .word 5
#points:      .word 4,2, 5,1, 5,2, 5,3 6,2

#Input C
#n_points:     .word 23
#points:       .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
n_points:    .word 30
points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10



# Valores de centroids e k a usar na 1a parte do projeto:
#centroids:   .word 0,0
#k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
centroids:    .word 0,0, 10,0, 0,10
k:            .word 3
L:            .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
clusters:     .zero 120
newCentroids: .zero 24 #vetor auxiliar que contem a copia dos centroids



#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff

dim: .word 32



# Codigo
 
.text
    
    #chamada da funcao principal do programa
    jal mainKMeans
    
    #Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall


### printPoint
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja' e' fornecida pelos docentes
# E' uma funcao auxiliar que deve ser chamada pelas funcoes seguintes que pintam a LED matrix.
# Argumentos:
# a0: x
# a1: y
# a2: cor

printPoint:
    li a3, LED_MATRIX_0_HEIGHT
    sub a1, a3, a1
    addi a1, a1, -1
    li a3, LED_MATRIX_0_WIDTH
    mul a3, a3, a1
    add a3, a3, a0
    slli a3, a3, 2
    li a0, LED_MATRIX_0_BASE
    add a3, a3, a0   # addr
    sw a2, 0(a3)
    jr ra
    

### cleanScreen
# Limpa todos os pontos do ecr?
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    li t0, 0 #indices da linha
    li t1, 0 #indices da coluna
    lw t2, dim #max
    li a2, white #cor para apagar os leds
    addi sp, sp, -4
    sw ra, 0(sp)
    cleanScreen_loop_linhas:
        cleanScreen_loop_colunas:
            add a0, x0, t1 #linha
            add a1, x0, t0 #coluna
            jal printPoint
            addi t0, t0, 1
            blt t0, t2, cleanScreen_loop_colunas
        addi t1, t1 ,1
        li t0, 0
        blt t1, t2, cleanScreen_loop_linhas
        
        
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

    
### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    li t0, 0 #indices do vetor
    la t1, points #obter o endereco do vetor points
    lw t2, n_points #obter o numero de pontos
    la t3, clusters #obter o endereco do vetor clusters
    la t4, colors #obter o endereco com as cores
    slli, t2, t2, 1 #sessenta coordenadas
    
    #guardar o contexto incial
    addi sp, sp, -4
    sw ra, 0(sp)
    
    printClusters_loop:
        #obter as coordenadas do ponto
        lw a0, 0(t1)
        lw a1, 4(t1)
        
        #obter a cor do cluster que o ponto pertence
        lw a2, 0(t3)
        slli a2, a2, 2
        add a2, t4, a2
        lw a2, 0(a2)
        
        #obter o indice do proximo ponto e as suas
        #respetivas coordenadas
        addi t1, t1, 8
        addi t3, t3, 4
        
        jal printPoint
        addi t0, t0, 2
        blt t0, t2, printClusters_loop
    
    #recuperar o contexto incial
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra


### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    lw t1, k  #obter o numero de centroids
    la t0, centroids #obter o endereco de centroids
    
    #guardar o contexto incial
    addi sp, sp, -4
    sw ra, 0(sp)
    
    #obter a cor dos centroids
    li a2, black
    
    #dar print dos centroids
    loop_printCentroids:
        lw a0, 0(t0)
        lw a1, 4(t0)
        jal printPoint
        addi t0, t0, 8
        addi t1, t1, -1
        bgt t1, x0, loop_printCentroids
        
    #recuperar o contexto incial
    lw ra, 0(sp)
    addi sp, sp, 4
    
    jr ra
    

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual 
# de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    la t0, centroids
    li a2, 0 #indice do centroid a calcular. 
             #nao deve ser alterado pela Media.
    
    #preservar o contexto incial
    addi sp, sp, -8
    sw ra, 0(sp)
    sw t0, 4(sp)
    
    loop_calculateCentroid:
        la a1, points #obter o enedereco do vetor points
        jal Media #calcula a media dos x
        lw t0, 4(sp) #recuperar o endereco
        #verificar que a media nao deu um valor negativo
        blt a0, x0, pula1_loop_calculateCentroids
        sw a0, 0(t0) #guarda o valor
        
    pula1_loop_calculateCentroids:
        addi a1, a1, 4 #passa para a coordenada y
        jal Media #calcula a media dos y
        lw t0, 4(sp) #recuperar o endereco
        
        #verificar que a media nao deu um valor negativo
        blt a0, x0, pula2_loop_calculateCentroids
        sw a0, 4(t0) #guarda o valor
        
    pula2_loop_calculateCentroids:    
        addi t0, t0, 8 #Passa para o centroide seguinte
        sw t0, 4(sp)
        addi a2, a2, 1
        lw t2, k
        
        #caso o indice seja menor que k, executa mais um ciclo
        blt a2, t2, loop_calculateCentroid
        
    lw ra, 0(sp) #repoe o ra
    addi sp, sp, 8
    jr ra # retorna


### Media
# Calcula a media de uma coordenada x ou y no vetor points.
# Argumentos: 
# a1: endereco do vetor points      
# a2: k atual
# Retorno: a0: media

Media:
    li t1, 0 #soma
    li t2, 0 #contador
    mv t3, a1
    la t4, clusters
    li t5, 0 #numero de pontos
    lw a3, n_points
    somaMedia:
        lw t6, 0(t4) #carrega o ponto no vetor clusters
        lw t0, 0(t3) #carrega o ponto no vetor points
        addi t3, t3, 8 #passa para a proxima iteracao
        addi t4, t4, 4
        addi t2, t2, 1
        
        bge t2, a3 Media_pula
        bne t6, a2, somaMedia #caso o ponto pertenca ao cluster que queremos calcular, entra na Media
        add t1, t1, t0
        addi t5, t5, 1
        j somaMedia
       
    Media_pula: 
        div a0, t1, t5
        jr ra


### mainSingleCluster
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum

mainSingleCluster:
    
    addi, sp, sp, -4
    sw ra, 0(sp)
    
    #2. cleanScreen
    jal cleanScreen

    #3. printClusters
    jal printClusters

    #4. calculateCentroids
     jal calculateCentroids

    #5. printCentroids
    jal printCentroids

    #6. Termina
    lw ra 0(sp)
    addi sp, sp ,4
    jr ra


###inicializeCentroids
# de forma pseudoaleatoria atribui o dado valor
# das coordenadas a um numero de k de centroids
# argumentos: nenhum
# retorno: nenhum

inicializeCentroids:
    
    #guardar o contexto incial
    addi sp, sp, -4 
    sw ra, 0(sp)
    
    lw t1, k #obter o numero de centroids
    slli t1, t1, 1 #obter o numero total de coordenadas
    la t2, centroids #obter o endereco do vetor centroids
    
    li a7, 30
    ecall
    
    #obter os pontos de forma pseudoaleatoria
    loop_inicialize_centroids:
        li t0, 1103515245
        mul a0, a0, t0
        li t0, 12345
        add a0, a0, t0
        li t0, 32
        remu a0, a0 ,t0
        sw a0, 0(t2)
        addi t2, t2, 4
        addi t1, t1, -1
        bgt t1, x0, loop_inicialize_centroids
    
    #recuperar o contexto incial
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra
    

### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:

    #guardar o contexto incial
    addi, sp, sp, -4
    sw ra, 0(sp)
    
    addi t0, x0, -1
    
    #obter o modulo da distancia no eixo dos xx
    sub a0, a0, a2 
    bge a0, x0, jump1 
    mul a0, a0, t0 
    jump1:
        
    #obter modulo da distancia no eixo dos xx
    sub a1, a1, a3
    bge a1, x0, jump2
    mul a1, a1, t0
    jump2:
        
    #obter a distancia total
    add a0, a0, a1
    
    #recuperar o contexto incial
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra


### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    
    la t0, centroids
    li t2, 0 #indice
    li t3 0 #menor indice
    li a4, 64 # menor valor
    
    #guardar o contexto incial
    addi sp, sp, -24
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw t0, 12(sp)
    sw t2, 16(sp)
    sw t3, 20(sp)

    #procurar o centroid mais perto do ponto
    loop_nearestCluster:
        lw a0, 4(sp)
        lw a1, 8(sp)
        lw a2, 0(t0)
        lw a3, 4(t0)
        jal manhattanDistance
        bge a0, a4, nearestCluster_pula
        
        mv a4, a0 # atualizar o menor
        lw t2, 16(sp)
        sw t2, 20(sp)
        
        nearestCluster_pula:
        lw t0, 12(sp)
        lw t2, 16(sp)
        addi t2, t2, 1
        addi t0, t0, 8
        sw t0, 12(sp)
        sw t2, 16(sp)
        lw t1, k
        blt t2, t1, loop_nearestCluster
    
    #retornar o indice
    lw t3, 20(sp)
    mv a0, t3  
    
    #recuperar o contexto incial
    lw ra, 0(sp)
    addi sp, sp, 24
    jr ra


### obtemIndicesClusters
# Determina os indices dos clusters a que os pontos pretencem
# e coloca-los no vetor clusters
# argumentos: nenhum
# retorno: nenhum 

obtemIndicesClusters:
    
    #incializar o valor das variaveis
    lw t0, n_points
    la t1, clusters
    la t2, points
    
    #guardar o contexto incial
    addi sp, sp, -16
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2, 12(sp)

    loop_obtemIndicesClusters:
        lw a0, 0(t2)
        lw a1, 4(t2)
        jal nearestCluster
        
        #voltar a obter o valores originais
        lw t0, 4(sp)
        lw t1, 8(sp)
        lw t2, 12(sp)
        
        #guardar o incide do centroid mais proximo
        sw a0, 0(t1)
        
        #obter o proximo endereco e guardar a infromacao
        #necessaria
        addi t2, t2, 8
        addi t1, t1, 4
        addi t0, t0, -1
        sw t0, 4(sp)
        sw t1, 8(sp)
        sw t2, 12(sp)
        bgt t0, x0, loop_obtemIndicesClusters
    
    lw ra, 0(sp)
    addi sp, sp, 12
    jr ra


### saveCentroids
# Realiza uma copia do vetor centroids (guardar-o)
# argumentos: nenhum
# retorno: nenhum

saveCentroids:
    
    #obter os enderecos do vetor centroids
    #(o recente e onde se vai salvar)
    la t0, newCentroids
    la t1, centroids
    
    #obter o numero de coordenadas dos centroids
    lw t2, k
    slli t2, t2, 1
    loop_saveCentroids:
        
        #copiar o conteudo para o novo vetor
        lw t3, 0(t1)
        sw t3, 0(t0)
        
        #obter a proxima posicao
        addi t0, t0, 4
        addi t1, t1, 4
        addi t2, t2, -1
        bgt t2, x0, loop_saveCentroids
    
    jr ra


### centroidsEqual
# compara o conteudo do vetor centroids com o anterior
# argumentos: nenhum
# retorno:
#    0 se o conteudo for igual ou 1 se for diferente

centroidsEqual:
    
    la t0, newCentroids
    la t1, centroids
    lw t2, k
    slli t2, t2, 1
    
    loop_centroidsEqual:
        
        #comparar se o valor das coordenadas s?o iguais
        lw t3, 0(t0)
        lw t4, 0(t1)
        bne t3, t4, diferentes
        
        #obtem o valor da seguinte coordenada
        addi t0, t0, 4
        addi t1, t1, 4
        addi t2, t2, -1
        bgt t2, x0, loop_centroidsEqual
    
    li a0, 0
    jr ra
    
    diferentes:
        li a0, 1
        jr ra


### limpaPontos
# percorre os vetores points e centroids e apaga-os
# argumentos: nenhum
# retorno: nenhum

limpaPontos:
    
    #obter o numero de pontos e o vetor pontos
    lw t0, n_points
    la t1, points
    li a2, white # cor para apagara os pontos
    
    #guardar o contexto incial
    addi sp, sp, -8
    sw ra, 0(sp)
    
    #primeiro loop
    li t2, 1
    sw t2, 4(sp)
    
    #percorrer o vetor pontos para os apagar
    loop_limpaPontos:
        lw a0, 0(t1)
        lw a1, 4(t1)
        jal printPoint
        addi t1, t1, 8
        addi t0, t0, -1
        bgt t0, x0, loop_limpaPontos
    
    #verifica se estamos no primeiro ou segundo loop
    li t0, 2
    lw t2, 4(sp)
    beq t2, t0, limpaPontos_pula
    
    #obter o numero de centroids e o vetor centroids
    lw t0, k
    la t1, centroids
    
    #segundo loop
    li t2, 2
    sw t2, 4(sp)
    j loop_limpaPontos
    
    limpaPontos_pula:
    #recuperar o contexto incial
    lw ra, 0(sp)
    addi sp, sp, 8
       
    jr ra
        
 
### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:  
    
    #guardar o contexto incial
    addi, sp, sp, -4
    sw ra, 0(sp)
    
    #limpar o ecra
    jal cleanScreen
    
    #incializar os centroids
    jal inicializeCentroids
    
    #pula uma intrucao incial desnecessaria
    j saltaInstrucao
    
    loop_mainkMeans:
        
        #OTIMIZATION
        #vantagens menos tempo desperdicado para percorrer todos os pontos
        # da matriz 32x32, passando um menor numero de intrucoes
        #desvantagem: mais acessos a memória o que pode aumentar o tempo 
        #necessario para apagar os todos pontos caso ambos os vetores tenham
        #um tamanho relativamente grande
        
        #limpar o ecra
        jal limpaPontos
        
        saltaInstrucao:
            
        #guardar o valor dos centroids
        jal saveCentroids
        
        #obter o indice dos clusters que os pontos pertencem
        jal obtemIndicesClusters
    
        #calcular os novos centroids
        jal calculateCentroids
        
        #imprime os clusters e centroids
        jal printClusters  
        jal printCentroids
        
        #compara o vetor centroids com o guardado
        #se forem iguais o algoritmo para
        jal centroidsEqual
        beq a0, x0, fim
        
        #decrementar o valor de L
        lw t0, L
        la t1, L
        addi t0, t0, -1
        sw t0, 0(t1)
        
        bge t0, x0, loop_mainkMeans 
    
    fim:
    #recuperar o contexto incial
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

####################################
#####   Data set Glass      ########
#####     Algoritmo         ########
#####   Red neuronal        ########
#####  Efrain Soto Olmos    ########
####################################

library(neuralnet)
library(tidyverse)

# Empleamos una función para reescalar los datos al dominio [0,1].

min.max<-function(v)
{
  return((v-min(v))/(max(v)-min(v)))
}

#Carga de datos
datos<-read.csv("https://raw.githubusercontent.com/EfrainSO/diplomado/main/Proyecto%202/Glass/Glass.csv")
# Paso 2: Preprocesamiento de los datos
# Reescalamos las covariables a la escala [0,1] 
datos<-mutate_at(datos, as.vector(colnames(datos[,-10])),
                 min.max)

# Definimos la variable de respuesta como factor
datos$tipo_de_cristal<-as.factor(datos$tipo_de_cristal)


# Paso 3. Definir un conjunto de prueba y entrenamiento.
future::plan("multisession")
set.seed(123)
#####################validacion cruzada
#etiquetas
id=row.names(datos)
#Eticatas para modificar
id_new=id
#Cantidad de datos en prueba
por=round(length(id)*0.1,0)
#lista para las etiquetas de prueba
prueba=list()
#lista para las etiquetas de entrenamiento
entrenamiento=list()
#Separacion de las etiquetas
for (i in 1:9) {
  id_1=sample(id_new,por)
  id_new=setdiff(id_new,id_1)
  prueba[[i]]=id_1
  entrenamiento[[i]]=setdiff(id,prueba[[i]])
               }
prueba[[10]]=id_new
entrenamiento[[10]]=setdiff(id,prueba[[i]])

###################
#Medicion de capacidad predictiva
#vector de errores de clasificacion
ec_multiple=c()
#bucle de validacion cruzada
for (i in 10:11) {#nodos a medir
  #vector de errores por validacion
  error=c()
  for (j in 1:10) {#partes de validacion cruzada
    #sets
    set.test=datos[prueba[[j]],] 
    set.train=datos[entrenamiento[[j]],]
    #Modelo
    glass.modelo<-neuralnet(tipo_de_cristal ~., data=set.train, 
                            hidden = c(i), 
                            err.fct = "sse",
                            linear.output = FALSE,
                            stepmax = 1e+07
    )
    ##############Analisis predictivo
    #Prediccion
    modelo_resultados<-predict(glass.modelo,set.test)
    #Matriz de confusion
    confusion<-table(set.test$tipo_de_cristal, apply(modelo_resultados, 1, which.max))
    #Exactitud
    acc<-sum(diag(confusion))/dim(set.test)[1]
    #Error de clasificacion
    error[j]=1-acc
  }
  #Guardamos los errores
  ec_multiple[i]=mean(error)
}
#Errores de clasificacion
ec_multiple

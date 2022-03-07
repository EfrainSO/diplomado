####################################
#####   Data set Glass      ########
#####     Algoritmo         ########
#####      Naive Bayes      ########
#####  Efrain Soto Olmos    ########
####################################

#Cargamos las librerias necesarias
library(tidyverse)   
library(paradox)
library(mlr3learners) 
library(mlr3measures) 
library(mlr3tuning)
library(mlr3verse)



#################################
#Carga de datos
datos<-read.csv("https://raw.githubusercontent.com/EfrainSO/diplomado/main/Proyecto%202/Glass/Glass.csv")
#transformación a factor la variable tipo_de_cristal
datos<-datos %>% mutate(tipo_de_cristal=as.factor(tipo_de_cristal))
#Analisis de realciones
cor(datos)
#Vemos una alta correlacion entre el indice de refraccion y el calcio
#Por lo que se intentara tambien eliminando una de las dos, considerando
#lo mismo con el cilicio por lo que se eliminara indice de refraccion

###########Opcional
#Eliminamos indice de refraccion
#datos$Indice_refraccion=NULL

#Definición de la tarea
tarea<-TaskClassif$new("classif_naive",
                       backend = datos,
                       target = "tipo_de_cristal")
#Definir el algoritmo
class.naiveB<-lrn("classif.naive_bayes", predict_type="prob")
#class.naiveB$param_set
#Activamos todos los nucleos
future::plan("multisession")
set.seed(123)

#######Medicion del algoritmo
#Validacion cruzada
val_curzada<-rsmp("repeated_cv", folds=10, repeats=5)
#Medicion
resultados<-resample(tarea,class.naiveB,val_curzada)
#Medidas
resultados$aggregate(msr("classif.acc"))
resultados$aggregate(msr("classif.ce"))
#Mediciones
#0.4101732  #0.5898268
#Disminuye la exactitud si eliminamos indice de refraccion
#0.4   #0.6

############Entrenamiento
naive.modelo<-class.naiveB$train(tarea)
#Predicciones
pred<-naive.modelo$predict_newdata(datos)
#Matriz de confusion
pred$confusion
ma_confusion<-as.table(pred$confusion) 
write.table(ma_confusion,"confusion.txt")



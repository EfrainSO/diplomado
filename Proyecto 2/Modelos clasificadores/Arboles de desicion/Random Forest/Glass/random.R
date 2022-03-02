####################################
#####   Data set Glass      ########
#####     Algoritmo         ########
#####   Random Forest       ########
#####  Efrain Soto Olmos    ########
####################################
library(tidyverse)
library(skimr)       
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
#Definición de la tarea
tarea<-TaskClassif$new("classif_random_Forest",
                       backend = datos,
                       target = "tipo_de_cristal")
#Definir el algoritmo
classif.bosque<-lrn("classif.randomForest")
#Activamos todos los nucleos
future::plan("multisession")
set.seed(123)


######################################
#Selección de los hiperparametros

espacio_soluciones<-ParamSet$new(list(ParamInt$new("ntree",1250,1250),
                                      ParamInt$new("mtry",1,4),
                                      ParamInt$new("nodesize",10,20),
                                      ParamInt$new("maxnodes",10,15)))
#Tipo de busqueda aleatoria de 100 casos
tipo_busqueda<-mlr3tuning::tnr("random_search",batch_size=100)
#tipo de validación
val_cruzada<-rsmp("cv",folds=10)
#Union de las configuraciones para la busqueda del mejor modelo
#Se selecciona solo una medida de precisión SingleCrit
#Se utiliza el ce
busqueda<-TuningInstanceSingleCrit$new(task=tarea,
                                      learner=classif.bosque,
                                      resampling=val_cruzada,
                                      measure=msr("classif.ce"),
                                      search_space=espacio_soluciones,
                                      terminator=trm("evals",n_evals=200))
#Se busca el mejor modelo
tipo_busqueda$optimize(busqueda)
#Mejor modelo
busqueda$archive$best()
#Error ce de 0.2244589              
#Modelo entrenado con los mejores hiperparametros
classif.bosque$param_set$values<-busqueda$result_learner_param_vals
#Entrenamiento con la tarea
model_calibrado<-classif.bosque$train(tarea)
#Prediccion con la tarea
pred<-model_calibrado$predict_newdata(datos)
#Matriz de confusion
pred$confusion

######################################
#OOB_Error, este error se visualiza ya que se realiza un bootstrap
#y muy posiblemente algunos arboles no contengan todas las variables
#por lo que visualizamos el error especifico en esas variables
#errores
bosqueModeloDatos<-model_calibrado$model$err.rate
#Factores
variables<-colnames(bosqueModeloDatos)
#Variable dummy para el grafico
x<-1:1250
#grafico del error oob del primer factor
plot(x,y=bosqueModeloDatos[,1],col=1,lty=1,type="l", ylim=c(0,0.3))
#Grafico del error oob de los factores restantes
for(i in 2:length(variables))
  lines(x, y=bosqueModeloDatos[,i],col=i,lty=i,type="l")

#Se aumentara el numero de arboles ya que dos variables no se
#estabilizaron aunque si hubo mejoria en el error de clasificacion
#el numero de arboles se aumento a 1500 pero es suficiente con 
#1250 y las busquedas se dejaran en 100

###################################
#Metodo de validación anidada
#Validación externa
vc_externa<-rsmp("cv", folds=10)
#Validación interna
vc_interna<-rsmp("repeated_cv", folds=10, repeats=5)

#nuevo espacio de soluciones dado el analisis
espacio<-ParamSet$new(list(ParamInt$new("ntree",1250,1250),
                           ParamInt$new("mtry",1,4),
                           ParamInt$new("nodesize",10,20),
                           ParamInt$new("maxnodes",10,15)))
#Nueva cantidad de busqueda
tipo_busqueda<-mlr3tuning::tnr("random_search",batch_size=100)
#Busqueda del mejor modelo
optim.learner<-AutoTuner$new(classif.bosque,
                             vc_interna,
                             msr("classif.ce"),
                             trm("evals",n_evals=200),
                             tipo_busqueda,
                             espacio)
#Realizamos la busqueda
resultados<-resample(tarea,optim.learner,vc_externa)
#Promediamos el error
resultados$aggregate(measure=msr("classif.ce"))
#Error de clasificación final 0.2437229   
#entrenamiento del modelo con todos los datos
modelo.final<-optim.learner$train(tarea)
#modelo final
modelo.final$model$learner
#prediccion del modelo final
pred<-modelo.final$predict_newdata(datos)
#matriz de confusión
pred$confusion
ma_confusion<-as.table(pred$confusion) 
write.table(ma_confusion,"confusion.txt")

#se intento aumentar el rango de los parametros
#pero el modelo no acepto el nuevo rango

####################################
#####   Data set Glass      ########
#####     Algoritmo         ########
##### Arboles de desición   ########
#####  Efrain Soto Olmos    ########
####################################


#librerias
library(tidyverse)    #operaciones con data set
library(paradox)  #opciones de tuneado
library(mlr3learners)  #algoritmos
library(mlr3tuning)    #autotuneado
library(mlr3measures)  #medidas de precisión
library(rpart.plot)    #grafica del arbol

#################################
#Carga de datos
datos<-read.csv("https://raw.githubusercontent.com/EfrainSO/diplomado/main/Proyecto%202/Glass/Glass.csv")
#transformación a factor la variable tipo_de_cristal
datos<-datos %>% mutate(tipo_de_cristal=as.factor(tipo_de_cristal))
#Definición de la tarea
tarea<-TaskClassif$new("classif_arbol",
                       backend = datos,
                       target = "tipo_de_cristal")
#Definir el algoritmo
classif.arbol<-lrn("classif.rpart")
#Activamos todos los nucleos
future::plan("multisession")
set.seed(123)

######################################
#Selección de los hiperparametros
opcion_param<-ParamSet$new(list(ParamInt$new("minsplit",1,5),
                                ParamInt$new("minbucket",1,20),
                                ParamInt$new("maxdepth",1,20),
                                ParamDbl$new("cp",0.01,0.1)))
#tipo de busqueda aleatoria de 500
tipo_busqueda<-mlr3tuning::tnr("random_search",batch_size=500)
#tipo de validación
val_cruzada<-rsmp("cv",folds=10)
#Union de las configuraciones para la busqueda del mejor modelo
#Se selecciona solo una medida de precisión SingleCrit
#Se utiliza el ce
busqueda<-TuningInstanceSingleCrit$new(task=tarea,
                                       learner=classif.arbol,
                                       resampling=val_cruzada,
                                       measure=msr("classif.ce"),
                                       search_space=opcion_param,
                                       terminator=trm("evals",n_evals=5))
#Se busca el mejor modelo
tipo_busqueda$optimize(busqueda)

########################################
#Analisis del proceso de autotunin
modelos<-busqueda$archive$data
modelos_orden<-modelos[order(modelos$classif.ce),]
#el mejor modelo tuvo un error de 0.2889610
#borrar columnas inccesarias
modelos_orden[,7:10]<-list(NULL)

#guardando tablas
write.csv(modelos_orden,"tabla.csv")

#Analisis de los hiperparametros encontrados en la busqueda
###Rangos encontrados en los mejores 10 minsplit, 1-5
min(modelos_orden[1:10]$minsplit)
max(modelos_orden[1:10]$minsplit)
###Rangos encontrados en los mejores 10 minbucket, 2-8
min(modelos_orden[1:10]$minbucket)
max(modelos_orden[1:10]$minbucket)
###Rangos encontrados en los mejores 10 maxdeph, 7-15
min(modelos_orden[1:10]$maxdepth)
max(modelos_orden[1:10]$maxdepth)
###Rangos encontrados en los mejores 10 cp, 0.0144087-0.02797776
min(modelos_orden[1:10]$cp)
max(modelos_orden[1:10]$cp)


##Modelo calibrado
classif.arbol$param_set$values=busqueda$result_learner_param_vals

#Entrenamiento del modelo
classif.arbol$train(tarea)
#grafica del modelo, que se ve horrible
#rpart.plot(classif.arbol$model, type=5)
#predicciones
pred<-classif.arbol$predict(tarea)
#matriz de confusión
ma_confusion<-as.table(pred$confusion) 
write.table(ma_confusion,"confusion.csv")




###################################
#Metodo de validación anidada
#Validación externa
vc_externa<-rsmp("cv", folds=10)
#Validación interna
vc_interna<-rsmp("repeated_cv", folds=10, repeats=5)

#nuevo espacio de soluciones dado el analisis
espacio<-ParamSet$new(list(ParamInt$new("minsplit",1,5),
                                ParamInt$new("minbucket",2,8),
                                ParamInt$new("maxdepth",7,15),
                                ParamDbl$new("cp",0.01,0.03)))
#Nueva cantidad de busqueda
tipo_busqueda<-mlr3tuning::tnr("random_search",batch_size=300)
#Busqueda del mejor modelo
optim.learner<-AutoTuner$new(classif.arbol,
                             vc_interna,
                             msr("classif.ce"),
                             trm("evals",n_evals=5),
                             tipo_busqueda,
                             espacio)
#Realizamos la busqueda
resultados<-resample(tarea,optim.learner,vc_externa)
#Promediamos el error
resultados$aggregate(measure=msr("classif.ce"))
#Error de clasificación final 0.3227273  
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

####################################
#####   Data set Glass      ########
#####     Algoritmo         ########
#####       SVM             ########
#####  Efrain Soto Olmos    ########
####################################

library(tidyverse)
library(paradox)
library(mlr3learners) 
library(mlr3measures) 
library(mlr3verse)
library(mlr3tuning) 
library(ggplot2)

#################################
#Carga de datos
datos<-read.csv("https://raw.githubusercontent.com/EfrainSO/diplomado/main/Proyecto%202/Glass/Glass.csv")
#transformación a factor la variable tipo_de_cristal
datos<-datos %>% mutate(tipo_de_cristal=as.factor(tipo_de_cristal))
#Definición de la tarea
tarea<-TaskClassif$new("classif_svm",
                       backend = datos,
                       target = "tipo_de_cristal")
#Definimos el algoritmo
class.svm<-lrn("classif.svm", scale=TRUE)
#Activamos todos los nucleos
future::plan("multisession")
set.seed(123)

######################################
#Selección de los hyperparametros
opcion_param<-ParamSet$new(list(ParamDbl$new("cost",0,10),
                                ParamDbl$new("gamma",0,5),
                                ParamFct$new("kernel", c("polynomial","radial","sigmoid")),
                                ParamFct$new("type","C-classification")))
#tipo de busqueda aleatoria de 500
tipo_busqueda<-mlr3tuning::tnr("random_search",batch_size=200)
#tipo de validación
val_cruzada<-rsmp("cv",folds=10)
#Union de las configuraciones para la busqueda del mejor modelo
#Se selecciona solo una medida de precisión SingleCrit
#Se utiliza el ce
busqueda=TuningInstanceSingleCrit$new(task=tarea,
                                     learner =class.svm,
                                     resampling=val_cruzada,
                                     measure = msr("classif.ce"),
                                     search_space = opcion_param,
                                     terminator=trm("evals", n_evals=10))     
#Se busca el mejor modelo
tipo_busqueda$optimize(busqueda)
#Mejor modelo
busqueda$archive$best()
#Error ce de 0.2820346              
#Modelo entrenado con los mejores hiperparametros
class.svm$param_set$values<-busqueda$result_learner_param_vals
#Entrenamiento con la tarea
model_calibrado<-class.svm$train(tarea)
#Prediccion con la tarea
pred<-model_calibrado$predict_newdata(datos)
#Matriz de confusion
pred$confusion



###################################
#Metodo de validación anidada
#Validación externa
vc_externa<-rsmp("cv", folds=10)
#Validación interna
vc_interna<-rsmp("repeated_cv", folds=10, repeats=5)
#Busqueda del mejor modelo
optim.learner<-AutoTuner$new(learner = class.svm,
                             vc_interna,msr("classif.ce"), 
                             opcion_param,
                             terminator = trm("evals", n_evals=10),
                             tuner=tipo_busqueda)
#Realizamos la busqueda
resultados<-resample(tarea,optim.learner,vc_externa)
#Promediamos el error
resultados$aggregate(measure=msr("classif.ce"))
#Error de clasificación final 0.3270563 tiempo menor que arboles   
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

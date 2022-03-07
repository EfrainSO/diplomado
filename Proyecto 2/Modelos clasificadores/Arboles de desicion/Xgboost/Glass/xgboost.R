####################################
#####   Data set Glass      ########
#####     Algoritmo         ########
#####  Xboost arboles de    ########
#####     desición          ########
#####  Efrain Soto Olmos    ########
####################################

library(tidyverse)
library(paradox)
library(mlr3learners) 
library(mlr3measures) 
library(mlr3verse)
library(mlr3tuning) 
library(xgboost)
library(ggplot2)

#################################
#Carga de datos
datos<-read.csv("https://raw.githubusercontent.com/EfrainSO/diplomado/main/Proyecto%202/Glass/Glass.csv")
#transformación a factor la variable tipo_de_cristal
datos<-datos %>% mutate(tipo_de_cristal=as.factor(tipo_de_cristal))
#Definición de la tarea
tarea<-TaskClassif$new("classif_xboost",
                       backend = datos,
                       target = "tipo_de_cristal")
#Definimos el algoritmo
clasif.xgboost<-lrn("classif.xgboost")
#Activamos todos los nucleos
future::plan("multisession")
set.seed(123)

######################################
#Selección de los hyperparametros
opcion_param<-ParamSet$new(list(ParamDbl$new("eta",0,1),
                                ParamDbl$new("gamma",0,5),
                                ParamInt$new("max_depth",1,5),
                                ParamDbl$new("min_child_weight",0,5),
                                ParamDbl$new("subsample",0.5,1),
                                ParamDbl$new("colsample_bytree",0.5,1),
                                ParamInt$new("nrounds",200,200),
                                ParamFct$new("eval_metric", c("merror", "mlogloss"))
))                                     
#tipo de busqueda aleatoria de 500
tipo_busqueda<-mlr3tuning::tnr("random_search",batch_size=200)
#tipo de validación
val_cruzada<-rsmp("cv",folds=10)
#Union de las configuraciones para la busqueda del mejor modelo
#Se selecciona solo una medida de precisión SingleCrit
#Se utiliza el ce
busqueda<-TuningInstanceSingleCrit$new(task=tarea,
                                       learner=clasif.xgboost,
                                       resampling=val_cruzada,
                                       measure=msr("classif.ce"),
                                       search_space=opcion_param,
                                       terminator=trm("evals",n_evals=200))
#Se busca el mejor modelo
tipo_busqueda$optimize(busqueda)
#Mejor modelo
busqueda$archive$best()
#con un error de 0.215368 muy rapido
#Parametros del mejor modelo
busqueda$result_learner_param_vals
# parametros
#nrounds 200, nthread 1, eta 0.2088763, gamma 0.09182042,
#max_depth 3, min_child_weight 0.03499227, subsample 0.698623
#colsample_bytree 0.9764205, eval_metric merror

##Modelo calibrado
clasif.xgboost$param_set$values=busqueda$result_learner_param_vals
#Entrenamiento del modelo
model_tuned<-clasif.xgboost$train(tarea)

#Importancia de las covariables
model_tuned$importance()

#Indice_refraccion          magnesio          aluminio            calcio 
#0.17205417        0.15673262        0.15233355        0.13702604 
#bario             sodio           potasio           silicio 
#0.12722861        0.08321100        0.07977023        0.05615786 
#hierro 
#0.03548591 
#El hierro y el silico no aportan mucho



#predicciones
pred<-model_tuned$predict_newdata(datos)
#matriz de confusión
ma_confusion<-as.table(pred$confusion)
ma_confusion #a su maquina le atino a todo

#Graficamos las perdidas para estimar si tenemos suficientes
#arboles
#model_tuned$model$evaluation_log
ggplot(model_tuned$model$evaluation_log, aes(iter,train_merror))+geom_line()+geom_point()
#Con 50 arboles es mas que suficiente

###################################
#Metodo de validación anidada
#Validación externa
vc_externa<-rsmp("cv", folds=10)
#Validación interna
vc_interna<-rsmp("repeated_cv", folds=10, repeats=5)

#nuevo espacio de soluciones dado el analisis
espacio<-ParamSet$new(list(ParamDbl$new("eta",0,1),
                           ParamDbl$new("gamma",0,5),
                           ParamInt$new("max_depth",1,5),
                           ParamDbl$new("min_child_weight",0,5),
                           ParamDbl$new("subsample",0.5,1),
                           ParamDbl$new("colsample_bytree",0.5,1),
                           ParamInt$new("nrounds",50,50),
                           ParamFct$new("eval_metric", c("merror", "mlogloss"))
))   
#Nueva cantidad de busqueda
tipo_busqueda<-mlr3tuning::tnr("random_search",batch_size=200)
#Busqueda del mejor modelo
optim.learner<-AutoTuner$new(learner = clasif.xgboost,
                             vc_interna,msr("classif.ce"), 
                             espacio,
                             terminator = trm("evals", n_evals=200),
                             tuner=tipo_busqueda)
#Realizamos la busqueda
resultados<-resample(tarea,optim.learner,vc_externa)
#Promediamos el error
resultados$aggregate(measure=msr("classif.ce"))
#Error de clasificación final 0.261039  
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

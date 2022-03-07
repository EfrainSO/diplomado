####################################
#####   Data set Glass      ########
#####     Algoritmo         ########
##### Regresion Logistica   ########
#####  Efrain Soto Olmos    ########
####################################

library(tidyverse)
library(paradox)
library(mlr3learners) 
library(mlr3measures) 
library(mlr3verse)
library(mlr3tuning) 

#################################
#Carga de datos
datos<-read.csv("https://raw.githubusercontent.com/EfrainSO/diplomado/main/Proyecto%202/Glass/Glass.csv")
#transformación a factor la variable tipo_de_cristal
#Los agrupamos de tal forma que 1 seran cristal 1,2,3 y
#2 los crsitales 4,5,6 esto debido a los outliers
#ya que puede que sea mas facil identificarlos

#Agrupacion

datos[datos$tipo_de_cristal==1,]$tipo_de_cristal =1
datos[datos$tipo_de_cristal==2,]$tipo_de_cristal =1
datos[datos$tipo_de_cristal==3,]$tipo_de_cristal =1
datos[datos$tipo_de_cristal==4,]$tipo_de_cristal =2
datos[datos$tipo_de_cristal==5,]$tipo_de_cristal =2
datos[datos$tipo_de_cristal==6,]$tipo_de_cristal =2
table(datos$tipo_de_cristal)

datos$tipo_de_cristal<-as.factor(datos$tipo_de_cristal)
#Definimos la tarea
tarea<-TaskClassif$new(id="clas.logist",
                       backend=datos,
                       target="tipo_de_cristal",
                       positive = "2")
#Algoritmo
Log.Reg<-lrn("classif.log_reg", predict_type="prob")
#Validacion cruzada 
train.set<-sample(tarea$row_ids,0.8*tarea$nrow)
test.set<-setdiff(tarea$row_ids,train.set)  
#Entrenamiento
Log.Reg$train(tarea,train.set)
modelo<-Log.Reg$model
#Analisis de significancia
summary(modelo)
#Mediciones
pred<-Log.Reg$predict(tarea,test.set)
pred$score(measures = msr("classif.acc"))# exactitud
pred$score(measures=msr("classif.auc"))  # área bajo la curva ROC
pred$score(measures = msr("classif.ce")) # clasificación del error
pred$score(measures =msr("classif.tpr")) # sensibilidad
pred$score(measures =msr("classif.tnr")) # especificidad   
pred$confusion   # matriz de confusión

##############################################
#Seleccion de variables
cv<-rsmp("cv",folds=10)
#Cantidad de modelos a provar
evals100<-trm("evals",n_evals=100)
#Union de parametros
instancia<-FSelectInstanceSingleCrit$new(
  task =tarea,
  learner=Log.Reg,
  resampling=cv,
  measure = msr("classif.acc"),
  terminator=evals100
)
#Tipo de busqueda
filtro_select=fs("random_search")
#Busqueda
filtro_select$optimize(instancia)
#Variables seleccionadas
instancia$result_feature_set
#Desempeño predictivo
instancia$result_y
#Entrenamos con las variables seleccionadas
tarea$select(instancia$result_feature_set)
Log.Reg$train(tarea)
Log.Reg$model
summary(Log.Reg$model)
#######################################
#Validacion anidada
vc_externa<-rsmp("holdout", ratio=0.8)
#Union de parametros
auto_tuner<-AutoFSelector$new(
  learner=Log.Reg,
  resampling = rsmp("cv",folds=10),  # Val. cruzada  interna
  measure=msr("classif.acc"),
  terminator = trm("evals",n_evals=50),
  fselector=fs("random_search")
)
#Ejecutamos validacion
resultados<-resample(tarea,auto_tuner,vc_externa)
#Medidas
resultados$aggregate(measures = msr("classif.acc"))
#0.93
resultados$aggregate(measures=msr("classif.auc"))
#Entrenamiento del modelo final
modelo.final<-auto_tuner$train(tarea)

#Predicciones
modelo.final$predict_newdata(datos)  # Entre paréntesis se coloca la base de datos nuevos 














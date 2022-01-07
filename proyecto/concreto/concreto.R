#librerias
library(paradox)
library(mlr3learners) 
library(mlr3measures) 
library(mlr3tuning)   


#lectura de datos
datos<-read.csv("https://raw.githubusercontent.com/EfrainSO/diplomado/main/proyecto/concreto.csv")

#Analisis de las variables
str(datos)
summary(datos)
skimr::skim(datos)
#revision de datos faltantes
purrr::map_dbl(datos,~sum(is.na(.)))
#datos atipicos, cambiando el numero se cambia la columna
boxplot(datos[,9], horizontal = TRUE)
# install.packages("corrplot") si hace falta, esto muestra la correlacion
#entre las variables
corrplot::corrplot(cor(datos))

#Preprocesamiento de los datos
#cambio de nombre de las columnas
colnames(datos)<-c("cemento","escoria","ceniza","agua","superplastificantes",
                   "granular_gruezo","granular_fino","edad","fuerza")
    #opcional estandarizacion no mejora el modelo
    #funcion para noramlizar los datos
    min.max <- function(v)
    {
        return ((v-min(v))/(max(v)-min(v)))
    }
    datos<-mutate_at(datos,c("cemento","escoria","agua","superplastificantes",
                         "granular_gruezo","granular_fino","edad"),min.max)
    




#Construccion del algoritmo tipo regresion
#tarea
tarea<-TaskRegr$new(id="concret", backend=datos, target="fuerza")

#algoritmo
clasif.knn<-lrn("regr.kknn")

# Calibración del algoritmo, parametros a cambiar:
espacio_soluciones<-ParamSet$new(list(ParamInt$new("k",1,15),
                                      ParamInt$new("distance",1,5),
                                      ParamFct$new("kernel",c("inv","optimal")),
                                      ParamLgl$new("scale")))
#tipo de busqueda, probar todos
tipo_busqueda<-mlr3tuning::tnr("grid_search")
#tipo de division de datos validacion cruzada repetida
cv<-rsmp("repeated_cv",folds=10,repeats=5)
#union de todos los parametros anteriores
instancia_busqueda=TuningInstanceSingleCrit$new(task=tarea,
                                                learner = clasif.knn,
                                                resampling=cv,
                                                measure = msr("regr.mse"),
                                                search_space = espacio_soluciones,
                                                terminator=trm("none"))      
#activar todos los nucleos
future::plan("multisession")
#ejecutar busqueda de los hiperparametros
tipo_busqueda$optimize(instancia_busqueda)

#Mejor modelo que encontro
instancia_busqueda$archive$best()

#opcional----- guardar los resultados de todas las pruebas
resultado<-instancia_busqueda$archive$data
 #ordenando de mejor a mayor
 ordenado<-resultado[order(resultado$regr.mse),]
 #eliminar las columnas inutiles
 ordenado[,6:10]<-list(NULL)
 #guardar los resultados en un archivo
 write.csv(ordenado,"/home/efrain/Escritorio/diplomado csv/concreto/hiper1,15,1,3,todos.csv")
 #tomando los primeros 20 modelos para ver las mejores configuraciones
 min(ordenado[1:20,]$k)
 max(ordenado[1:20,]$k)
 #para k es de 4-12
 unique(ordenado[1:20,]$kernel)
 #y unicamente aparece el kernel "inv"
 #se cambiara el espacio de soluciones con la informacion obtenida
 #

#validacion anidada
 #construcion del segundo algoritmo--opcional, puede usarse el primero
 regre2<-lrn("regr.kknn",kernel="inv")
 #espacio_2---opcional, puede usarse el primero
 espacio2<-ParamSet$new(list(ParamInt$new("k",4,12),
                              ParamInt$new("distance",1,5),
                              ParamLgl$new("scale")))
#inicio de validacion anidada como en calse
vc_externa<-rsmp("cv", folds=10) # Val cruzada externa
vc_interna<-rsmp("repeated_cv", folds=10, repeats=5)#val cruzada interna
#seleccion del mejor modelo en validacion cruzada anidada
optim.learner<-AutoTuner$new(learner=regre2,
                             vc_interna,msr("regr.mse"), 
                             espacio2,
                             terminator = trm("none"),
                             tuner=tipo_busqueda)
#activacion de los nucleos
future::plan("multisession")
#ejecucion de la parte externa
resultados<-resample(tarea,optim.learner,vc_externa)
#Medicion de los resultados
resultados$aggregate(measures=msr("regr.mse"))
        #61.01342 como resultado personal
        #59.52152 con datos estandarizados

#entrenamiento del modelo final
modelo_final<-optim.learner$train(tarea)
optim.learner$archive$best()
optim.learner$archive


resultado2<-optim.learner$archive$data
#ordenando de mejor a mayor
ordenado2<-resultado2[order(resultado2$regr.mse),]
#eliminar las columnas inutiles
ordenado2[,6:10]<-list(NULL)


#modelo final con 4 vecinos, medida 3 y la escala activada
#mismo modelo con

# El modelo entrenado, lo guardamos en un archivo para
# emplearlo posteriormente para hacer predicciones.

# Utilizamos saveRDS(objeto_a_guardar, "nombre y ruta del archivo")
saveRDS(modelo_final,"/home/efrain/Escritorio/diplomado csv/concreto/modelo_stan")


#librerias
library(paradox)
library(mlr3learners) 
library(mlr3measures) 
library(mlr3tuning)



#lectura de datos
datos<-read.csv("https://raw.githubusercontent.com/EfrainSO/diplomado/main/proyecto/glass_mod.csv")

#Analisis de las variables
str(datos)
summary(datos)
skimr::skim(datos)
#revision de datos faltantes, no se encontraron datos faltantes
purrr::map_dbl(datos,~sum(is.na(.)))

#Preprocesamiento de los datos
#recoding de la variable a predecir

datos$tipo_de_cristal<-dplyr::recode(datos$tipo_de_cristal,
                                     "1"=1, "2"=2, "3"=3, "4"=4,
                                     "5"=4, "6"=5,"7"=6)
#como factor
datos$tipo_de_cristal<-factor(datos$tipo_de_cristal)
#eliminar indices
datos$ID<-NULL

#datos atipicos, se encontraron muchos datos atipicos
boxplot(datos[,3], horizontal = TRUE)

outliers<-c(match(boxplot.stats(datos[,1])$out,datos[,1]),
  match(boxplot.stats(datos[,2])$out,datos[,2]),
  match(boxplot.stats(datos[,3])$out,datos[,3]),
  match(boxplot.stats(datos[,4])$out,datos[,4]),
  match(boxplot.stats(datos[,5])$out,datos[,5]),
  match(boxplot.stats(datos[,6])$out,datos[,6]),
  match(boxplot.stats(datos[,7])$out,datos[,7]),
  match(boxplot.stats(datos[,8])$out,datos[,8]),
  match(boxplot.stats(datos[,9])$out,datos[,9]))


unique(outliers) #mas de 60 datos outliers unicos
length(outliers) #137 datos outliers
#tabla de frecuencia
df<-as.data.frame(table(outliers))
#dataframe de outliers
datos_out<-datos[unique(outliers),]
#numero de outliers pertenecientes a las clase 6
#la mayoria los datos clase 6 y 4 los detecta como datos outliers,
#debido a la cantidad de clase 1
df_3<-as.data.frame(table(datos_out$tipo_de_cristal))
df_2<-as.data.frame(table(datos$tipo_de_cristal))
#por lo que no se quitaran los datos outliers

#correlacion entre las variables
corrplot::corrplot(cor(datos))
#fuerte relacion entre el calcio y el indice de refraccion


#opcional estandarizacion
#funcion para noramlizar los datos
min.max <- function(v)
{
  return ((v-min(v))/(max(v)-min(v)))
}
colnames(datos)
datos<-dplyr::mutate_at(datos,c("Indice_refraccion","sodio","magnesio",
                         "aluminio","silicio","potasion",
                         "calcio","bario","hierro"),min.max)

#Construccion del algoritmo tipo regresion
#tarea
tarea<-TaskClassif$new(id="glass", backend=datos, target="tipo_de_cristal")

#algoritmo
clasif.knn<-lrn("classif.kknn")

# Calibración del algoritmo, parametros a cambiar:
espacio_soluciones<-ParamSet$new(list(ParamInt$new("k",1,15),
                                      ParamInt$new("distance",1,3),
                                      ParamFct$new("kernel",c("rectangular","triangular","gaussian","inv","optimal")),
                                      ParamLgl$new("scale")))
#tipo de busqueda, probar todos
tipo_busqueda<-mlr3tuning::tnr("grid_search")
#tipo de division de datos validacion cruzada repetida
cv<-rsmp("repeated_cv",folds=10,repeats=5)
#union de todos los parametros anteriores
instancia_busqueda=TuningInstanceSingleCrit$new(task=tarea,
                                                learner = clasif.knn,
                                                resampling=cv,
                                                measure = msr("classif.ce"),
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
ordenado<-resultado[order(resultado$classif.ce),]
#eliminar las columnas inutiles
ordenado[,6:10]<-list(NULL)
#mejor modelo estandarizado 5 vecinos 1 metrica
#scale true, disntancia "inv"
#guardar los resultados en un archivo
write.csv(ordenado,"/home/efrain/Escritorio/diplomado csv/glass/hiper1,15,1,3,todos_stand.csv")
#tomando los primeros 20 modelos para ver las mejores configuraciones
min(ordenado[1:20,]$k)
max(ordenado[1:20,]$k)
#para k es de 1-7 no estandarizado
unique(ordenado[1:20,]$kernel)
#todos los kernels y diatancias 1 y 2
#se cambiara el espacio de soluciones con la informacion obtenida


#la diferencia entre la estandarizacion y la que no
#es apenas notable, pero se preferira la estandarizada
#devido a que es mas uniforme en cuanto a los vecinos
#y tiene la mejor metrica


#validacion anidada
#construcion del segundo algoritmo--opcional, puede usarse el primero
regre2<-lrn("classif.kknn",distance=1)
#espacio_2---opcional, puede usarse el primero
espacio2<-ParamSet$new(list(ParamInt$new("k",4,5),
                            ParamFct$new("kernel",c("triangular","gaussian","inv","optimal")),
                            ParamLgl$new("scale")))
#inicio de validacion anidada como en calse
vc_externa<-rsmp("cv", folds=10) # Val cruzada externa
vc_interna<-rsmp("repeated_cv", folds=10, repeats=5)#val cruzada interna
#seleccion del mejor modelo en validacion cruzada anidada
optim.learner<-AutoTuner$new(learner=regre2,
                             vc_interna,msr("classif.ce"), 
                             espacio2,
                             terminator = trm("none"),
                             tuner=tipo_busqueda)
#activacion de los nucleos
future::plan("multisession")
#ejecucion de la parte externa
resultados<-resample(tarea,optim.learner,vc_externa)
#Medicion de los resultados
resultados$aggregate(measures=msr("classif.ce"))
#0.2714286 como resultado personal

#entrenamiento del modelo final
modelo_final<-optim.learner$train(tarea)
optim.learner$archive$best()
#modelo final con 7 vecinos, medida 1 y la escala activada

ultimo<-optim.learner$archive$data
ordenado2<-ultimo[order(ultimo$classif.ce),]
#eliminar las columnas inutiles
ordenado2[,5:9]<-list(NULL)

# El modelo entrenado, lo guardamos en un archivo para
# emplearlo posteriormente para hacer predicciones.

# Utilizamos saveRDS(objeto_a_guardar, "nombre y ruta del archivo")
saveRDS(modelo_final,"/home/efrain/Escritorio/diplomado csv/glass/modelo")


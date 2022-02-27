#librerias

#lectura de datos
datos<-read.csv("https://raw.githubusercontent.com/EfrainSO/diplomado/main/proyecto/glass/glass_mod.csv")

#Analisis de las variables
str(datos)
#todas las variables son de tipo numerico continuo excepto la
#variable a predecir
summary(datos)
#La variable mas grande es el silicio
skimr::skim(datos)
#son 214 datos 11 columnas

#revision de datos faltantes, no se encontraron datos faltantes
purrr::map_dbl(datos,~sum(is.na(.)))


#############################################################
#Preprocesamiento de los datos
#recoding de la variable a predecir

datos$tipo_de_cristal<-dplyr::recode(datos$tipo_de_cristal,
                                     "1"=1, "2"=2, "3"=3, "4"=4,
                                     "5"=4, "6"=5,"7"=6)
#como factor
datos$tipo_de_cristal<-factor(datos$tipo_de_cristal)
#eliminar indices
datos$ID<-NULL


#guardamos los datos modificados
#write.csv(datos,"Glass.csv",row.names= FALSE)
############################################################


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

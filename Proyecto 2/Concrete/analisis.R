#lectura de datos
datos<-read.csv("https://raw.githubusercontent.com/EfrainSO/diplomado/main/proyecto/concreto/concrete_data.csv")

#Analisis de las variables
str(datos)
summary(datos$Strength)
skimr::skim(datos)
#revision de datos faltantes
purrr::map_dbl(datos,~sum(is.na(.)))
#datos atipicos, cambiando el numero se cambia la columna
boxplot(datos[,9], horizontal = TRUE, col = "orange")

#Preprocesamiento de los datos
#cambio de nombre de las columnas
colnames(datos)<-c("cemento","escoria","ceniza","agua","superplastificantes",
                   "granular_gruezo","granular_fino","edad","fuerza")
#guardamos los datos modificados
write.csv(datos,"concreto.csv",row.names = FALSE)


#opcional estandarizacion no mejora el modelo
#funcion para noramlizar los datos
min.max <- function(v)
{
  return ((v-min(v))/(max(v)-min(v)))
}
datos<-mutate_at(datos,c("cemento","escoria","agua","superplastificantes",
                         "granular_gruezo","granular_fino","edad"),min.max)




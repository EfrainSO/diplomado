# Bosting

Con la técnica de bagging los modelos individuales son entrenados en paralelo. Por el contrario,
con el boosting, los modelos se van construyendo de manera secuencial. Cada nuevo modelo busca
corregir los errores de los modelos previos.

La función del boosting es combinar muchos modelos débiles para que en colectivo se construya
un modelo muy fuerte (La unión hace la fuerza). La razón de usar modelos débiles cuando usamos
boosting es que, si usamos modelos fuertes, en colectivo la mejoría en la predicción obtenida
es muy poca comparada con el uso de modelos débiles, así que entonces por qué gastar tiempo de
cómputo en la construcción de modelos muy complejos o fuertes cuando podemos obtener el mismo
desempeño empleando modelos más simples o menos complejos.

Los dos métodos más empleados de boosting son:

1.- Adaptative boosting 2.- Gradiente boosting

## Adaptative boosting

Inicialmente, todos los datos en el conjunto de entrenamiento tiene la misma importancia o peso.
Un primer modelo se entrena empleando una muestra bootstrap del conjunto de entrenamiento con la 
salvedad de que la probabilidad de seleccionar una observación en particular es proporcional a su
peso. Los casos que este primer modelo clasificó de manera incorrecta se les da ahora más
peso/importancia, mientras que los casos que fueron clasificados correctamente se les asigna menos
peso/importancia.

El siguiente modelo toma otra muestra boostrap del conjunto de entrenamiento, pero ahora los pesos
ya no son los mismos, se han modificado de acuerdo a los errores de clasificación del modelo previo.
De este modo, casos que fueron incorrectamente clasificados en el modelo previo, tienen ahora mayor
probabilidad de ser seleccionados. Los modelos subsecuentes deben por lo tanto, aprender mejores reglas
para clasificar correctamente estos casos.

Una vez que tenemos al menos dos modelos, los datos se clasifican agregando las predicciones de cada uno
de los modelos individuales, igual que en el bagging. Casos que fueron clasificados de manera incorrecta
por la mayoría de modelos previos se les asigna ahora mayor peso/importancia y casos correctamente
clasificados por la mayoría de los modelos se les asigna menos peso/importancia.

## Gradient boosting

Grandient Boosting es muy similar al boosting adaptativo, solo difieren en la forma en que tratan de
corregir los errores del modelo previo. En el caso de Gradient Boosting se trata de minimizar los
residuales (error residual) observados en el modelo previo, en el caso de una variable objetivo continua,
el error residual equivale a la diferencia entre lo observado y la predicho, para el caso dela variables
objetivo discretas, puede ser la proporción de casos incorrectamente clasificados. Aunque también se puede
interpretar a través de la log pérdida.

De este modo, gradient boosting, genera modelos que van minimizando el error residual, lo cual favorece
la correcta clasificación de casos que fueron previamente mal clasificados. Si se entrena cada modelo
en una muestra aleatoria (sin reemplazo, i.e no es tipo bootstrap) entonces se tiene el algoritmo gradient
boosting estocástico. Aunque en general, siempre es una buena idea muestrear sobre el conjunto de datos
de entrenamiento, pues esto reduce la varianza.

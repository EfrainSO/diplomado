# Algoritmo de red neuronal para el data set de clasificacion glass
Se provaron diferentes nodos para las capa oculta de la red neuronal, utilizando una validacion
cruzada de 10 partes, y promediando los errores de clasificación con
matriz de confusion

# Resultados
|Nodos|CE|
|4|0.4668571 |
|5|0.4280000 |
|6|0.4668571|
|7|0.3954286 |
|8|0.3533333 |
|9|0.3803810 |
|10|0.3676190 |
|11|0.3914286|

Mientras mas nodos se emplean menos tiempo tarde el algoritmo en entrenar

Para los 11 nodos la validacion cruzada fue de solo unos minutos, claro que no
se presta para muchos analisis con muchos cambios, ya que su uso en un bucle es
extremadamente tardado, por ejemplo en la seleccion de hyperparametros o variables.

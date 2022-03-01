# Arboles de desición basados en la teoria de la información

 ### Si no definimos limites para el árbol, entonces nuestro proceso tendrá un 100% de precisión en el conjunto de datos de entrenamiento, en el peor de los casos, un caso en cada hoja. Para evitar esta situación se puede proceder de la siguiente forma:

1.- Restricciones en el tamaño del árbol.

2.- Podar el árbol.

Caso 1. Pre-poda. Restricciones en el tamaño.

minsplit : Define el mínimo número de casos en un nodo antes de ramificar, es decir el número mínimo de observaciones que debe tener un nodo para poder ser dividido. Cuanto mayor sea el valor, menos flexible es el modelo (esto puede causar un pobre ajuste del modelo), pero a la vez valores grandes previenen que el modelo aprenda relaciones muy especificas. El valor de este hiper-parámetro entonces se debe ajustar empleando validación cruzada.

maxdepth : Profundidad máxima del árbol, entendiendo por profundidad máxima el número de divisiones de la rama más larga (en sentido descendente) del árbol. Nuevamente, entre más profundo sea el árbol, habrá un mayor sobreajuste. Se debe emplear la validación cruzada.

minbucket : Mínimo número de casos en cada hoja (nodo terminal). Define el número mínimo de observaciones que deben tener los nodos terminales. Su efecto es muy similar al de observaciones mínimas para división. Se puede emplear en lugar de la profundidad. Si al momento de dividir un nodo las hojas que tengan menos que minbucket entonces el nodo no se divide.

cp Parámetro de complejidad del árbol. El cp es un estadístico que se calcula en cada nivel del árbol, si el cp en un nivel del árbol es menor al umbral elegido, entonces ya los nodos no se dividirán, esto es, agregar otra capa al árbol no mejora el desempeño del modelo. El cp se calcula como:

cp=Pr(Incorrectt+1)−Pr(Incorrectt)n(splitst)−n(splitst+1)
donde p(incorrectl) es la proporción de casos mal clasificados al nivel de profundidad l, y n(splits) es el número de divisiones a la profundidad l

## Ventajas del Método:
La construcción intuitiva de un árbol de decisión es muy sencilla.

Interpretabilidad, Se puede construir fácilmente un conjunto de reglas para tomar decisiones.

Puede manejar indistintamente covariables continuas y categóricas.

No requiere supuestos adicionales sobre la distribución de la variable de respuesta.

No requiere mucho tiempo de cómputo.

## Desventajas:
Es un tipo de clasificación “débil” pues los resultados varían mucho dependiendo de la muestra empleada para entrenar el modelo.

Es muy fácil de sobreajustar, esto es, que pueden ser excelentes para clasificar los datos que conocemos, pero deficientes para los datos desconocidos.

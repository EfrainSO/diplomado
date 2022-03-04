# Random Forest
La idea del bagging es relativamente simple:

Decidir cuántos submodelos se van a entrenar.

Cada submodelo se entrena a partir de una muestra de tamaño fijo extraída del conjunto de datos original con reemplazo.

Entrenar los submodelos en cada una de las muestras obtenidas en el paso 2.

Pasar los nuevos datos por el modelo entrenado y obtener las predicciones.

La predicción más frecuente o promedio de las predicciones individuales se emplea como predicción final.

El bagging es una técnica muy similar a promediar modelos, que se aplica en técnicas de Machine Learning que sufren de problemas
de bajo sesgo o varianza alta, tal como los árboles de decisión. De hecho, la más famosa aplicación del bagging para árboles de 
decisión es la técnica llamada bosques aleatorios.

La técnica de bosques aleatorios usa el bagging para crear un gran número de árboles. Un truco adicional de la técnica de bosques
aleatorios es que el algoritmo en cada uno de los nodos selecciona una fracción de las variables predictoras que serán las que
considera para realizar la nueva división. El resultado de esta selección aleatoria es que los árboles estarán altamente incorrelacionados.

En efecto, si existen covariables que tengan un alto poder predictivo, estas variables serán seleccionadas por muchos de los
árboles para hacer sus predicciones. Lo cual no tiene mucho beneficio a nivel de información, es decir “casi” tendríamos árboles
idénticos. Es por esta razón que resulta más efectivo tener árboles que no estén correlacionados, de modo que árboles diferentes
contribuyan a realizar predicciones diferentes.

## Hyperparametros
El hiperparametro que mas se vigila es el nuemero de arboles que se utilizan en el bosque, y estos se miden por una grafica,
la grafica del OOB error, que mide el error de cada una de las posibilidades en la seleccion de categorias, esto debido a que,
el random forest utiliza el bootstraping, por lo que en algunos arboles no aparecen estas categorias o aparecen en menor medida,
y el error de clasificacion en esos arboles para esas variables es mayor que en el resto, y lo nivelamos añadiendo mas arboles,
por eso observamos la grafica del  OOB error, para elegir la cantidad de arboles adecuada.

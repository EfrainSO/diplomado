# Redes Neuronales
Las redes neuronales son modelos simples del funcionamiento del sistema nervioso.
Las unidades básicas son las neuronas, que generalmente se organizan en capas.

Las unidades de procesamiento se organizan en capas. Hay tres partes normalmente
en una red neuronal : una capa de entrada, con unidades que representan los campos
de entrada; una o varias capas ocultas; y una capa de salida, con una unidad o 
unidades que representa el campo o los campos de destino. Las unidades se conectan
con fuerzas de conexión variables (o ponderaciones). Los datos de entrada se
presentan en la primera capa, y los valores se propagan desde cada neurona hasta
cada neurona de la capa siguiente. al final, se envía un resultado desde la
capa de salida.

La red aprende examinando los registros individuales, generando una predicción
para cada registro y realizando ajustes a las ponderaciones cuando realiza
una predicción incorrecta. Este proceso se repite muchas veces y la red
sigue mejorando sus predicciones hasta haber alcanzado uno o varios criterios
de parada.

Al principio, todas las ponderaciones son aleatorias y las respuestas que
resultan de la red son, posiblemente, disparatadas. La red aprende a través
del entrenamiento. Continuamente se presentan a la red ejemplos para los
que se conoce el resultado, y las respuestas que proporciona se comparan
con los resultados conocidos. La información procedente de esta comparación
se pasa hacia atrás a través de la red, cambiando las ponderaciones
gradualmente. A medida que progresa el entrenamiento, la red se va haciendo
cada vez más precisa en la replicación de resultados conocidos. Una
vez entrenada, la red se puede aplicar a casos futuros en los que se 
desconoce el resultado.

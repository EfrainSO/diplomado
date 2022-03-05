# Uso del algoritmo xboost que es un derivado del random forest

Parametros tuneados en el entrenado

-eta (learning rate): contracción del tamaño de paso usado para prevenir el sobreajuste. Despues de cada boost podemos tener el pero de nuevas caracteristicas,
el hiperparametro eta contra ese peso para hacer el boosting mas conservativo. Default 0.3, rango= [0,1]

-gamma(perdida dividida minima): minimo información para poder particionar una hoja ( al menos eso parece ser), justo como un arbol de desición. Default =0 range =0,inf

-max_depht: maxima profundidad del arbol. Default = 6, rango=0,inf

-min_child_weight: si se parte una hoja de un arbol y la suma de los pesos es menos que este valor, entonces se seguira partiendo. Deafult = 1, rango=0,inf

-colsample_bytree: significa que la sumuestra se escogera para cada arbol, puede escogerse tambien colsample_bytree, colsample_bylevel, colsample_bynode [default=1]
rango=0,1

-eval_metric [default according to objective]


-eval_metric: Metrica de evaluación par validadcion de la información:

logloss: negative log-likelihood

error: Error de clasificación binario.

Para mas información de los hyperparametros busque

(https://xgboost.readthedocs.io/en/stable/parameter.html)

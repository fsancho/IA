# Librerías Auxiliares IA

En lo que sigue:

* `N`: Número
* `B`: Booleano
* `L`: Lista
* `T`: Tabla
* `S`: Conjunto
* `Df`: Dataframe
* `x`: Genérico
* `f`: Fichero
* `s`: Cadena
* `(R) Func P1 ... Pn`: `Func` recibe `n` datos de entrada (de tipos `P1`, ..., `Pn`) y devuelve un dato de tipo `R`.

## Sets

Librería para trabajar con conjuntos:

`set:from-list`, `set:empty`, `set:size`, `set:add`, `set:remove`, `set:member?`, `set:one-of`, `set:subset?`, `set:is-set?`, `set:equal?`, `set:is-empty?`, `set:union`, `set:intersection`, `set:dif`, `set:sym-dif`, `set:power`


* Convierte una lista en conjunto: `(S) set:from-list L`
* Conjunto vacío: `(S) set:empty`
* Tamaño: `(N) set:size S`
* Operaciones con elementos:
  * Añadir elemento a conjunto: `(S) set:add x S`
  * Elimina elemento de conjunto: `(S) set:remove x S`
  * Pertenencia: `(S) set:member? x S`
  * Elección: `(X) set:one-of S`
* Predicados:
  * Subconjunto: `(B) set:subset? S1 S2`
  * Es conjunto: `(B) set:is-set? S`
  * Igualdad: `(B) set:equal? S1 S2`
  * Vacío: `(B) set:is-empty? S`
* Operaciones entre conjuntos:
  * Unión: `(S) set:union S1 S2`
  * Intersección: `(S) set:intersection S1 S2`
  * Diferencia: `(S) set:dif S1 S2`
  * Diferencia Simétrica:  `(S) set:sym-dif S1 S2`
  * Conjunto Potencia: `(S) set:power S`

## DataFrame

Librería para trabajar con DataFrames:

`DF:load`, `DF:save, DF:header, DF:data`, `DF:first`, `DF:last`, `DF:n-of`, `DF:shape`, `DF:pp`, `DF:ren-col`, `DF:add-col`, `DF:move-col`, `DF:add-calc-col`, `DF:col`, `DF:value`, `DF:sort-col`, `DF:filter`, `DF:map`, `DF:foreach`, `DF:col-values`, `DF:filter-col`, `DF:rem-col`, `DF:shuffle`, `DF:split`, `DF:sort-by`, `DF:enum`, `DF:Cat2NumDep`, `DF:Cat2NumIndep`, `DF:Bin2NumDep`, `DF:Bin2NumIndep`,  `DF:scale`, `DF:normalize`, `DF:summary` 

* Carga un CSV en un DF: `(Df) DF:load f`
* Graba un DF en un CSV: `() DF:save Df f`
* Muestra el DF en el Centro de Comandos: `DF:show Df`
* Pretty Print de un DF (cadena para imprimir): `(s) DF:pp Df`
* Resumen del DF: `() DF:summary Df`
* Recuperación: (`cn`: column name)

  * Cabecera: `(L) DF:header Df`
  * Datos: `(L) DF:data Df`
  * `N` primeras filas: `(L) DF:first N Df`
  * `N` últimas filas: `(L) DF:last N Df`
  * `N` filas al azar: `(L) DF:n-of N Df`
  * Una columna (datos): `(L) DF:col cn Df`
  * Valores (sin duplicados) de `cn`: `(L) DF:col-values cn Df`
  * Valor de una columna en una fila: `(X) DF:value cn row Df`
  * Forma (`N1` filas x `N2` columnas): `([N1 N2]) DF:shape Df`
* Modificación Columnas:

  * Cambia nombre de una columna: `(Df) DF:ren-col old-cn new-cn Df`
  * Añade nueva columna con contenido: `(Df) DF:add-col cn cont Df`
  * Añade nueva columna calculada: `(Df) DF:add-calc-col cn f Df`
  * Elimina columna: `(Df) DF:rem-col cn Df`
  * Filtra filas con valor `val` en `cn`: `(Df) DF:filter-col cn val Df`
  * Ordena las filas según `cn`: `(Df) DF:sort-col cn Df`
  * Cambia una columna de posición (`pos` se calcula sin `cn`): `(DF) DF:move-col cn pos Df`
* Modificación Dataframe:

  * Filtra las filas verificando `f`: `(Df) DF:filter f Df`
  * Aplica `f` a todas las filas: `(L) DF:map f Df`
  * Ejecuta una acción `f` a cada fila: `() DF:foreach Df f`
  * Reordena al azar las filas: `(Df) DF:shuffle Df`
  * Split aleatorio (`r` $\in [0,1]$), `r|(1-r)`: `([Df1 Df2]) DF:split r Df`
  * Ordena las filas usando una función `f`: `(Df) DF:sort-by f Df`
  * Añade una columna con enumeración: `(Df) DF:enum Df`
  * Categórica a Numérica: 
    * `(DF) DF:Cat2NumDep cn Df`
    * `(DF) DF:Cat2NumIndep cn Df`
  * Binaria a Numérica: 
    * `(DF) DF:Bin2NumDep cn Df`
    * `(DF) DF:Bin2NumDep cn Df`
  * Normalización (no comprueba que los datos sean numéricos, ni maneja datos faltantes):
    * Escala lineal: escala los valores de `cn` para que tomen los valores en $[a,b]$: `(DF) DF:scale cn a b Df`
    * Normal: escala los valores de `cn` para seguir una normal $N(0,1)$: `(DF) DF:normalize cn Df`
  

## Patrones Funcionales

Librería para manipular estructuras de forma funcional.

### Apply

`__apply`, `__apply-result`

* Para procedimientos: `__apply f [a1 ... an] = (f a1 ... an)`
* Para reports: `__apply-result f [a1 ... an] = (f a1 ... an)`

### Listas

`take`, `takewhile`, `drop`, `dropwhile`, `zip`

* Toma los `N` primeros elementos: `(L) take N L`
* Toma los primeros elementos mientras verifiquen `f`: `(L) takewhile f L`
* Quita los `N` primeros elementos: `(L) drop N L`
* Quita los primeros elementos mientras verifiquen `f`: `(L) dropwhile f L`
* Zip de dos listas: `([X,X]) zip L1 L2`

### Tablas

`table:foreach`, `table:map`, `table:filter`

* Ejecuta `f` en cada `[k v]` de la tabla: `() table:foreach T f`
* Aplica `f: [k v] -> [k' v']` a la tabla: `(T) table:map f T`
* Filtra los `[k v]` que verifican `f: [k v] -> B`: `(T) table:filter f T`

### Cadenas

`string:to-list`, `string:foreach`, `string:map`, `string:filter`, `string:upto`, `string:from`, `string:split-by`

* Convierte una cadena en lista de caracteres: `(L) string:to-list s`

* Ejecuta `f` a cada carácter de la cadena: `() string:foreach s f`

* Aplica `f` a cada carácter de la cadena: `(L) string:map f s`

  (si `f: char -> char`, reduciendo con `word` se obtiene una cadena)

* Filtra los caracteres de una cadena con `f`: `(s) string:filter f s`

* Subcadena inicial: `(s) string:upto N S`

* Subcadena final: `(s) string:from N s`

* Divide la cadena en una posición: `([s1 s2]) string:split-by N s`

  
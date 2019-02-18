globals [
  final-x
  final-y
  dis-carreras
  dis-calles
]
patches-own [
  esCalle?
  esCarrera?
  esCasa?
  esFinal?
  pintado?
  quemado?
  nivelGas
  nivelFuego
]
breed [lideres lider]
breed [policias policia]
breed [estudiantes estudiante]
estudiantes-own[papa? pintura? aguante]

to setup
  ca
  set final-x max-pxcor
  set final-y max-pycor
  set dis-calles int (world-width / (num-calles - 1))
  set dis-carreras int (world-height / (num-carreras - 1))
  ;;Pintar las cuadras
  ask patches [
    set esCasa? true
    set esFinal? false
    set esCalle? false
    set esCarrera? false
    set pintado? false
    set quemado? false
    set nivelGas 0
    set nivelFuego 0

    if ((pxcor mod dis-calles < ancho-calzada) or (pxcor >= world-width - ancho-calzada))[
      set esCalle? true
      set esCasa? false
    ]

    if ((pycor mod dis-carreras < ancho-calzada ) or (pycor >= world-height - ancho-calzada))[
      set esCarrera? true
      set esCasa? false
    ]

    if(pxcor >= final-x and pycor >= final-y)[
      set esFinal? true
      set esCasa? false
    ]
  ]

  pintarCalles

  ;;Creación de Lider Estudiantil
  create-lideres 1 [
    set shape  "person"
    set color orange
    set size 1
    set label-color blue - 2
    setxy 0 6
    set heading 0
  ]

  ;;Creación de estudiantes
  create-estudiantes (num-estudiantes - 1) [
    set shape  "person"
    set color yellow
    set size 1
    set label-color blue - 2
    setxy (who * 1 mod ancho-calzada) (6 - int (who / ancho-calzada) mod 6)
    set heading 0

    ;;Probabilidad de llevar pintura
    ifelse (random 100 < porcentaje-pintura)[
      set pintura? true
    ][
      set pintura? false
    ]

    ;;Probabilidad de llevar Papas bomba
    ifelse (random 100 < procentaje-papas)[
      set papa? true
    ][
      set papa? false
    ]
  ]

  ;;Creación de policias del esmad
  create-policias (num-esmad / 100 * num-estudiantes) [
    set shape  "person police"
    set color green
    set size 1
    set label-color blue - 2
    setxy (who * 1 mod ancho-calzada) (20 + int (who / ancho-calzada ) mod 10)
    set heading 90
  ]

  reset-ticks
end

to pintarCalles
  ask patches [
    if esCalle? [set pcolor black]
    if esCarrera? [set pcolor black]

    ifelse (nivelGas >= nivelFuego)
    [if(nivelGas > 0.05) [set pcolor scale-color yellow nivelGas 0.01 1]]
    [if(nivelFuego > 0.05) [set pcolor scale-color red nivelFuego 0.01 1]]

    if esFinal? [set pcolor white]
    if esCasa? [set pcolor gray]
    if esCasa? and quemado?  [set pcolor red]
    if pintado?  [set pcolor blue]
    ;;if pintado?  [set pcolor one-of [blue green cyan orange]]
  ]
end

to do
  ;if (all? lideres [xcor > final-x and ycor > final-y] and all? estudiantes [xcor > final-x and ycor > final-y])
   ; [ stop ]

  ask lideres [
    ifelse (xcor >= final-x and ycor >= final-y) [ stop ]
    [moverLider]
  ]

  ask estudiantes [
    ifelse (xcor >= final-x and ycor >= final-y) [ stop ]
    [
      seguirLider
      pintar
      explotar
    ]
  ]

  diffuse nivelGas 0.4
  diffuse nivelFuego 0.4
  ask patches
  [
    if (nivelFuego > 0.05) [set quemado? true ]
    set nivelGas nivelGas * 0.8
    set nivelFuego nivelFuego * 0.7
  ]

  pintarCalles
  tick
end

to moverLider
  facexy final-x final-y

  ;;if ([nivelGas] of patches in-radius 3)
  ;;[facexy (- final-x) (- final-y)]

  let orientacion int (heading / 90)

  ifelse (esCalle? and esCarrera?) [
    ifelse (random 100 < 50)
    [
      ifelse(orientacion = 1 or orientacion = 2)
      [moverAbajo true]
      [moverArriba true]
    ]
    [
      ifelse(orientacion = 0 or orientacion = 1)
      [moverDerecha true]
      [moverIzquierda true]
    ]
  ][
    if esCalle? [
      ifelse(orientacion = 0 or orientacion = 4)
      [moverArriba true]
      [moverAbajo true]
    ]
    if esCarrera? [
      ifelse(orientacion = 0 or orientacion = 1)
      [moverDerecha true]
      [moverIzquierda true]
    ]
  ]
end

to seguirLider
  ifelse (([nivelGas] of patch-here) > 0.04)
  [ huirGas false ]
  ;[]
  [face turtle 0]

  let orientacion int (heading / 90)

  if esCalle? [
    ifelse(orientacion = 0 or orientacion = 3)
    [moverArriba false]
    [moverAbajo false]
  ]

  if esCarrera? [
    ifelse(orientacion = 0 or orientacion = 1)
    [moverDerecha false]
    [moverIzquierda false]
  ]
end

to pintar
  if ( pintura? and random 100 > 95)[
    if( ycor < max-pycor - 1 and [esCasa?] of patch-at 0 1 )[
      ask patch-at 0 1 [ask patches in-radius 1 [if esCasa? [set pintado? true]]]
    ]

    if( ycor > 1 and [esCasa?] of patch-at 0 -1 )[
      ask patch-at 0 -1 [ask patches in-radius 1 [if esCasa? [set pintado? true]]]
    ]

    if( xcor < max-pxcor and [esCasa?] of patch-at 1 0)[
      ask patch-at 1 0 [ask patches in-radius 1 [if esCasa? [set pintado? true]]]
    ]

    if( xcor > 1 and [esCasa?] of patch-at -1 0)[
      ask patch-at -1 0 [ask patches in-radius 1 [if esCasa? [set pintado? true]]]
    ]

    alertar
    stop
  ]
end

to explotar
  if ( papa? and random 100 > 95)[
    ask patch-here [set nivelFuego 60]
    alertar
    stop
  ]
end

to alertar
  ask policias [
    if ( random 100 > tolerancia-esmad )[
      disparar
    ]
  ]
end

to disparar
  let estudianteBlanco (random num-estudiantes)
  ask patch ([xcor] of turtle estudianteBlanco) ([ycor] of turtle estudianteBlanco)
  [
    if (pxcor < (final-x - ancho-calzada) or pycor < (final-y - ancho-calzada))
    [set nivelGas 60]
  ]
end


to moverArriba [esLider]
  set heading 0
  if (puedeAvanzar? esLider) [fd 1]
end

to moverDerecha [esLider]
  set heading 90
  if (puedeAvanzar? esLider) [fd 1]
end

to moverAbajo [esLider]
  set heading 180
  if (puedeAvanzar? esLider) [fd 1]
end

to moverIzquierda [esLider]
  set heading 270
  if (puedeAvanzar? esLider) [fd 1]
end

to-report puedeAvanzar? [esLider?]
  report (can-move? 1 and
    (
      ([esFinal?] of patch-ahead 1) or (
        (not [esCasa?] of patch-ahead 1) and (
          esLider? or (
            (not any? estudiantes-on patch-ahead 1) and
            (not any? lideres-on patch-ahead 1)
          )
        )
      )
    )
  )
end

to huirGas [esLider?]
  let gasAdelante 0
  let gasDerecha 0
  let gasIzquierda 0
  let gasAtras 0

  if (can-move? 1) [set gasAdelante [nivelGas] of patch-ahead 1]
  if (patch-right-and-ahead 90 1 != nobody) [set gasDerecha [nivelGas] of patch-right-and-ahead 90 1]
  if (patch-left-and-ahead 90 1 != nobody) [set gasIzquierda [nivelGas] of patch-left-and-ahead 90 1]
  if (can-move? -1) [set gasAtras [nivelGas] of patch-ahead -1]

  if (max (list gasAdelante gasDerecha gasIzquierda gasAtras) = gasAdelante)
  [
    if (puedeAvanzar? esLider?) [fd 1]
  ]

  if (max (list gasAdelante gasDerecha gasIzquierda gasAtras) = gasAtras)
  [
    rt 180
    if (puedeAvanzar? esLider?) [fd 1]
  ]

  if (max (list gasAdelante gasDerecha gasIzquierda gasAtras) = gasDerecha)
  [
    rt 270
    if (puedeAvanzar? esLider?) [fd 1]
  ]

  if (max (list gasAdelante gasDerecha gasIzquierda gasAtras) = gasIzquierda)
  [
    rt 90
    if (puedeAvanzar? esLider?) [fd 1]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
304
54
924
435
-1
-1
12.0
1
10
1
1
1
0
0
0
1
0
50
0
30
1
1
1
ticks
30.0

SLIDER
87
85
259
118
num-calles
num-calles
1
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
87
124
259
157
num-carreras
num-carreras
1
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
86
161
258
194
ancho-calzada
ancho-calzada
1
10
3.0
1
1
NIL
HORIZONTAL

BUTTON
977
62
1156
122
pintar calles
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
86
202
258
235
num-estudiantes
num-estudiantes
20
100
29.0
1
1
NIL
HORIZONTAL

SLIDER
86
245
258
278
num-esmad
num-esmad
0
100
11.0
1
1
NIL
HORIZONTAL

BUTTON
978
130
1156
187
empezar
do\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
87
290
259
323
porcentaje-pintura
porcentaje-pintura
0
100
48.0
1
1
NIL
HORIZONTAL

SLIDER
87
330
259
363
procentaje-papas
procentaje-papas
0
100
28.0
1
1
NIL
HORIZONTAL

SLIDER
87
370
259
403
tolerancia-esmad
tolerancia-esmad
0
100
73.0
1
1
NIL
HORIZONTAL

MONITOR
981
253
1077
298
pintados
pintados
17
1
11

TEXTBOX
983
348
1300
418
Gris edificios\nAzul pintura\nRojo Papas bomba\nAmarillo Gas pimienta arrojado por los policias\n
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person police
false
0
Polygon -1 true false 124 91 150 165 178 91
Polygon -13345367 true false 134 91 149 106 134 181 149 196 164 181 149 106 164 91
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -13345367 true false 120 90 105 90 60 195 90 210 116 158 120 195 180 195 184 158 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Polygon -13345367 true false 150 26 110 41 97 29 137 -1 158 6 185 0 201 6 196 23 204 34 180 33
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Rectangle -16777216 true false 109 183 124 227
Rectangle -16777216 true false 176 183 195 205
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Polygon -1184463 true false 172 112 191 112 185 133 179 133
Polygon -1184463 true false 175 6 194 6 189 21 180 21
Line -1184463 false 149 24 197 24
Rectangle -16777216 true false 101 177 122 187
Rectangle -16777216 true false 179 164 183 186

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@

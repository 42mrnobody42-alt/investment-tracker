quiero crear una aplicación web que tenga los siguientes componentes:
Usar contenedores docker para los servicios postgresql para la DB, tomcat para el servicio web.
Los lenguajes de programación que vamos a usar es pl/sql, java para la logica ultima version LTS.
Para el frontend quiero usar react css para que se vea lo mas moderno y potente.
Tengo un servidor en pop os 22.04 y tengo instalado visual estudio code, necesito una guia para programar y probar  en local desde mi servidor.
El versionamiento de todos los archivos seran llevados en un nuevo proyecto de git github separados por carpetas para Docker, DB, back y front.
Quiero que crees un paso a paso del procedimiento de toda la programación con diagramas, modelo MER y documentos.
quiero que guardes este promp en un directorio de promps para el proyecto en formato MD

ahora si la aplicación va ha ser lo siguiente:
1. tener seguridad https y manejo de tockens JWS para la comunicación.
2. crear usuarios con roles.
3. La aplicación sera para que un cliente pueda registrar todas sus inversiones que tiene en diferente plataformas con sus respectivos costos de comision cada una y el costo de cada plataforma puede cambiar en el tiempo de valor o porcentaje.
4. el cliente puede registrar entre compras y ventas de acciones por cantidad, valor unitario por acción, valor total acciones, comision, valor total moviento.
5. el cliente puede ver el total de sus movimientos y obtener el valor  positivo o negativo de sus inversiones.
6. tambien debe tener una función a parte para realizar un calculo de cuanto deberia ser lo minimo para la venta de las acciones y la cantidad que debe vender para generar una ganancia que el cliente indique, el calculo se debe hacer segun lo registrado en la cuenta del cliente.
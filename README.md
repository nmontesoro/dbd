# Introducción

Este es el trabajo práctico final para la materia Diseño de Bases de Datos de
la Facultad de Ingeniería, Universidad Nacional de Mar del Plata, dictada en el
primer cuatrimestre del año 2023 por Dra. Leticia M. Seijas (profesora), Ing.
Estanislao Mileta (JTP) e Ing. Marco Carnaghi (ayudante graduado).

El problema consiste en diseñar una base de datos para controlar la seguridad
en un laboratorio ficticio que trabaja con materiales peligrosos. El
laboratorio tiene distintas áreas con niveles de seguridad (baja, media y alta)
y empleados de diferentes categorías (jerárquicos, profesionales y no
profesionales). Se requiere registrar los datos personales de los empleados,
así como el responsable jerárquico de cada área. Además, se necesita llevar un
historial de eventos de cada área y registrar la fecha en que un empleado se
hizo cargo de ella. Los empleados profesionales tienen especialidades y pueden
ser contratados por períodos específicos, mientras que los empleados no
profesionales tienen acceso a áreas con el mismo nivel de seguridad y se
necesita conocer sus horarios de acceso. Se deben implementar funcionalidades
como obtener los empleados no profesionales que pueden ingresar a todas las
áreas de su nivel de seguridad asignado, obtener los empleados con intentos de
ingreso fallidos o restricciones de seguridad, y desarrollar una aplicación que
acceda a la base de datos.

# DER

![DER](/docs/img/der.png)

# Ejecución del programa

Toda la aplicación está pensada para ser corrida con Docker, evitando así
errores de dependencias. Luego de instalar Docker y clonar el repositorio
mediante `git clone`, lo único que hay que hacer es

```shell
docker-compose up --build
```

Este comando compila la aplicación .NET (Blazor WebServer) y la ejecuta dentro
de un contenedor. También crea la base de datos de MySQL en otro contenedor,
utilizando los scripts que se encuentran en el directorio `mysql-files`, y
vincula ambos contenedores mediante una red interna.

Luego de ejecutar el comando anterior correctamente se puede acceder a la
aplicación navegando a [http://localhost:80](http://localhost:80). Asimismo se habilita el
puerto 3306 (puerto por defecto de MySQL) para poder acceder directamente a la
base de datos mediante MySQL Workbench[^1].

[^1]: Usuario: `root`, contraseña: `PwdDbd`.

## Uso

La pantalla principal es la siguiente. Desde aquí se puede acceder al listado
de empleados, al acceso a áreas mediante legajo y contraseña, y a la sección de
auditoría.

![Captura de la pantalla principal de la aplicación](/docs/img/screen1.png)

En la sección de _Empleados_ se puede ver un listado de todos los empleados en
orden alfabético según su apellido. El listado incluye el legajo, la fecha de
nacimiento, el teléfono y el nivel de seguridad para el que fue capacitado.

![Captura de la pantalla de empleados](/docs/img/screen2.png)

La sección de _Acceso por legajo_ emula un control de entrada y salida de
empleados dentro del laboratorio. Desde aquí se puede seleccionar el área a
donde se desea acceder, y utilizar el número de legajo y contraseña de un
empleado para validar la acción. El sistema comprueba automáticamente si se
trata de un movimiento permitido y muestra al usuario un mensaje según haya
sido autorizado o no.

![Captura de la pantalla de acceso](/docs/img/screen3.png)

Finalmente, la sección _Auditoría_ implementa las consignas 2 y 3 del trabajo
práctico (el resto están en los scripts de creación de la DB). Básicamente,
muestra listados de los empleados que tuvieron problemas para acceder o que
no fueron autorizados.

![Captura de la pantalla de auditoría](/docs/img/screen4.png)

# Autores

La aplicación fue desarrollada por Nazareno Montesoro y Santiago Castiñeira.

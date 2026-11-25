# Vannu

**Seguimiento de pedidos y guías para tiendas mayoristas.**

Vannu ayuda a las tiendas que venden por WhatsApp y en el local a llevar el control de sus pedidos, sus salidas y sus guías de envío, y les da a sus clientes un link para ver cómo va su pedido sin tener que preguntar.

---

## El problema

En muchas tiendas mayoristas todo el proceso se hace a mano:

- Los pedidos llegan por varias líneas de WhatsApp y en persona.
- Los datos del cliente se anotan en un papel que se pega al paquete.
- La transportadora recoge los paquetes y después envía las guías en foto o en link.
- Esa guía hay que buscarla y reenviarla a cada cliente, entre cientos de mensajes al día.

El resultado: guías que se pierden, clientes que no saben dónde va su pedido y asesoras respondiendo una y otra vez "¿y mi guía?".

## La solución

- **Registro del pedido** en un minuto, con autocompletado de clientes frecuentes.
- **Link de seguimiento** para el cliente, enviado por WhatsApp con un toque.
- **Rótulo impreso** en formato de recibo, para no escribir los datos dos veces.
- **Control de salidas:** qué paquetes se llevó la transportadora y a qué hora.
- **Registro de guías** por número o link, con alerta de guías atrasadas.
- **Página del cliente** con el estado del pedido y el botón de rastreo de la transportadora.
- **Datos protegidos:** la información personal solo se ve con los últimos 4 dígitos de la cédula.
- **Historial y reportes** por día, por salida y por asesora.

## Cómo funciona

1. La asesora registra el pedido y le envía al cliente su link.
2. Cuando pasa la transportadora, se registra la salida de los paquetes.
3. Cuando llega la guía, se pega en el sistema.
4. El cliente abre su link y ve el estado y su guía, sin escribirle a la tienda.

## Tecnología

| Parte | Herramienta |
| --- | --- |
| Pantallas | HTML, CSS y JavaScript, sin frameworks |
| Base de datos | PostgreSQL en Supabase |
| Login | Supabase Auth |
| Seguridad de los datos | Row Level Security (RLS) y funciones SQL |
| Tiempo real | Supabase Realtime |

## Estado del proyecto

En desarrollo: **fase 0 de 14** (preparación).

## Estructura del repositorio

| Carpeta | Contenido |
| --- | --- |
| `docs/` | Diagramas, capturas y decisiones del proyecto |
| `supabase/` | Scripts SQL de la base de datos |
| `APRENDIZAJES.md` | Bitácora de lo aprendido en cada fase |

## Autora

Yenifer Cortez · yenico623@gmail.com

## Derechos

© 2026 Yenifer Cortez. Todos los derechos reservados. El código es visible con fines de portafolio; no se autoriza su copia ni su uso comercial sin permiso.

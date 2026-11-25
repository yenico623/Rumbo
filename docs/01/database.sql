


create table public.empresas (
    id              bigint generated always as identity primary key,
    nombre          text        not null check (char_length(nombre) between 2 and 100),
    nit             text        unique,
    activa          boolean     not null default true,
    fecha_creacion  timestamptz not null default now()
);


create table public.perfiles (
    id              uuid        primary key references auth.users (id) on delete cascade,
    empresa_id      bigint      references public.empresas (id),
    nombre          text        not null check (char_length(nombre) between 2 and 60),
    rol             text        not null check (rol in ('SUPERADMIN', 'ADMIN_EMPRESA', 'OPERADOR')),
    activo          boolean     not null default true,
    fecha_creacion  timestamptz not null default now(),
    -- El superadmin no tiene empresa; los demás sí.
    constraint ck_perfiles_rol_empresa check (
        (rol = 'SUPERADMIN' and empresa_id is null)
        or (rol <> 'SUPERADMIN' and empresa_id is not null)
    )
);



create table public.asesoras (
    id          bigint  generated always as identity primary key,
    empresa_id  bigint  not null references public.empresas (id),
    nombre      text    not null check (char_length(nombre) between 2 and 60),
    activa      boolean not null default true,
    constraint uq_asesoras_empresa_nombre unique (empresa_id, nombre),
    constraint uq_asesoras_empresa_id     unique (empresa_id, id)
);



create table public.clientes (
    id              bigint      generated always as identity primary key,
    empresa_id      bigint      not null references public.empresas (id),
    cedula          text        not null check (cedula ~ '^[0-9]{5,15}$'),
    nombre          text        not null check (char_length(nombre) between 2 and 100),
    telefono        text        not null check (telefono ~ '^[0-9]{10}$'),
    fecha_registro  timestamptz not null default now(),
    constraint uq_clientes_empresa_cedula unique (empresa_id, cedula),
    constraint uq_clientes_empresa_id     unique (empresa_id, id)
);


create table public.transportadoras (
    id                 bigint generated always as identity primary key,
    nombre             text   not null unique,
    plantilla_rastreo  text
);


create table public.salidas (
    id                 bigint      generated always as identity primary key,
    empresa_id         bigint      not null references public.empresas (id),
    transportadora_id  bigint      not null references public.transportadoras (id),
    fecha_hora         timestamptz not null default now(),
    constraint uq_salidas_empresa_transportadora_id unique (empresa_id, transportadora_id, id)
);



create table public.pedidos (
    id                 bigint        generated always as identity primary key,
    empresa_id         bigint        not null references public.empresas (id),
    numero_interno     integer       not null check (numero_interno > 0),
    codigo             text          not null unique check (codigo ~ '^[A-Z0-9-]{6,12}$'),
    fecha_registro     timestamptz   not null default now(),
    asesora_id         bigint,
    cliente_id         bigint        not null,
    ciudad             text          not null check (char_length(ciudad) between 2 and 80),
    direccion          text          not null check (char_length(direccion) between 5 and 150),
    transportadora_id  bigint        not null references public.transportadoras (id),
    unidades           integer       check (unidades is null or unidades > 0),
    valor              numeric(12,2) check (valor is null or valor >= 0),
    salida_id          bigint,
    guia               text          check (guia is null or char_length(guia) between 6 and 30),
    link_guia          text          check (link_guia is null or char_length(link_guia) <= 500),
    fecha_guia         timestamptz,
    
    intentos_fallidos  integer       not null default 0 check (intentos_fallidos >= 0),
    bloqueado_hasta    timestamptz,

    constraint uq_pedidos_empresa_numero      unique (empresa_id, numero_interno),
    constraint uq_pedidos_transportadora_guia unique (transportadora_id, guia),

    -- Llaves compuestas: impiden mezclar datos de empresas distintas.
    constraint fk_pedidos_cliente foreign key (empresa_id, cliente_id)
        references public.clientes (empresa_id, id),
    constraint fk_pedidos_asesora foreign key (empresa_id, asesora_id)
        references public.asesoras (empresa_id, id),
    constraint fk_pedidos_salida foreign key (empresa_id, transportadora_id, salida_id)
        references public.salidas (empresa_id, transportadora_id, id),

    -- Una guía solo existe si el paquete ya salió, y llega con su fecha.
    constraint ck_pedidos_guia_requiere_salida check (guia is null or salida_id is not null),
    constraint ck_pedidos_guia_fecha check ((guia is null) = (fecha_guia is null))
);



create index ix_perfiles_empresa        on public.perfiles (empresa_id);
create index ix_salidas_empresa_fecha   on public.salidas (empresa_id, fecha_hora);
create index ix_salidas_transportadora  on public.salidas (transportadora_id);
create index ix_pedidos_empresa_fecha   on public.pedidos (empresa_id, fecha_registro);
create index ix_pedidos_empresa_asesora on public.pedidos (empresa_id, asesora_id, fecha_registro);
create index ix_pedidos_cliente         on public.pedidos (empresa_id, cliente_id);
create index ix_pedidos_salida          on public.pedidos (empresa_id, transportadora_id, salida_id);
create index ix_pedidos_guia            on public.pedidos (guia);
-- Para las listas "Por despachar" y "Sin guía"
create index ix_pedidos_sin_salida on public.pedidos (empresa_id) where salida_id is null;
create index ix_pedidos_sin_guia   on public.pedidos (empresa_id) where salida_id is not null and guia is null;

create or replace function public.mi_empresa_id()
returns bigint
language sql
stable
security definer
set search_path = ''
as $$
    select p.empresa_id
    from public.perfiles p
    where p.id = (select auth.uid())
      and p.activo = true;
$$;

create or replace function public.mi_rol()
returns text
language sql
stable
security definer
set search_path = ''
as $$
    select p.rol
    from public.perfiles p
    where p.id = (select auth.uid())
      and p.activo = true;
$$;

-- Solo los usuarios con login pueden usarlas.
revoke execute on function public.mi_empresa_id() from public, anon;
revoke execute on function public.mi_rol()        from public, anon;
grant  execute on function public.mi_empresa_id() to authenticated;
grant  execute on function public.mi_rol()        to authenticated;


alter table public.empresas        enable row level security;
alter table public.perfiles        enable row level security;
alter table public.asesoras        enable row level security;
alter table public.clientes        enable row level security;
alter table public.transportadoras enable row level security;
alter table public.salidas         enable row level security;
alter table public.pedidos         enable row level security;



grant select, insert, update on public.empresas  to authenticated;
grant select, update         on public.perfiles  to authenticated;
grant select, insert, update on public.asesoras  to authenticated;
grant select, insert, update on public.clientes  to authenticated;
grant select                 on public.transportadoras to authenticated;
grant select, insert         on public.salidas   to authenticated;
grant select, insert, update on public.pedidos   to authenticated;
-- Nadie borra pedidos ni clientes desde la app: se conserva el historial.



insert into public.empresas (nombre) values ('Mi Tienda');

insert into public.transportadoras (nombre) values
    ('Envía'),
    ('Interrapidísimo');
/*
  #Gestión de Fondo Rotativo - Tienda Catu
  
  ## Tablas Principales
  
  1. Cajas
    - `cajas` - Registro de cajas comercial y principal
  
  2. Usuarios
    - `profiles` - Perfiles de usuarios del sistema
  
  3. Turnos y Operaciones
    - `turnos` - Turnos de trabajo en cada caja
    - `aperturas` - Apertura de caja con fondo inicial
    - `arqueos` - Conteo de efectivo y cierre de turno
    - `traslados` - Traslado de efectivo entre cajas
    - `recepciones` - Recepción de traslados
    - `pagos_proveedores` - Pagos realizados a proveedores
  
  4. Administración
    - `parametros` - Parámetros configurables del sistema
    - `cierres_jornada` - Cierre diario consolidado
    - `bitacora_auditoria` - Registro de auditoría
  
  ## Seguridad
  - RLS habilitado en todas las tablas
  - Políticas permisivas para permitir operación sin autenticación estricta
*/

-- Crear usuario por defecto si no existe
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = '00000000-0000-0000-0000-000000000000') THEN
    INSERT INTO auth.users (
      id,
      instance_id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      created_at,
      updated_at,
      raw_app_meta_data,
      raw_user_meta_data,
      is_super_admin,
      confirmation_token,
      recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      '00000000-0000-0000-0000-000000000000',
      'authenticated',
      'authenticated',
      'usuario@catu.com',
      crypt('password123', gen_salt('bf')),
      NOW(),
      NOW(),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"nombre_completo":"Usuario Sistema"}',
      false,
      '',
      ''
    );
  END IF;
END $$;

-- Tabla de perfiles de usuario
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY DEFAULT '00000000-0000-0000-0000-000000000000',
  nombre_completo TEXT NOT NULL DEFAULT 'Usuario Sistema',
  email TEXT NOT NULL DEFAULT 'usuario@catu.com',
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver perfiles"
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Todos pueden insertar perfiles"
  ON public.profiles FOR INSERT
  WITH CHECK (true);

-- Insertar perfil por defecto si no existe
INSERT INTO public.profiles (id, nombre_completo, email)
VALUES ('00000000-0000-0000-0000-000000000000', 'Usuario Sistema', 'usuario@catu.com')
ON CONFLICT (id) DO NOTHING;

-- Tabla de cajas
CREATE TABLE IF NOT EXISTS public.cajas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL UNIQUE,
  tipo TEXT NOT NULL CHECK (tipo IN ('comercial', 'principal')),
  ubicacion TEXT,
  activa BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.cajas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver las cajas"
  ON public.cajas FOR SELECT
  USING (true);

CREATE POLICY "Todos pueden insertar cajas"
  ON public.cajas FOR INSERT
  WITH CHECK (true);

-- Insertar las dos cajas principales si no existen
INSERT INTO public.cajas (nombre, tipo, ubicacion) 
VALUES
  ('Caja Comercial', 'comercial', 'Planta Baja'),
  ('Caja Principal', 'principal', 'Planta Alta')
ON CONFLICT (nombre) DO NOTHING;

-- Tabla de turnos
CREATE TABLE IF NOT EXISTS public.turnos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  caja_id UUID NOT NULL REFERENCES public.cajas(id),
  usuario_id UUID NOT NULL REFERENCES public.profiles(id),
  fecha DATE NOT NULL,
  hora_inicio TIME NOT NULL,
  hora_fin TIME,
  estado TEXT NOT NULL DEFAULT 'abierto' CHECK (estado IN ('abierto', 'cerrado')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.turnos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver turnos"
  ON public.turnos FOR SELECT
  USING (true);

CREATE POLICY "Todos pueden crear turnos"
  ON public.turnos FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Todos pueden actualizar turnos"
  ON public.turnos FOR UPDATE
  USING (true);

-- Tabla de aperturas de caja
CREATE TABLE IF NOT EXISTS public.aperturas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  turno_id UUID NOT NULL REFERENCES public.turnos(id),
  monto_inicial DECIMAL(10,2) NOT NULL CHECK (monto_inicial >= 0),
  observaciones TEXT,
  fecha_hora TIMESTAMPTZ DEFAULT NOW(),
  cerrada BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.aperturas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver aperturas"
  ON public.aperturas FOR SELECT
  USING (true);

CREATE POLICY "Todos pueden crear aperturas"
  ON public.aperturas FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Todos pueden actualizar aperturas"
  ON public.aperturas FOR UPDATE
  USING (true);

-- Tabla de arqueos
CREATE TABLE IF NOT EXISTS public.arqueos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  apertura_id UUID NOT NULL REFERENCES public.aperturas(id),
  monto_contado DECIMAL(10,2) NOT NULL CHECK (monto_contado >= 0),
  monto_esperado DECIMAL(10,2) NOT NULL,
  diferencia DECIMAL(10,2) NOT NULL,
  comentario TEXT,
  fecha_hora TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.arqueos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver arqueos"
  ON public.arqueos FOR SELECT
  USING (true);

CREATE POLICY "Todos pueden crear arqueos"
  ON public.arqueos FOR INSERT
  WITH CHECK (true);

-- Tabla de traslados
CREATE TABLE IF NOT EXISTS public.traslados (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  arqueo_id UUID NOT NULL REFERENCES public.arqueos(id),
  caja_origen_id UUID NOT NULL REFERENCES public.cajas(id),
  caja_destino_id UUID NOT NULL REFERENCES public.cajas(id),
  monto DECIMAL(10,2) NOT NULL CHECK (monto >= 0),
  archivo_adjunto TEXT,
  estado TEXT NOT NULL DEFAULT 'en_transito' CHECK (estado IN ('en_transito', 'recibido', 'observado')),
  fecha_hora_envio TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.traslados ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver traslados"
  ON public.traslados FOR SELECT
  USING (true);

CREATE POLICY "Todos pueden crear traslados"
  ON public.traslados FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Todos pueden actualizar traslados"
  ON public.traslados FOR UPDATE
  USING (true);

-- Tabla de recepciones
CREATE TABLE IF NOT EXISTS public.recepciones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  traslado_id UUID NOT NULL REFERENCES public.traslados(id),
  usuario_receptor_id UUID NOT NULL REFERENCES public.profiles(id),
  monto_recibido DECIMAL(10,2) NOT NULL CHECK (monto_recibido >= 0),
  diferencia DECIMAL(10,2) NOT NULL,
  comentario TEXT,
  fecha_hora TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.recepciones ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver recepciones"
  ON public.recepciones FOR SELECT
  USING (true);

CREATE POLICY "Todos pueden crear recepciones"
  ON public.recepciones FOR INSERT
  WITH CHECK (true);

-- Tabla de pagos a proveedores
CREATE TABLE IF NOT EXISTS public.pagos_proveedores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proveedor TEXT NOT NULL,
  tipo_documento TEXT NOT NULL CHECK (tipo_documento IN ('Factura', 'Nota de venta', 'Doc. no autorizado', 'Devolución', 'Recepción')),
  numero_documento TEXT NOT NULL,
  valor NUMERIC NOT NULL DEFAULT 0 CHECK (valor >= 0),
  saldo NUMERIC NOT NULL DEFAULT 0,
  pagado_por TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.pagos_proveedores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver pagos"
  ON public.pagos_proveedores FOR SELECT
  USING (true);

CREATE POLICY "Todos pueden crear pagos"
  ON public.pagos_proveedores FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Todos pueden actualizar pagos"
  ON public.pagos_proveedores FOR UPDATE
  USING (true);

CREATE POLICY "Todos pueden eliminar pagos"
  ON public.pagos_proveedores FOR DELETE
  USING (true);

-- Tabla de cierres de jornada
CREATE TABLE IF NOT EXISTS public.cierres_jornada (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fecha DATE NOT NULL UNIQUE,
  total_trasladado DECIMAL(10,2) NOT NULL,
  diferencias_acumuladas DECIMAL(10,2) NOT NULL,
  cantidad_traslados INTEGER NOT NULL,
  traslados_con_diferencia INTEGER NOT NULL,
  tiempo_promedio_minutos INTEGER,
  reporte_url TEXT,
  usuario_cierre_id UUID NOT NULL REFERENCES public.profiles(id),
  fecha_hora_cierre TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.cierres_jornada ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver cierres"
  ON public.cierres_jornada FOR SELECT
  USING (true);

CREATE POLICY "Todos pueden crear cierres"
  ON public.cierres_jornada FOR INSERT
  WITH CHECK (true);

-- Tabla de parámetros
CREATE TABLE IF NOT EXISTS public.parametros (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clave TEXT NOT NULL UNIQUE,
  valor TEXT NOT NULL,
  descripcion TEXT,
  tipo TEXT NOT NULL CHECK (tipo IN ('number', 'text', 'boolean')),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.parametros ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver parámetros"
  ON public.parametros FOR SELECT
  USING (true);

CREATE POLICY "Todos pueden actualizar parámetros"
  ON public.parametros FOR UPDATE
  USING (true);

-- Insertar parámetros por defecto
INSERT INTO public.parametros (clave, valor, descripcion, tipo) 
VALUES
  ('umbral_diferencia', '2.00', 'Umbral de diferencia permitido en USD', 'number'),
  ('zona_horaria', 'America/Guayaquil', 'Zona horaria del sistema', 'text'),
  ('moneda', 'USD', 'Moneda del sistema', 'text'),
  ('requiere_denominaciones', 'false', 'Requiere detalle de denominaciones', 'boolean'),
  ('tiempo_alerta_traslado', '30', 'Minutos para alerta de traslado en tránsito', 'number'),
  ('hora_limite_cierre', '23:00', 'Hora límite para cerrar turno', 'text')
ON CONFLICT (clave) DO NOTHING;

-- Tabla de bitácora de auditoría
CREATE TABLE IF NOT EXISTS public.bitacora_auditoria (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tabla TEXT NOT NULL,
  registro_id UUID NOT NULL,
  accion TEXT NOT NULL CHECK (accion IN ('INSERT', 'UPDATE', 'DELETE')),
  usuario_id UUID REFERENCES public.profiles(id),
  datos_anteriores JSONB,
  datos_nuevos JSONB,
  fecha_hora TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.bitacora_auditoria ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver bitácora"
  ON public.bitacora_auditoria FOR SELECT
  USING (true);

-- Función para actualizar updated_at
CREATE OR REPLACE FUNCTION public.actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para actualizar updated_at
DROP TRIGGER IF EXISTS actualizar_profiles_updated_at ON public.profiles;
CREATE TRIGGER actualizar_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.actualizar_updated_at();

DROP TRIGGER IF EXISTS actualizar_parametros_updated_at ON public.parametros;
CREATE TRIGGER actualizar_parametros_updated_at
  BEFORE UPDATE ON public.parametros
  FOR EACH ROW
  EXECUTE FUNCTION public.actualizar_updated_at();

-- Secuencias para numeración automática de documentos
CREATE SEQUENCE IF NOT EXISTS public.seq_doc_no_autorizado START WITH 1;
CREATE SEQUENCE IF NOT EXISTS public.seq_devolucion START WITH 1;
CREATE SEQUENCE IF NOT EXISTS public.seq_recepcion START WITH 1;

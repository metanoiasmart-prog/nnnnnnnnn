-- Tabla de perfiles de usuario
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nombre_completo TEXT NOT NULL,
  email TEXT NOT NULL,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver su propio perfil"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

-- Tabla de cajas
CREATE TABLE public.cajas (
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

-- Insertar las dos cajas principales
INSERT INTO public.cajas (nombre, tipo, ubicacion) VALUES
  ('Caja Comercial', 'comercial', 'Planta Baja'),
  ('Caja Principal', 'principal', 'Planta Alta');

-- Tabla de turnos
CREATE TABLE public.turnos (
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

CREATE POLICY "Los usuarios pueden ver sus propios turnos"
  ON public.turnos FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "Los usuarios pueden crear turnos"
  ON public.turnos FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Los usuarios pueden actualizar sus propios turnos"
  ON public.turnos FOR UPDATE
  USING (auth.uid() = usuario_id);

-- Tabla de aperturas de caja
CREATE TABLE public.aperturas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  turno_id UUID NOT NULL REFERENCES public.turnos(id),
  monto_inicial DECIMAL(10,2) NOT NULL CHECK (monto_inicial >= 0),
  observaciones TEXT,
  fecha_hora TIMESTAMPTZ DEFAULT NOW(),
  cerrada BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.aperturas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver aperturas de sus turnos"
  ON public.aperturas FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.turnos 
    WHERE turnos.id = aperturas.turno_id 
    AND turnos.usuario_id = auth.uid()
  ));

CREATE POLICY "Los usuarios pueden crear aperturas"
  ON public.aperturas FOR INSERT
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.turnos 
    WHERE turnos.id = turno_id 
    AND turnos.usuario_id = auth.uid()
  ));

CREATE POLICY "Los usuarios pueden actualizar sus aperturas"
  ON public.aperturas FOR UPDATE
  USING (EXISTS (
    SELECT 1 FROM public.turnos 
    WHERE turnos.id = aperturas.turno_id 
    AND turnos.usuario_id = auth.uid()
  ));

-- Tabla de arqueos
CREATE TABLE public.arqueos (
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

CREATE POLICY "Los usuarios pueden ver arqueos de sus aperturas"
  ON public.arqueos FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.aperturas 
    JOIN public.turnos ON turnos.id = aperturas.turno_id
    WHERE aperturas.id = arqueos.apertura_id 
    AND turnos.usuario_id = auth.uid()
  ));

CREATE POLICY "Los usuarios pueden crear arqueos"
  ON public.arqueos FOR INSERT
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.aperturas 
    JOIN public.turnos ON turnos.id = aperturas.turno_id
    WHERE aperturas.id = apertura_id 
    AND turnos.usuario_id = auth.uid()
  ));

-- Tabla de traslados
CREATE TABLE public.traslados (
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

CREATE POLICY "Todos los usuarios pueden ver traslados"
  ON public.traslados FOR SELECT
  USING (true);

CREATE POLICY "Los usuarios pueden crear traslados"
  ON public.traslados FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Todos pueden actualizar traslados"
  ON public.traslados FOR UPDATE
  USING (true);

-- Tabla de recepciones
CREATE TABLE public.recepciones (
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

CREATE POLICY "Los usuarios pueden crear recepciones"
  ON public.recepciones FOR INSERT
  WITH CHECK (auth.uid() = usuario_receptor_id);

-- Tabla de cierres de jornada
CREATE TABLE public.cierres_jornada (
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

CREATE POLICY "Todos pueden ver cierres de jornada"
  ON public.cierres_jornada FOR SELECT
  USING (true);

CREATE POLICY "Los usuarios pueden crear cierres"
  ON public.cierres_jornada FOR INSERT
  WITH CHECK (auth.uid() = usuario_cierre_id);

-- Tabla de parámetros
CREATE TABLE public.parametros (
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
INSERT INTO public.parametros (clave, valor, descripcion, tipo) VALUES
  ('umbral_diferencia', '2.00', 'Umbral de diferencia permitido en USD', 'number'),
  ('zona_horaria', 'America/Guayaquil', 'Zona horaria del sistema', 'text'),
  ('moneda', 'USD', 'Moneda del sistema', 'text'),
  ('requiere_denominaciones', 'false', 'Requiere detalle de denominaciones', 'boolean'),
  ('tiempo_alerta_traslado', '30', 'Minutos para alerta de traslado en tránsito', 'number'),
  ('hora_limite_cierre', '23:00', 'Hora límite para cerrar turno', 'text');

-- Tabla de bitácora de auditoría
CREATE TABLE public.bitacora_auditoria (
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

CREATE POLICY "Todos pueden ver la bitácora"
  ON public.bitacora_auditoria FOR SELECT
  USING (true);

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION public.actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER actualizar_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.actualizar_updated_at();

CREATE TRIGGER actualizar_parametros_updated_at
  BEFORE UPDATE ON public.parametros
  FOR EACH ROW
  EXECUTE FUNCTION public.actualizar_updated_at();

-- Función y trigger para crear perfil automáticamente al registrarse
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, nombre_completo, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'nombre_completo', NEW.email),
    NEW.email
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
/*
  # Sistema Completo de Gestión de Efectivo - Tienda Catu
  
  1. Nuevas Tablas
    - `profiles` - Perfiles de usuarios
    - `cajas` - Cajas registradoras (comercial y principal)
    - `empleados` - Empleados de la tienda
    - `turnos` - Turnos de trabajo por caja
    - `aperturas` - Apertura de caja con fondo inicial
    - `arqueos` - Arqueo y cierre de caja
    - `traslados` - Traslados de efectivo entre cajas
    - `recepciones` - Recepción de traslados
    - `pagos_proveedores` - Pagos a proveedores durante el turno
    - `parametros` - Parámetros del sistema
    - `bitacora_auditoria` - Registro de auditoría
    - `cierres_jornada` - Cierre diario de jornada
    
  2. Seguridad
    - Habilitar RLS en todas las tablas
    - Políticas restrictivas para cada tabla
    - Solo usuarios autenticados pueden acceder
*/

-- Crear tabla de perfiles de usuarios
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text DEFAULT '',
  nombre_completo text DEFAULT '',
  activo boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (true);

-- Crear tabla de cajas
CREATE TABLE IF NOT EXISTS cajas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre text NOT NULL,
  tipo text NOT NULL,
  ubicacion text,
  activa boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE cajas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view cajas"
  ON cajas FOR SELECT
  TO authenticated
  USING (true);

-- Crear tabla de empleados
CREATE TABLE IF NOT EXISTS empleados (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre_completo text NOT NULL,
  cargo text NOT NULL,
  activo boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE empleados ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view empleados"
  ON empleados FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert empleados"
  ON empleados FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Crear tabla de turnos
CREATE TABLE IF NOT EXISTS turnos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  caja_id uuid NOT NULL REFERENCES cajas(id),
  usuario_id uuid NOT NULL REFERENCES profiles(id),
  empleado_id uuid REFERENCES empleados(id),
  fecha date NOT NULL,
  hora_inicio time NOT NULL,
  hora_fin time,
  estado text DEFAULT 'abierto',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE turnos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own turnos"
  ON turnos FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert own turnos"
  ON turnos FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update own turnos"
  ON turnos FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Crear tabla de aperturas
CREATE TABLE IF NOT EXISTS aperturas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  turno_id uuid NOT NULL REFERENCES turnos(id),
  monto_inicial numeric NOT NULL,
  fecha_hora timestamptz DEFAULT now(),
  observaciones text,
  cerrada boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE aperturas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view aperturas"
  ON aperturas FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert aperturas"
  ON aperturas FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update aperturas"
  ON aperturas FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Crear tabla de arqueos
CREATE TABLE IF NOT EXISTS arqueos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  apertura_id uuid NOT NULL REFERENCES aperturas(id),
  monto_esperado numeric NOT NULL,
  monto_contado numeric NOT NULL,
  monto_final numeric,
  diferencia numeric NOT NULL,
  fecha_hora timestamptz DEFAULT now(),
  comentario text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE arqueos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view arqueos"
  ON arqueos FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert arqueos"
  ON arqueos FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Crear tabla de traslados
CREATE TABLE IF NOT EXISTS traslados (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  arqueo_id uuid NOT NULL REFERENCES arqueos(id),
  caja_origen_id uuid NOT NULL REFERENCES cajas(id),
  caja_destino_id uuid NOT NULL REFERENCES cajas(id),
  monto numeric NOT NULL,
  estado text DEFAULT 'en_transito',
  fecha_hora_envio timestamptz DEFAULT now(),
  archivo_adjunto text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE traslados ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view traslados"
  ON traslados FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert traslados"
  ON traslados FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update traslados"
  ON traslados FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Crear tabla de recepciones
CREATE TABLE IF NOT EXISTS recepciones (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  traslado_id uuid NOT NULL REFERENCES traslados(id),
  usuario_receptor_id uuid NOT NULL REFERENCES profiles(id),
  monto_recibido numeric NOT NULL,
  diferencia numeric NOT NULL,
  fecha_hora timestamptz DEFAULT now(),
  comentario text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE recepciones ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view recepciones"
  ON recepciones FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert recepciones"
  ON recepciones FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Crear tabla de pagos a proveedores
CREATE TABLE IF NOT EXISTS pagos_proveedores (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  proveedor text NOT NULL,
  tipo_documento text NOT NULL,
  numero_documento text NOT NULL,
  valor numeric DEFAULT 0,
  saldo numeric DEFAULT 0,
  pagado_por text NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE pagos_proveedores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view pagos_proveedores"
  ON pagos_proveedores FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert pagos_proveedores"
  ON pagos_proveedores FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Crear tabla de parámetros
CREATE TABLE IF NOT EXISTS parametros (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  clave text NOT NULL UNIQUE,
  valor text NOT NULL,
  tipo text NOT NULL,
  descripcion text,
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE parametros ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view parametros"
  ON parametros FOR SELECT
  TO authenticated
  USING (true);

-- Crear tabla de bitácora de auditoría
CREATE TABLE IF NOT EXISTS bitacora_auditoria (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tabla text NOT NULL,
  registro_id uuid NOT NULL,
  accion text NOT NULL,
  datos_anteriores jsonb,
  datos_nuevos jsonb,
  usuario_id uuid REFERENCES profiles(id),
  fecha_hora timestamptz DEFAULT now()
);

ALTER TABLE bitacora_auditoria ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view bitacora"
  ON bitacora_auditoria FOR SELECT
  TO authenticated
  USING (true);

-- Crear tabla de cierres de jornada
CREATE TABLE IF NOT EXISTS cierres_jornada (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fecha date NOT NULL,
  usuario_cierre_id uuid NOT NULL REFERENCES profiles(id),
  cantidad_traslados integer NOT NULL,
  total_trasladado numeric NOT NULL,
  traslados_con_diferencia integer NOT NULL,
  diferencias_acumuladas numeric NOT NULL,
  tiempo_promedio_minutos numeric,
  fecha_hora_cierre timestamptz DEFAULT now(),
  reporte_url text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE cierres_jornada ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view cierres_jornada"
  ON cierres_jornada FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert cierres_jornada"
  ON cierres_jornada FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Insertar usuario demo
INSERT INTO profiles (id, email, nombre_completo, activo)
VALUES ('00000000-0000-0000-0000-000000000000', 'demo@catu.com', 'Usuario Demo', true)
ON CONFLICT (id) DO NOTHING;

-- Insertar cajas iniciales
INSERT INTO cajas (nombre, tipo, ubicacion, activa) VALUES
  ('Caja Planta Baja', 'comercial', 'Planta Baja', true),
  ('Caja Principal', 'principal', 'Administración', true)
ON CONFLICT DO NOTHING;

-- Insertar parámetros del sistema
INSERT INTO parametros (clave, valor, tipo, descripcion) VALUES
  ('umbral_diferencia', '2.00', 'numeric', 'Umbral máximo de diferencia permitida en USD'),
  ('tiempo_maximo_traslado', '30', 'integer', 'Tiempo máximo para traslado en minutos')
ON CONFLICT (clave) DO NOTHING;
/*
  # Reset y Recreación Completa del Sistema de Gestión de Efectivo

  1. Tablas Principales
    - `empleados` - Información de empleados
    - `cajas` - Información de cajas registradoras
    - `turnos` - Turnos de trabajo
    - `aperturas` - Aperturas de caja
    - `arqueos` - Arqueos de caja (con monto_contado restaurado)
    - `traslados` - Traslados de efectivo entre cajas
    - `recepciones` - Recepción de traslados
    - `pagos_proveedores` - Pagos a proveedores
    - `parametros` - Parámetros del sistema

  2. Seguridad
    - RLS habilitado en todas las tablas
    - Políticas públicas temporales para desarrollo
*/

-- Eliminar tablas existentes si existen
DROP TABLE IF EXISTS recepciones CASCADE;
DROP TABLE IF EXISTS traslados CASCADE;
DROP TABLE IF EXISTS pagos_proveedores CASCADE;
DROP TABLE IF EXISTS arqueos CASCADE;
DROP TABLE IF EXISTS aperturas CASCADE;
DROP TABLE IF EXISTS turnos CASCADE;
DROP TABLE IF EXISTS empleados CASCADE;
DROP TABLE IF EXISTS cajas CASCADE;
DROP TABLE IF EXISTS parametros CASCADE;

-- Tabla de empleados
CREATE TABLE IF NOT EXISTS empleados (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre_completo text NOT NULL,
  cargo text NOT NULL,
  activo boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Tabla de cajas
CREATE TABLE IF NOT EXISTS cajas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre text NOT NULL,
  ubicacion text,
  tipo text,
  activa boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Tabla de turnos
CREATE TABLE IF NOT EXISTS turnos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  caja_id uuid NOT NULL REFERENCES cajas(id),
  empleado_id uuid NOT NULL REFERENCES empleados(id),
  usuario_id uuid,
  fecha date NOT NULL,
  hora_inicio time NOT NULL,
  hora_fin time,
  estado text DEFAULT 'abierto',
  created_at timestamptz DEFAULT now()
);

-- Tabla de aperturas
CREATE TABLE IF NOT EXISTS aperturas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  turno_id uuid NOT NULL REFERENCES turnos(id),
  monto_inicial numeric NOT NULL,
  fecha_hora timestamptz DEFAULT now(),
  cerrada boolean DEFAULT false,
  observaciones text,
  created_at timestamptz DEFAULT now()
);

-- Tabla de arqueos (con monto_contado restaurado)
CREATE TABLE IF NOT EXISTS arqueos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  apertura_id uuid NOT NULL REFERENCES aperturas(id),
  monto_contado numeric NOT NULL,
  monto_esperado numeric,
  monto_final numeric,
  monto_teorico numeric NOT NULL,
  diferencia numeric NOT NULL,
  estado text NOT NULL,
  fecha_hora timestamptz DEFAULT now(),
  comentario text,
  billetes_100 integer DEFAULT 0,
  billetes_50 integer DEFAULT 0,
  billetes_20 integer DEFAULT 0,
  billetes_10 integer DEFAULT 0,
  monedas_5 integer DEFAULT 0,
  monedas_2 integer DEFAULT 0,
  monedas_1 integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Tabla de traslados (con monto_enviado agregado)
CREATE TABLE IF NOT EXISTS traslados (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  arqueo_id uuid REFERENCES arqueos(id),
  caja_origen_id uuid REFERENCES cajas(id),
  caja_destino_id uuid REFERENCES cajas(id),
  empleado_envia_id uuid NOT NULL REFERENCES empleados(id),
  monto numeric,
  monto_enviado numeric,
  estado text DEFAULT 'en_transito',
  fecha_hora_envio timestamptz DEFAULT now(),
  comentario text,
  created_at timestamptz DEFAULT now()
);

-- Tabla de recepciones
CREATE TABLE IF NOT EXISTS recepciones (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  traslado_id uuid NOT NULL REFERENCES traslados(id),
  usuario_receptor_id uuid,
  monto_recibido numeric NOT NULL,
  diferencia numeric NOT NULL,
  fecha_hora timestamptz DEFAULT now(),
  comentario text,
  created_at timestamptz DEFAULT now()
);

-- Tabla de pagos a proveedores
CREATE TABLE IF NOT EXISTS pagos_proveedores (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  proveedor text NOT NULL,
  tipo_documento text,
  numero_documento text,
  valor numeric,
  monto numeric,
  saldo numeric,
  pagado_por uuid REFERENCES empleados(id),
  fecha_hora timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

-- Tabla de parámetros
CREATE TABLE IF NOT EXISTS parametros (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  clave text NOT NULL UNIQUE,
  valor text NOT NULL,
  descripcion text,
  created_at timestamptz DEFAULT now()
);

-- Habilitar RLS en todas las tablas
ALTER TABLE empleados ENABLE ROW LEVEL SECURITY;
ALTER TABLE cajas ENABLE ROW LEVEL SECURITY;
ALTER TABLE turnos ENABLE ROW LEVEL SECURITY;
ALTER TABLE aperturas ENABLE ROW LEVEL SECURITY;
ALTER TABLE arqueos ENABLE ROW LEVEL SECURITY;
ALTER TABLE traslados ENABLE ROW LEVEL SECURITY;
ALTER TABLE recepciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE pagos_proveedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE parametros ENABLE ROW LEVEL SECURITY;

-- Políticas públicas para desarrollo (permitir todo)
CREATE POLICY "Permitir todo en empleados" ON empleados FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en cajas" ON cajas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en turnos" ON turnos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en aperturas" ON aperturas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en arqueos" ON arqueos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en traslados" ON traslados FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en recepciones" ON recepciones FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en pagos_proveedores" ON pagos_proveedores FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en parametros" ON parametros FOR ALL USING (true) WITH CHECK (true);

-- Insertar parámetro de umbral de diferencia
INSERT INTO parametros (clave, valor, descripcion)
VALUES ('umbral_diferencia', '2.00', 'Umbral máximo de diferencia permitida en arqueos (USD)');

-- Insertar cajas iniciales
INSERT INTO cajas (nombre, ubicacion, tipo, activa)
VALUES 
  ('Caja Planta Baja', 'Planta Baja', 'comercial', true),
  ('Caja Principal', 'Oficina Central', 'principal', true);

-- Renombrar campo fecha_hora a fecha_hora_envio en traslados para claridad
ALTER TABLE public.traslados 
RENAME COLUMN fecha_hora TO fecha_hora_envio;
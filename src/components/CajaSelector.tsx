import { useState, useEffect } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { useToast } from "@/hooks/use-toast";
import { Plus, Loader2 } from "lucide-react";

interface CajaSelectorProps {
  value: string;
  onChange: (value: string) => void;
  required?: boolean;
}

export const CajaSelector = ({ value, onChange, required = false }: CajaSelectorProps) => {
  const { toast } = useToast();
  const [cajas, setCajas] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [saving, setSaving] = useState(false);
  const [nuevaCaja, setNuevaCaja] = useState({
    nombre: "",
    ubicacion: "",
    tipo: "comercial",
  });

  useEffect(() => {
    loadCajas();
  }, []);

  const loadCajas = async () => {
    try {
      const { data, error } = await supabase
        .from("cajas")
        .select("*")
        .eq("activa", true)
        .order("nombre");

      if (error) throw error;
      setCajas(data || []);
      
      // Si hay cajas y no hay una seleccionada, seleccionar la primera (Planta Baja)
      if (data && data.length > 0 && !value) {
        const plantaBaja = data.find(c => c.ubicacion === "Planta Baja");
        if (plantaBaja) {
          onChange(plantaBaja.id);
        }
      }
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const handleAgregarCaja = async () => {
    if (!nuevaCaja.nombre.trim() || !nuevaCaja.ubicacion.trim()) {
      toast({
        title: "Campos requeridos",
        description: "Debes completar todos los campos",
        variant: "destructive",
      });
      return;
    }

    setSaving(true);
    try {
      const { data, error } = await supabase
        .from("cajas")
        .insert({
          nombre: nuevaCaja.nombre,
          ubicacion: nuevaCaja.ubicacion,
          tipo: nuevaCaja.tipo,
        })
        .select()
        .single();

      if (error) throw error;

      toast({
        title: "Caja agregada",
        description: "La caja se ha registrado correctamente",
      });

      setCajas([...cajas, data]);
      onChange(data.id);
      setNuevaCaja({ nombre: "", ubicacion: "", tipo: "comercial" });
      setDialogOpen(false);
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center gap-2">
        <Loader2 className="h-4 w-4 animate-spin" />
        <span className="text-sm text-foreground">Cargando cajas...</span>
      </div>
    );
  }

  return (
    <div className="flex gap-2">
      <div className="flex-1">
        <Select value={value} onValueChange={onChange} required={required}>
          <SelectTrigger>
            <SelectValue placeholder="Selecciona una caja" />
          </SelectTrigger>
          <SelectContent>
            {cajas.map((caja) => (
              <SelectItem key={caja.id} value={caja.id}>
                {caja.nombre} - {caja.ubicacion}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogTrigger asChild>
          <Button type="button" variant="outline" size="icon">
            <Plus className="h-4 w-4" />
          </Button>
        </DialogTrigger>
        <DialogContent>
          <DialogHeader>
            <DialogTitle className="text-foreground">Agregar Nueva Caja</DialogTitle>
            <DialogDescription className="text-foreground">
              Completa los datos de la nueva caja
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4 mt-4">
            <div className="space-y-2">
              <Label htmlFor="nombre">Nombre de la Caja</Label>
              <Input
                id="nombre"
                value={nuevaCaja.nombre}
                onChange={(e) => setNuevaCaja({ ...nuevaCaja, nombre: e.target.value })}
                placeholder="Caja Principal"
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="ubicacion">Ubicación</Label>
              <Input
                id="ubicacion"
                value={nuevaCaja.ubicacion}
                onChange={(e) => setNuevaCaja({ ...nuevaCaja, ubicacion: e.target.value })}
                placeholder="Planta Baja"
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="tipo">Tipo</Label>
              <Select value={nuevaCaja.tipo} onValueChange={(value) => setNuevaCaja({ ...nuevaCaja, tipo: value })}>
                <SelectTrigger id="tipo">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="comercial">Comercial</SelectItem>
                  <SelectItem value="administrativa">Administrativa</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="flex gap-3 pt-4">
              <Button
                type="button"
                variant="outline"
                onClick={() => setDialogOpen(false)}
                className="flex-1"
              >
                Cancelar
              </Button>
              <Button
                type="button"
                onClick={handleAgregarCaja}
                disabled={saving}
                className="flex-1"
              >
                {saving && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                Agregar
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
};

import { useState, useEffect } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { useToast } from "@/hooks/use-toast";
import { Plus, Loader2 } from "lucide-react";

interface EmpleadoSelectorProps {
  value: string;
  onChange: (value: string) => void;
  required?: boolean;
}

export const EmpleadoSelector = ({ value, onChange, required = false }: EmpleadoSelectorProps) => {
  const { toast } = useToast();
  const [empleados, setEmpleados] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [saving, setSaving] = useState(false);
  const [nuevoEmpleado, setNuevoEmpleado] = useState({
    nombreCompleto: "",
    cargo: "",
  });

  useEffect(() => {
    loadEmpleados();
  }, []);

  const loadEmpleados = async () => {
    try {
      const { data, error } = await supabase
        .from("empleados")
        .select("*")
        .eq("activa", true)
        .order("nombre_completo");

      if (error) throw error;
      setEmpleados(data || []);
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

  const handleAgregarEmpleado = async () => {
    if (!nuevoEmpleado.nombreCompleto.trim() || !nuevoEmpleado.cargo.trim()) {
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
        .from("empleados")
        .insert({
          nombre_completo: nuevoEmpleado.nombreCompleto,
          cargo: nuevoEmpleado.cargo,
        })
        .select()
        .single();

      if (error) throw error;

      toast({
        title: "Empleado agregado",
        description: "El empleado se ha registrado correctamente",
      });

      setEmpleados([...empleados, data]);
      onChange(data.id);
      setNuevoEmpleado({ nombreCompleto: "", cargo: "" });
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
        <span className="text-sm text-foreground">Cargando empleados...</span>
      </div>
    );
  }

  return (
    <div className="flex gap-2">
      <div className="flex-1">
        <Select value={value} onValueChange={onChange} required={required}>
          <SelectTrigger>
            <SelectValue placeholder="Selecciona un empleado" />
          </SelectTrigger>
          <SelectContent>
            {empleados.map((empleado) => (
              <SelectItem key={empleado.id} value={empleado.id}>
                {empleado.nombre_completo} - {empleado.cargo}
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
            <DialogTitle className="text-foreground">Agregar Nuevo Empleado</DialogTitle>
            <DialogDescription className="text-foreground">
              Completa los datos del nuevo empleado
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4 mt-4">
            <div className="space-y-2">
              <Label htmlFor="nombreCompleto">Nombre Completo</Label>
              <Input
                id="nombreCompleto"
                value={nuevoEmpleado.nombreCompleto}
                onChange={(e) => setNuevoEmpleado({ ...nuevoEmpleado, nombreCompleto: e.target.value })}
                placeholder="Juan Pérez"
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="cargo">Cargo</Label>
              <Input
                id="cargo"
                value={nuevoEmpleado.cargo}
                onChange={(e) => setNuevoEmpleado({ ...nuevoEmpleado, cargo: e.target.value })}
                placeholder="Cajero"
              />
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
                onClick={handleAgregarEmpleado}
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

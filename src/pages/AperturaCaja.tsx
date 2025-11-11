import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { useToast } from "@/hooks/use-toast";
import { ArrowLeft, Loader2, DollarSign, Clock, Calendar, User } from "lucide-react";
import { EmpleadoSelector } from "@/components/EmpleadoSelector";
import { CajaSelector } from "@/components/CajaSelector";

const AperturaCaja = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [loading, setLoading] = useState(false);

  const [formData, setFormData] = useState({
    cajaId: "",
    empleadoId: "",
    montoInicial: "",
    observaciones: "",
    fecha: new Date().toISOString().split('T')[0],
    horaInicio: new Date().toTimeString().slice(0, 5),
  });


  const verificarAperturaActiva = async (cajaId: string) => {
    const { data: turnosActivos } = await supabase
      .from("turnos")
      .select(`
        id,
        aperturas (
          id,
          cerrada
        )
      `)
      .eq("caja_id", cajaId)
      .eq("estado", "abierto");

    if (turnosActivos && turnosActivos.length > 0) {
      const tieneAperturaActiva = turnosActivos.some((turno: any) =>
        turno.aperturas && turno.aperturas.some((apertura: any) => !apertura.cerrada)
      );
      return tieneAperturaActiva;
    }
    return false;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!formData.cajaId) {
      toast({
        title: "Campo requerido",
        description: "Debes seleccionar una caja",
        variant: "destructive",
      });
      return;
    }

    if (!formData.empleadoId) {
      toast({
        title: "Campo requerido",
        description: "Debes seleccionar un empleado",
        variant: "destructive",
      });
      return;
    }

    setLoading(true);

    try {
      const tieneAperturaActiva = await verificarAperturaActiva(formData.cajaId);
      if (tieneAperturaActiva) {
        toast({
          title: "Apertura activa existente",
          description: "Ya tienes una apertura activa en esta caja. Debes cerrarla antes de abrir un nuevo turno.",
          variant: "destructive",
        });
        setLoading(false);
        return;
      }

      const { data: turno, error: turnoError } = await supabase
        .from("turnos")
        .insert({
          caja_id: formData.cajaId,
          empleado_id: formData.empleadoId,
          fecha: formData.fecha,
          hora_inicio: formData.horaInicio,
          estado: "abierto",
        })
        .select()
        .single();

      if (turnoError) throw turnoError;

      const { error: aperturaError } = await supabase
        .from("aperturas")
        .insert({
          turno_id: turno.id,
          monto_inicial: parseFloat(formData.montoInicial),
          observaciones: formData.observaciones || null,
        });

      if (aperturaError) throw aperturaError;

      toast({
        title: "Turno iniciado",
        description: "La caja ha sido abierta correctamente",
      });

      navigate("/");
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

  return (
    <div className="min-h-screen bg-gradient-bg">
      <header className="border-b border-border/50 bg-card/90 backdrop-blur-md shadow-soft sticky top-0 z-50">
        <div className="container mx-auto px-6 py-6">
          <div className="flex items-center gap-4">
            <Button 
              variant="ghost" 
              size="icon" 
              onClick={() => navigate("/")} 
              className="hover:bg-muted transition-colors"
            >
              <ArrowLeft className="h-5 w-5" />
            </Button>
            <div>
              <h1 className="text-2xl font-semibold text-title tracking-tight">Apertura de Caja</h1>
              <p className="text-sm text-muted-foreground mt-0.5">Iniciar nuevo turno de trabajo</p>
            </div>
          </div>
        </div>
      </header>

      <main className="container mx-auto px-6 py-8 max-w-2xl">
        <Card className="shadow-medium border border-border/50">
          <CardHeader className="border-b border-border/30 bg-muted/30">
            <div className="flex items-start justify-between">
              <div>
                <CardTitle className="text-xl font-semibold text-title">Datos de Apertura</CardTitle>
                <CardDescription className="text-sm text-muted-foreground mt-1">
                  Complete la información para iniciar el turno
                </CardDescription>
              </div>
              <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center">
                <DollarSign className="h-6 w-6 text-primary" />
              </div>
            </div>
          </CardHeader>
          <CardContent className="pt-6">
            <form onSubmit={handleSubmit} className="space-y-6">
              {/* Selector de Caja */}
              <div className="space-y-2">
                <Label className="text-sm font-medium text-foreground">Caja Asignada</Label>
                <CajaSelector
                  value={formData.cajaId}
                  onChange={(value) => setFormData({ ...formData, cajaId: value })}
                  required
                />
              </div>

              {/* Fecha y Hora */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="fecha" className="text-sm font-medium text-foreground flex items-center gap-2">
                    <Calendar className="h-4 w-4 text-muted-foreground" />
                    Fecha
                  </Label>
                  <Input
                    id="fecha"
                    type="date"
                    value={formData.fecha}
                    onChange={(e) => setFormData({ ...formData, fecha: e.target.value })}
                    required
                    className="h-10 border-border/50 focus:ring-2 focus:ring-primary/20"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="horaInicio" className="text-sm font-medium text-foreground flex items-center gap-2">
                    <Clock className="h-4 w-4 text-muted-foreground" />
                    Hora de Inicio
                  </Label>
                  <Input
                    id="horaInicio"
                    type="time"
                    value={formData.horaInicio}
                    onChange={(e) => setFormData({ ...formData, horaInicio: e.target.value })}
                    required
                    className="h-10 border-border/50 focus:ring-2 focus:ring-primary/20"
                  />
                </div>
              </div>

              {/* Empleado */}
              <div className="space-y-2">
                <Label className="text-sm font-medium text-foreground flex items-center gap-2">
                  <User className="h-4 w-4 text-muted-foreground" />
                  Empleado Responsable
                </Label>
                <EmpleadoSelector
                  value={formData.empleadoId}
                  onChange={(value) => setFormData({ ...formData, empleadoId: value })}
                  required
                />
              </div>

              {/* Monto Inicial */}
              <div className="space-y-2">
                <Label htmlFor="montoInicial" className="text-sm font-medium text-foreground flex items-center gap-2">
                  <DollarSign className="h-4 w-4 text-muted-foreground" />
                  Monto Inicial (USD)
                </Label>
                <div className="relative">
                  <span className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground text-sm">$</span>
                  <Input
                    id="montoInicial"
                    type="number"
                    step="0.01"
                    min="0"
                    value={formData.montoInicial}
                    onChange={(e) => setFormData({ ...formData, montoInicial: e.target.value })}
                    placeholder="0.00"
                    required
                    className="pl-7 h-10 border-border/50 focus:ring-2 focus:ring-primary/20"
                  />
                </div>
                <p className="text-xs text-muted-foreground">
                  Monto en efectivo con el que inicia el turno
                </p>
              </div>

              {/* Observaciones */}
              <div className="space-y-2">
                <Label htmlFor="observaciones" className="text-sm font-medium text-foreground">
                  Observaciones (Opcional)
                </Label>
                <Textarea
                  id="observaciones"
                  value={formData.observaciones}
                  onChange={(e) => setFormData({ ...formData, observaciones: e.target.value })}
                  placeholder="Notas adicionales sobre la apertura..."
                  rows={3}
                  className="resize-none border-border/50 focus:ring-2 focus:ring-primary/20"
                />
              </div>

              {/* Botones de Acción */}
              <div className="flex gap-3 pt-4 border-t border-border/30">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => navigate("/")}
                  className="flex-1 h-11"
                >
                  Cancelar
                </Button>
                <Button 
                  type="submit" 
                  disabled={loading} 
                  className="flex-1 h-11 bg-primary hover:bg-primary-hover shadow-primary"
                >
                  {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                  Iniciar Turno
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      </main>
    </div>
  );
};

export default AperturaCaja;
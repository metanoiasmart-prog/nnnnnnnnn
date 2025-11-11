import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { useToast } from "@/hooks/use-toast";
import { ArrowLeft, Trash2, Edit } from "lucide-react";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

const Configuraciones = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [parametros, setParametros] = useState<any[]>([]);
  const [cajas, setCajas] = useState<any[]>([]);
  const [empleados, setEmpleados] = useState<any[]>([]);
  const [editDialogOpen, setEditDialogOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<any>(null);
  const [editType, setEditType] = useState<"empleado" | "caja" | null>(null);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      const { data: parametrosData } = await supabase
        .from("parametros")
        .select("*")
        .order("clave");

      const { data: cajasData } = await supabase
        .from("cajas")
        .select("*")
        .order("nombre");

      const { data: empleadosData } = await supabase
        .from("empleados")
        .select("*")
        .order("nombre_completo");

      if (parametrosData) setParametros(parametrosData);
      if (cajasData) setCajas(cajasData);
      if (empleadosData) setEmpleados(empleadosData);
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    }
  };

  const actualizarParametro = async (id: string, valor: string) => {
    try {
      const { error } = await supabase
        .from("parametros")
        .update({ valor })
        .eq("id", id);

      if (error) throw error;

      toast({
        title: "Parámetro actualizado",
        description: "El cambio se guardó correctamente",
      });

      loadData();
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    }
  };

  const editarEmpleado = (empleado: any) => {
    setEditingItem({...empleado});
    setEditType("empleado");
    setEditDialogOpen(true);
  };

  const editarCaja = (caja: any) => {
    setEditingItem({...caja});
    setEditType("caja");
    setEditDialogOpen(true);
  };

  const guardarEdicion = async () => {
    if (!editingItem || !editType) return;

    try {
      if (editType === "empleado") {
        const { error } = await supabase
          .from("empleados")
          .update({
            nombre_completo: editingItem.nombre_completo,
            cargo: editingItem.cargo,
          })
          .eq("id", editingItem.id);

        if (error) throw error;

        toast({
          title: "Empleado actualizado",
          description: "Los datos se actualizaron correctamente",
        });
      } else if (editType === "caja") {
        const { error } = await supabase
          .from("cajas")
          .update({
            nombre: editingItem.nombre,
            ubicacion: editingItem.ubicacion,
            tipo: editingItem.tipo,
          })
          .eq("id", editingItem.id);

        if (error) throw error;

        toast({
          title: "Caja actualizada",
          description: "Los datos se actualizaron correctamente",
        });
      }

      setEditDialogOpen(false);
      setEditingItem(null);
      setEditType(null);
      loadData();
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    }
  };

  const eliminarEmpleado = async (id: string, nombre: string) => {
    if (!confirm(`¿Estás seguro de eliminar al empleado ${nombre}?`)) return;

    try {
      const { error } = await supabase
        .from("empleados")
        .delete()
        .eq("id", id);

      if (error) throw error;

      toast({
        title: "Empleado eliminado",
        description: "El empleado fue eliminado correctamente",
      });

      loadData();
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    }
  };

  const eliminarCaja = async (id: string, nombre: string) => {
    if (!confirm(`¿Estás seguro de eliminar la caja ${nombre}?`)) return;

    try {
      const { error } = await supabase
        .from("cajas")
        .delete()
        .eq("id", id);

      if (error) throw error;

      toast({
        title: "Caja eliminada",
        description: "La caja fue eliminada correctamente",
      });

      loadData();
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    }
  };

  return (
    <div className="min-h-screen bg-gradient-bg animate-slide-up">
      <header className="border-b-2 border-secondary/20 bg-card/80 backdrop-blur-xl shadow-soft sticky top-0 z-50">
        <div className="container mx-auto px-6 py-8">
          <div className="flex items-center gap-4">
            <Button variant="outline" size="icon" onClick={() => navigate("/")} className="hover:scale-110 transition-transform">
              <ArrowLeft className="h-5 w-5" />
            </Button>
            <div>
              <h1 className="text-3xl font-bold text-title">Configuraciones</h1>
              <p className="text-base text-muted-foreground font-medium">Gestiona parámetros, cajas y empleados</p>
            </div>
          </div>
        </div>
      </header>

      <main className="container mx-auto px-6 py-12 max-w-6xl">
        <Tabs defaultValue="parametros">
          <TabsList className="grid w-full grid-cols-3 h-14 bg-card shadow-soft border-2 border-primary/20">
            <TabsTrigger value="parametros" className="text-base font-semibold data-[state=active]:bg-gradient-primary data-[state=active]:text-white">Parámetros</TabsTrigger>
            <TabsTrigger value="cajas" className="text-base font-semibold data-[state=active]:bg-gradient-primary data-[state=active]:text-white">Cajas</TabsTrigger>
            <TabsTrigger value="empleados" className="text-base font-semibold data-[state=active]:bg-gradient-primary data-[state=active]:text-white">Empleados</TabsTrigger>
          </TabsList>

          <TabsContent value="parametros">
            <Card className="shadow-large border-2 border-primary/20 hover:border-primary/40 transition-all duration-300">
              <CardHeader className="bg-gradient-to-r from-primary/5 to-secondary/5 border-b-2 border-primary/10">
                <CardTitle className="text-2xl font-bold text-title">Parámetros del Sistema</CardTitle>
                <CardDescription className="text-base text-muted-foreground font-medium">
                  Configura los valores principales del sistema
                </CardDescription>
              </CardHeader>
              <CardContent className="pt-6">
                <div className="space-y-6">
                  {parametros.map((param) => (
                    <div key={param.id} className="flex items-end gap-4">
                      <div className="flex-1 space-y-2">
                        <Label>{param.clave.replace(/_/g, " ").toUpperCase()}</Label>
                        <Input
                          type="number"
                          step="0.01"
                          defaultValue={param.valor}
                          onBlur={(e) => {
                            if (e.target.value !== param.valor) {
                              actualizarParametro(param.id, e.target.value);
                            }
                          }}
                        />
                        {param.descripcion && (
                          <p className="text-sm text-foreground">{param.descripcion}</p>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="cajas">
            <Card className="shadow-large border-2 border-accent/20 hover:border-accent/40 transition-all duration-300">
              <CardHeader className="bg-gradient-to-r from-accent/5 to-warning/5 border-b-2 border-accent/10">
                <div className="flex items-center justify-between">
                  <div>
                    <CardTitle className="text-2xl font-bold text-title">Gestión de Cajas</CardTitle>
                    <CardDescription className="text-base text-muted-foreground font-medium">
                      Administra las cajas del sistema
                    </CardDescription>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="pt-6">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Nombre</TableHead>
                      <TableHead>Ubicación</TableHead>
                      <TableHead>Tipo</TableHead>
                      <TableHead>Estado</TableHead>
                      <TableHead className="text-right">Acciones</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {cajas.map((caja) => (
                      <TableRow key={caja.id}>
                        <TableCell className="font-medium">{caja.nombre}</TableCell>
                        <TableCell>{caja.ubicacion}</TableCell>
                        <TableCell className="capitalize">{caja.tipo}</TableCell>
                        <TableCell>
                          <span
                            className={`px-2 py-1 rounded-full text-xs ${
                              caja.activa
                                ? "bg-green-100 text-green-800"
                                : "bg-red-100 text-red-800"
                            }`}
                          >
                            {caja.activa ? "Activa" : "Inactiva"}
                          </span>
                        </TableCell>
                        <TableCell className="text-right">
                          <div className="flex justify-end gap-2">
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => editarCaja(caja)}
                            >
                              <Edit className="h-4 w-4 mr-1" />
                              Editar
                            </Button>
                            <Button
                              variant="destructive"
                              size="sm"
                              onClick={() => eliminarCaja(caja.id, caja.nombre)}
                            >
                              <Trash2 className="h-4 w-4 mr-1" />
                              Eliminar
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="empleados">
            <Card className="shadow-large border-2 border-success/20 hover:border-success/40 transition-all duration-300">
              <CardHeader className="bg-gradient-to-r from-success/5 to-primary/5 border-b-2 border-success/10">
                <div className="flex items-center justify-between">
                  <div>
                    <CardTitle className="text-2xl font-bold text-title">Gestión de Empleados</CardTitle>
                    <CardDescription className="text-base text-muted-foreground font-medium">
                      Administra los empleados del sistema
                    </CardDescription>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="pt-6">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Nombre</TableHead>
                      <TableHead>Cargo</TableHead>
                      <TableHead>Estado</TableHead>
                      <TableHead className="text-right">Acciones</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {empleados.map((empleado) => (
                      <TableRow key={empleado.id}>
                        <TableCell className="font-medium">{empleado.nombre_completo}</TableCell>
                        <TableCell>{empleado.cargo}</TableCell>
                        <TableCell>
                          <span
                            className={`px-2 py-1 rounded-full text-xs ${
                              empleado.activo
                                ? "bg-green-100 text-green-800"
                                : "bg-red-100 text-red-800"
                            }`}
                          >
                            {empleado.activo ? "Activo" : "Inactivo"}
                          </span>
                        </TableCell>
                        <TableCell className="text-right">
                          <div className="flex justify-end gap-2">
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => editarEmpleado(empleado)}
                            >
                              <Edit className="h-4 w-4 mr-1" />
                              Editar
                            </Button>
                            <Button
                              variant="destructive"
                              size="sm"
                              onClick={() => eliminarEmpleado(empleado.id, empleado.nombre_completo)}
                            >
                              <Trash2 className="h-4 w-4 mr-1" />
                              Eliminar
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </main>

      <Dialog open={editDialogOpen} onOpenChange={setEditDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle className="text-foreground">
              {editType === "empleado" ? "Editar Empleado" : "Editar Caja"}
            </DialogTitle>
            <DialogDescription className="text-foreground">
              Modifica los datos y guarda los cambios
            </DialogDescription>
          </DialogHeader>

          {editingItem && editType === "empleado" && (
            <div className="space-y-4 mt-4">
              <div className="space-y-2">
                <Label htmlFor="nombre_completo">Nombre Completo</Label>
                <Input
                  id="nombre_completo"
                  value={editingItem.nombre_completo}
                  onChange={(e) => setEditingItem({ ...editingItem, nombre_completo: e.target.value })}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="cargo">Cargo</Label>
                <Input
                  id="cargo"
                  value={editingItem.cargo}
                  onChange={(e) => setEditingItem({ ...editingItem, cargo: e.target.value })}
                />
              </div>
            </div>
          )}

          {editingItem && editType === "caja" && (
            <div className="space-y-4 mt-4">
              <div className="space-y-2">
                <Label htmlFor="nombre">Nombre</Label>
                <Input
                  id="nombre"
                  value={editingItem.nombre}
                  onChange={(e) => setEditingItem({ ...editingItem, nombre: e.target.value })}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="ubicacion">Ubicación</Label>
                <Input
                  id="ubicacion"
                  value={editingItem.ubicacion}
                  onChange={(e) => setEditingItem({ ...editingItem, ubicacion: e.target.value })}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="tipo">Tipo</Label>
                <Input
                  id="tipo"
                  value={editingItem.tipo}
                  onChange={(e) => setEditingItem({ ...editingItem, tipo: e.target.value })}
                  placeholder="comercial o principal"
                />
              </div>
            </div>
          )}

          <div className="flex gap-3 pt-4">
            <Button
              variant="outline"
              onClick={() => setEditDialogOpen(false)}
              className="flex-1"
            >
              Cancelar
            </Button>
            <Button
              onClick={guardarEdicion}
              className="flex-1"
            >
              Guardar Cambios
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default Configuraciones;

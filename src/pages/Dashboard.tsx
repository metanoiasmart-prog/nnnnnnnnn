import { useNavigate } from "react-router-dom";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Settings, Landmark, RotateCcwSquare, ArrowRightLeft, BriefcaseBusiness } from "lucide-react";

const Dashboard = () => {
  const navigate = useNavigate();

  const operacionesCards = [
    {
      title: "Apertura de Caja",
      description: "Iniciar turno con fondo inicial",
      action: () => navigate("/apertura-caja"),
      icon: Landmark,
      bgColor: "bg-primary",
      borderColor: "border-primary/30",
      hoverBorderColor: "hover:border-primary",
    },
    {
      title: "Arqueo de Caja",
      description: "Contar efectivo y cerrar turno",
      action: () => navigate("/arqueo-caja"),
      icon: RotateCcwSquare,
      bgColor: "bg-secondary",
      borderColor: "border-secondary/30",
      hoverBorderColor: "hover:border-secondary",
    },
    {
      title: "Traslado de Efectivo",
      description: "Enviar efectivo a Caja Principal",
      action: () => navigate("/traslado-efectivo"),
      icon: ArrowRightLeft,
      bgColor: "bg-accent",
      borderColor: "border-accent/30",
      hoverBorderColor: "hover:border-accent",
    },
    {
      title: "Recepción de Traslado",
      description: "Recibir efectivo en Caja Principal",
      action: () => navigate("/recepcion-traslado"),
      icon: BriefcaseBusiness,
      bgColor: "bg-success",
      borderColor: "border-success/30",
      hoverBorderColor: "hover:border-success",
    },
  ];

  return (
    <div className="min-h-screen bg-gradient-bg">
      <header className="border-b border-border bg-card/90 backdrop-blur-sm shadow-soft sticky top-0 z-50">
        <div className="container mx-auto px-6 py-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-title">
                Sistema de Gestión de Efectivo
              </h1>
              <p className="text-sm text-muted-foreground mt-1">Tienda Catu - Panel de Control</p>
            </div>
            <Button 
              variant="outline"
              size="icon"
              onClick={() => navigate("/configuraciones")}
              title="Configuraciones"
            >
              <Settings className="h-5 w-5" />
            </Button>
          </div>
        </div>
      </header>

      <main className="container mx-auto px-6 py-12 max-w-7xl">
        <section>
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold mb-3 text-title">
              Operaciones y Indicadores
            </h2>
            <p className="text-muted-foreground text-base">
              Selecciona la operación que deseas realizar o consulta los indicadores
            </p>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {operacionesCards.map((operacion, index) => {
              const Icon = operacion.icon;
              return (
                <Card
                  key={index}
                  className={`group overflow-hidden hover:shadow-lg transition-all duration-200 cursor-pointer border ${operacion.borderColor} ${operacion.hoverBorderColor} hover:scale-[1.02] bg-card`}
                  onClick={operacion.action}
                >
                  <CardHeader className="text-center p-6">
                    <div className={`mx-auto mb-4 w-16 h-16 rounded-xl ${operacion.bgColor} flex items-center justify-center transition-transform duration-200 group-hover:scale-105`}>
                      <Icon className="h-8 w-8 text-white" />
                    </div>
                    <CardTitle className="text-xl mb-2 text-title font-bold">
                      {operacion.title}
                    </CardTitle>
                    <CardDescription className="text-sm text-muted-foreground">
                      {operacion.description}
                    </CardDescription>
                  </CardHeader>
                </Card>
              );
            })}
          </div>
        </section>
      </main>
    </div>
  );
};

export default Dashboard;

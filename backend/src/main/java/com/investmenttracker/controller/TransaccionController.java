import java.math.BigDecimal;
import java.security.Principal;

@RestController
@RequestMapping("/api/transacciones")
@PreAuthorize("isAuthenticated()")
public class TransaccionController {

    @Autowired
    private TransaccionService transaccionService;

    @PostMapping
    public ResponseEntity<TransaccionDTO> crearTransaccion(
            @Valid @RequestBody TransaccionRequest request,
            Principal principal) {
        return ResponseEntity.ok(
                transaccionService.crearTransaccion(request, principal.getName()));
    }

    @GetMapping("/resumen")
    public ResponseEntity<ResumenInversionesDTO> getResumen(Principal principal) {
        return ResponseEntity.ok(
                transaccionService.getResumen(principal.getName()));
    }

    @GetMapping("/calculadora-venta/{simbolo}")
    public ResponseEntity<CalculoOptimoDTO> calcularVentaOptima(
            @PathVariable String simbolo,
            @RequestParam BigDecimal gananciaDeseada,
            @RequestParam Long plataformaId,
            Principal principal) {
        return ResponseEntity.ok(
                transaccionService.calcularVentaOptima(
                        principal.getName(), simbolo, gananciaDeseada, plataformaId));
    }
}
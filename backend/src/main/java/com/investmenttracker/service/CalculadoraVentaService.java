import java.math.BigDecimal;

@Service
public class CalculadoraVentaService {
    
    @Autowired
    private TransaccionRepository transaccionRepository;
    
    @Autowired
    private ComisionService comisionService;
    
    public CalculoOptimoDTO calcularVentaOptima(
            Long usuarioId, String simbolo, 
            BigDecimal gananciaDeseada, Long plataformaId) {
        
        // Obtener posición actual
        PosicionActual posicion = obtenerPosicionActual(usuarioId, simbolo);
        
        if (posicion.getCantidad() <= 0) {
            throw new NoPositionException("No tienes acciones de " +
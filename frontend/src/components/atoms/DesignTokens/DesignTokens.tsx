import styles from './DesignTokens.module.css';

import { useEffect, useRef, useState } from 'react';

import type { ReactElement, ReactNode } from 'react';

import type { DesignTokensProps, DesignTokensSection } from './DesignTokens.types';

type TokenVariant = 'swatch' | 'bar' | 'radius' | 'text';

const TOKENS = {
  brand: [
    '--color-primary',
    '--color-primary-hover',
    '--color-primary-light',
    '--color-accent',
    '--color-accent-hover',
  ],
  semantic: [
    '--color-success',
    '--color-success-hover',
    '--color-danger',
    '--color-danger-hover',
    '--color-warning',
    '--color-warning-hover',
    '--color-info',
    '--color-info-hover',
  ],
  neutral: [
    '--color-bg',
    '--color-surface',
    '--color-border',
    '--color-text',
    '--color-text-muted',
    '--color-text-inverse',
  ],
  fontFamilies: ['--font-sans', '--font-mono'],
  fontSizes: [
    '--font-size-xs',
    '--font-size-sm',
    '--font-size-base',
    '--font-size-lg',
    '--font-size-xl',
    '--font-size-2xl',
    '--font-size-3xl',
    '--font-size-4xl',
  ],
  fontWeights: [
    '--font-weight-regular',
    '--font-weight-medium',
    '--font-weight-semibold',
    '--font-weight-bold',
  ],
  lineHeights: ['--line-height-tight', '--line-height-normal', '--line-height-relaxed'],
  letterSpacing: ['--letter-spacing-tight', '--letter-spacing-normal', '--letter-spacing-wide'],
  spacing: [
    '--space-1',
    '--space-2',
    '--space-3',
    '--space-4',
    '--space-5',
    '--space-6',
    '--space-8',
    '--space-10',
  ],
  radius: ['--radius-sm', '--radius-md', '--radius-lg', '--radius-xl', '--radius-full'],
  shadows: [
    '--shadow-xs',
    '--shadow-sm',
    '--shadow-md',
    '--shadow-lg',
    '--shadow-xl',
    '--shadow-2xl',
  ],
  grid: ['--grid-columns', '--grid-gutter', '--container-max-width'],
  breakpoints: [
    '--breakpoint-sm',
    '--breakpoint-md',
    '--breakpoint-lg',
    '--breakpoint-xl',
    '--breakpoint-2xl',
  ],
  zIndex: [
    '--z-base',
    '--z-dropdown',
    '--z-sticky',
    '--z-overlay',
    '--z-modal',
    '--z-popover',
    '--z-tooltip',
    '--z-toast',
  ],
  durations: [
    '--duration-instant',
    '--duration-fast',
    '--duration-normal',
    '--duration-slow',
    '--duration-slower',
  ],
  easings: ['--ease-linear', '--ease-in', '--ease-out', '--ease-in-out', '--ease-spring'],
  stagger: ['--stagger-fast', '--stagger-normal', '--stagger-slow'],
} as const;

const THEMES = ['light', 'dark', 'high-contrast'] as const;
type ThemeName = (typeof THEMES)[number];

const EASING_PATHS: Record<string, string> = {
  '--ease-linear': 'M 0 100 L 100 0',
  '--ease-in': 'M 0 100 C 40 100, 100 0, 100 0',
  '--ease-out': 'M 0 100 C 0 100, 20 0, 100 0',
  '--ease-in-out': 'M 0 100 C 40 100, 20 0, 100 0',
  '--ease-spring': 'M 0 100 C 34 -56, 64 0, 100 0',
};

const PENDULUM_PATHS = {
  pendulum: 'M 0 50 Q 12 10, 25 50 T 50 50 T 75 50 T 100 50',
  'pendulum-damped': 'M 0 50 Q 12 20, 25 50 Q 35 30, 50 50 Q 60 40, 75 50 Q 85 45, 100 50',
} as const;

const SWEEP_COLS = 8;
const SWEEP_ROWS = 4;

function TokenValue({ name }: { name: string }): ReactElement {
  const ref = useRef<HTMLSpanElement>(null);
  const [value, setValue] = useState('');

  useEffect(() => {
    if (ref.current) {
      setValue(getComputedStyle(ref.current).getPropertyValue(name).trim());
    }
  }, [name]);

  return <span ref={ref}>{value}</span>;
}

function Section({ title, children }: { title: string; children: ReactNode }): ReactElement {
  return (
    <section className={styles.section}>
      <h2 className={styles.sectionTitle}>{title}</h2>
      {children}
    </section>
  );
}

function TokenCard({ name, variant }: { name: string; variant: TokenVariant }): ReactElement {
  return (
    <div className={styles.card}>
      {variant === 'swatch' && (
        <div className={styles.swatch} style={{ background: `var(${name})` }} />
      )}
      {variant === 'bar' && <div className={styles.bar} style={{ width: `var(${name})` }} />}
      {variant === 'radius' && (
        <div className={styles.radiusBox} style={{ borderRadius: `var(${name})` }} />
      )}
      <code className={styles.code}>{name}</code>
      <div className={styles.value}>
        <TokenValue name={name} />
      </div>
    </div>
  );
}

function TokenGrid({
  tokens,
  variant,
}: {
  tokens: readonly string[];
  variant: TokenVariant;
}): ReactElement {
  return (
    <div className={styles.grid}>
      {tokens.map((name) => (
        <TokenCard key={name} name={name} variant={variant} />
      ))}
    </div>
  );
}

function ThemeBlock({ theme }: { theme: ThemeName }): ReactElement {
  return (
    <div data-theme={theme}>
      <Section title={`Brand — ${theme}`}>
        <TokenGrid tokens={TOKENS.brand} variant="swatch" />
      </Section>
      <Section title={`Semantic — ${theme}`}>
        <TokenGrid tokens={TOKENS.semantic} variant="swatch" />
      </Section>
      <Section title={`Neutral — ${theme}`}>
        <TokenGrid tokens={TOKENS.neutral} variant="swatch" />
      </Section>
    </div>
  );
}

function ColorsSection(): ReactElement {
  return (
    <>
      {THEMES.map((theme) => (
        <ThemeBlock key={theme} theme={theme} />
      ))}
    </>
  );
}

function TypographySection(): ReactElement {
  return (
    <>
      <Section title="Font families">
        <TokenGrid tokens={TOKENS.fontFamilies} variant="text" />
      </Section>
      <Section title="Font sizes">
        <TokenGrid tokens={TOKENS.fontSizes} variant="text" />
      </Section>
      <Section title="Font weights">
        <TokenGrid tokens={TOKENS.fontWeights} variant="text" />
      </Section>
      <Section title="Line heights">
        <TokenGrid tokens={TOKENS.lineHeights} variant="text" />
      </Section>
      <Section title="Letter spacing">
        <TokenGrid tokens={TOKENS.letterSpacing} variant="text" />
      </Section>
      <Section title="Demo">
        <h1>Heading 1</h1>
        <h2>Heading 2</h2>
        <h3>Heading 3</h3>
        <p>Body — párrafo estándar con la fuente corporativa.</p>
        <p>
          <code>Monospace — código con JetBrains Mono.</code>
        </p>
      </Section>
    </>
  );
}

function SpacingSection(): ReactElement {
  return (
    <Section title="Spacing">
      {TOKENS.spacing.map((name) => (
        <div key={name} className={styles.spacingRow}>
          <code className={styles.spacingLabel}>{name}</code>
          <div className={styles.bar} style={{ width: `var(${name})` }} />
          <span className={styles.spacingValue}>
            <TokenValue name={name} />
          </span>
        </div>
      ))}
    </Section>
  );
}

function RadiusSection(): ReactElement {
  return (
    <Section title="Radius">
      <TokenGrid tokens={TOKENS.radius} variant="radius" />
    </Section>
  );
}

function ShadowCard({ shadow }: { shadow: string }): ReactElement {
  return (
    <div className={styles.shadowCard} style={{ boxShadow: `var(${shadow})` }}>
      <h3 className={styles.shadowTitle}>Card title</h3>
      <p className={styles.shadowBody}>
        Contenido de ejemplo para visualizar la sombra aplicada a una tarjeta.
      </p>
      <code className={styles.code}>{shadow}</code>
    </div>
  );
}

function ShadowsSection(): ReactElement {
  return (
    <Section title="Shadows">
      <div className={styles.shadowStage}>
        <div className={styles.shadowGrid}>
          {TOKENS.shadows.map((name) => (
            <ShadowCard key={name} shadow={name} />
          ))}
        </div>
      </div>
    </Section>
  );
}

function GridSection(): ReactElement {
  return (
    <Section title="Grid">
      <div className={styles.gutterRow}>
        <code className={styles.gutterLabel}>--grid-gutter (espaciado entre celdas)</code>
        <div className={styles.gutterGrid}>
          {Array.from({ length: 6 }, (_, i) => (
            <div key={i} className={styles.gutterCell} />
          ))}
        </div>
      </div>
      <div className={styles.containerRow}>
        <code className={styles.containerLabel}>--container-max-width</code>
        <div className={styles.containerTrack}>
          <div
            className={styles.containerBar}
            style={{ width: `min(var(--container-max-width), 100%)` }}
          />
        </div>
        <span className={styles.containerValue}>
          <TokenValue name="--container-max-width" />
        </span>
      </div>
      <div className={styles.containerRow}>
        <code className={styles.containerLabel}>--grid-columns</code>
        <div className={styles.containerTrack}>
          <div className={styles.containerBar} style={{ width: '100%' }} />
        </div>
        <span className={styles.containerValue}>
          <TokenValue name="--grid-columns" />
        </span>
      </div>
    </Section>
  );
}

function BreakpointsSection(): ReactElement {
  return (
    <Section title="Breakpoints">
      {TOKENS.breakpoints.map((name) => (
        <div key={name} className={styles.containerRow}>
          <code className={styles.containerLabel}>{name}</code>
          <div className={styles.containerTrack}>
            <div className={styles.containerBar} style={{ width: `min(var(${name}), 100%)` }} />
          </div>
          <span className={styles.containerValue}>
            <TokenValue name={name} />
          </span>
        </div>
      ))}
    </Section>
  );
}

function ZIndexSection(): ReactElement {
  return (
    <Section title="Z-index">
      <div className={styles.zIndexLayout}>
        <div className={styles.zStack}>
          {TOKENS.zIndex.map((name, i) => (
            <div
              key={name}
              className={styles.zBox}
              style={{
                zIndex: `var(${name})`,
                left: `${i * 32}px`,
                top: `${i * 26}px`,
              }}
            >
              {name.replace('--z-', '')}
            </div>
          ))}
        </div>
        <table className={styles.zTable}>
          <thead>
            <tr>
              <th>Token</th>
              <th>Profundidad</th>
              <th>Valor</th>
            </tr>
          </thead>
          <tbody>
            {TOKENS.zIndex.map((name, i) => (
              <tr key={name}>
                <td>
                  <code>{name}</code>
                </td>
                <td>
                  {i + 1} / {TOKENS.zIndex.length}
                </td>
                <td>
                  <TokenValue name={name} />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Section>
  );
}

function LayoutSection(): ReactElement {
  return (
    <>
      <GridSection />
      <BreakpointsSection />
      <ZIndexSection />
    </>
  );
}

function DurationDemo(): ReactElement {
  const [key, setKey] = useState(0);
  return (
    <Section title="Durations">
      <button type="button" className={styles.replayButton} onClick={() => setKey((k) => k + 1)}>
        Replay
      </button>
      {TOKENS.durations.map((name) => (
        <div key={name} className={styles.motionRow}>
          <code className={styles.motionLabel}>{name}</code>
          <div className={styles.motionTrack}>
            <div
              key={`${name}-${key}`}
              className={styles.motionWrapper}
              style={{ animationDuration: `var(${name})` }}
            >
              <div className={styles.motionBall} />
            </div>
          </div>
          <span className={styles.motionValue}>
            <TokenValue name={name} />
          </span>
        </div>
      ))}
    </Section>
  );
}

function EasingDemo(): ReactElement {
  const [key, setKey] = useState(0);
  return (
    <Section title="Easings">
      <p className={styles.easingIntro}>
        El <strong>easing</strong> define la <em>forma</em> del movimiento en el tiempo. Todos los
        ejemplos usan <code>--duration-slower</code> (misma duración); lo que cambia es la curva de
        velocidad. Las 5 primeras usan <code>cubic-bezier</code> estándar. Las 2 últimas usan
        keyframes compuestos ( <code>--ease-pendulum</code> y <code>--ease-pendulum-damped</code>)
        que simulan el comportamiento de un péndulo físico.
      </p>
      <button type="button" className={styles.replayButton} onClick={() => setKey((k) => k + 1)}>
        Replay (todos a la misma duración)
      </button>
      {TOKENS.easings.map((name) => (
        <div key={name} className={styles.easingRow}>
          <code className={styles.easingLabel}>{name}</code>
          <svg className={styles.easingCurve} viewBox="0 0 100 100" aria-hidden="true">
            <path className={styles.easingCurvePath} d={EASING_PATHS[name] ?? ''} />
          </svg>
          <div className={styles.easingTrack}>
            <div
              key={`${name}-${key}`}
              className={styles.easingWrapper}
              style={{ animationTimingFunction: `var(${name})` }}
            >
              <div className={styles.motionBall} />
            </div>
          </div>
          <span className={styles.easingValue}>
            <TokenValue name={name} />
          </span>
        </div>
      ))}

      <p className={styles.amplitudeNote}>
        <strong>Nota:</strong> la amplitud de ambos péndulos se controla con el token global
        <code>--pendulum-amplitude</code> (por defecto 120px). Cambiar ese token ajusta la
        oscilación de todos los consumidores. El péndulo amortiguado aplica factores fijos por ciclo
        (80%, 55%, 30%, 12.5% y 0) sobre la amplitud configurada.
      </p>
      <div className={styles.pendulumRow}>
        <code className={styles.easingLabel}>--ease-pendulum</code>
        <svg className={styles.pendulumSvg} viewBox="0 0 100 100" aria-hidden="true">
          <path className={styles.pendulumPath} d={PENDULUM_PATHS.pendulum} />
        </svg>
        <div className={styles.pendulumTrack}>
          <div key={`pendulum-${key}`} className={styles.pendulumBall} />
        </div>
        <span className={styles.easingValue}>oscilación continua</span>
      </div>

      <p className={styles.amplitudeNote}>
        <strong>Nota:</strong> la amplitud de ambos péndulos se controla con el token global
        <code>--pendulum-amplitude</code> (por defecto 120px). Cambiar ese token ajusta la
        oscilación de todos los consumidores. El péndulo amortiguado aplica factores fijos por ciclo
        (80%, 55%, 30%, 12.5% y 0) sobre la amplitud configurada.
      </p>
      <div className={styles.pendulumRow}>
        <code className={styles.easingLabel}>--ease-pendulum-damped</code>
        <svg className={styles.pendulumSvg} viewBox="0 0 100 100" aria-hidden="true">
          <path className={styles.pendulumPath} d={PENDULUM_PATHS['pendulum-damped']} />
        </svg>
        <div className={styles.pendulumTrack}>
          <div
            key={`pendulum-damped-${key}`}
            className={`${styles.pendulumBall} ${styles.pendulumBallDamped}`}
          />
        </div>
        <span className={styles.easingValue}>oscilación amortiguada</span>
      </div>
    </Section>
  );
}

function StaggerDemo(): ReactElement {
  const [key, setKey] = useState(0);
  const total = SWEEP_COLS * SWEEP_ROWS;

  const sweepVariants = [
    {
      id: 'tl-br',
      label: '↘  arriba-izquierda  →  abajo-derecha',
      className: styles.sweepCellTlBr,
      classNameText: 'sweepCellTlBr',
      getDelay: (row: number, col: number): number => row + col,
    },
    {
      id: 'tr-bl',
      label: '↙  arriba-derecha    →  abajo-izquierda',
      className: styles.sweepCellTrBl,
      classNameText: 'sweepCellTrBl',
      getDelay: (row: number, col: number): number => row + (SWEEP_COLS - 1 - col),
    },
    {
      id: 'bl-tr',
      label: '↗  abajo-izquierda   →  arriba-derecha',
      className: styles.sweepCellBlTr,
      classNameText: 'sweepCellBlTr',
      getDelay: (row: number, col: number): number => SWEEP_ROWS - 1 - row + col,
    },
    {
      id: 'br-tl',
      label: '↖  abajo-derecha     →  arriba-izquierda',
      className: styles.sweepCellBrTl,
      classNameText: 'sweepCellBrTl',
      getDelay: (row: number, col: number): number => SWEEP_ROWS - 1 - row + (SWEEP_COLS - 1 - col),
    },
  ];

  return (
    <>
      <Section title="Stagger">
        <button type="button" className={styles.replayButton} onClick={() => setKey((k) => k + 1)}>
          Replay
        </button>
        {TOKENS.stagger.map((name) => (
          <div key={name} className={styles.motionRow}>
            <code className={styles.motionLabel}>{name}</code>
            <div className={styles.staggerDots}>
              {Array.from({ length: 5 }, (_, i) => (
                <div
                  key={`${name}-${i}-${key}`}
                  className={styles.staggerDot}
                  style={{ animationDelay: `calc(var(${name}) * ${i})` }}
                />
              ))}
            </div>
            <span className={styles.motionValue}>
              <TokenValue name={name} />
            </span>
          </div>
        ))}
      </Section>

      <Section title="Barrido de página (4 direcciones)">
        <p className={styles.sweepIntro}>
          Barrido diagonal basado en <code>--pasar-pagina</code>: cada celda se retrasa según su
          posición en el grid. Se lee como una página que se recorre en diagonal — útil para
          transiciones de cambio de vista o carga de grids. Se ofrecen las 4 direcciones diagonales.
        </p>

        <div className={styles.sweepInfoGrid}>
          <div className={styles.sweepInfoItem}>
            <span className={styles.sweepInfoLabel}>--pasar-pagina (retardo por paso)</span>
            <span className={styles.sweepInfoValue}>
              <TokenValue name="--pasar-pagina" />
            </span>
          </div>
          <div className={styles.sweepInfoItem}>
            <span className={styles.sweepInfoLabel}>--duration-slow (duración por celda)</span>
            <span className={styles.sweepInfoValue}>
              <TokenValue name="--duration-slow" />
            </span>
          </div>
          <div className={styles.sweepInfoItem}>
            <span className={styles.sweepInfoLabel}>--ease-out (curva)</span>
            <span className={styles.sweepInfoValue}>
              <TokenValue name="--ease-out" />
            </span>
          </div>
        </div>

        <button type="button" className={styles.replayButton} onClick={() => setKey((k) => k + 1)}>
          Replay
        </button>

        {sweepVariants.map((variant) => (
          <div key={variant.id} className={styles.sweepBlock}>
            <code className={styles.sweepDirectionLabel}>
              {variant.label} | --pasar-pagina ({variant.classNameText})
            </code>
            <div className={styles.sweepGrid}>
              {Array.from({ length: total }, (_, i) => {
                const row = Math.floor(i / SWEEP_COLS);
                const col = i % SWEEP_COLS;
                return (
                  <div
                    key={`${variant.id}-${i}-${key}`}
                    className={`${styles.sweepCell} ${variant.className}`}
                    style={{
                      animationDelay: `calc(var(--pasar-pagina) * ${variant.getDelay(row, col)})`,
                    }}
                  />
                );
              })}
            </div>
          </div>
        ))}
      </Section>
    </>
  );
}
function MotionSection(): ReactElement {
  return (
    <>
      <DurationDemo />
      <EasingDemo />
      <StaggerDemo />
    </>
  );
}

const SECTIONS: Record<DesignTokensSection, () => ReactElement> = {
  colors: ColorsSection,
  typography: TypographySection,
  spacing: SpacingSection,
  radius: RadiusSection,
  shadows: ShadowsSection,
  layout: LayoutSection,
  motion: MotionSection,
};

const ALL_SECTIONS: DesignTokensSection[] = [
  'colors',
  'typography',
  'spacing',
  'radius',
  'shadows',
  'layout',
  'motion',
];

/**
 * Catálogo visual de design tokens de Investment Tracker Pro.
 *
 * Lee los tokens del tema activo (`data-theme`) vía `getComputedStyle`.
 * La sección `colors` renderiza siempre los 3 temas (light, dark,
 * high-contrast) para comparación directa.
 *
 * Es un componente documental/decorativo: no debe usarse en vistas de producción.
 */
export function DesignTokens({ section, dataTestId, className }: DesignTokensProps): ReactElement {
  const sections = section ? [section] : ALL_SECTIONS;
  const rootClass = className ? `${styles.root} ${className}` : styles.root;

  return (
    <div className={rootClass} data-testid={dataTestId}>
      {sections.map((key) => {
        const SectionComponent = SECTIONS[key];
        return <SectionComponent key={key} />;
      })}
    </div>
  );
}

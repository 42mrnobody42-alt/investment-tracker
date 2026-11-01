// Type declarations para commitlint.config.js
// (tsconfig.app.json tiene allowJs: false, por eso se necesita .d.ts aparte)
declare const config: {
  extends: string[];
  defaultIgnores: boolean;
  parserPreset: {
    parserOpts: {
      headerPattern: RegExp;
      headerCorrespondence: string[];
      breakingHeaderPattern: RegExp;
    };
  };
  rules: {
    'type-enum': [number, 'always', string[]];
    'type-empty': [number, 'never'];
    'subject-empty': [number, 'never'];
    'subject-full-stop': [number, 'never', string];
    'header-max-length': [number, 'always', number];
    'body-leading-blank': [number, 'always'];
    'footer-leading-blank': [number, 'always'];
  };
};

export default config;

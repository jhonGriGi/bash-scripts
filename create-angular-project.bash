#!/bin/bash

set -e # Salir inmediatamente si un comando falla

# Nombre del proyecto
PROJECT_NAME=$1

# Verificar si se pasó un nombre
if [ -z "$PROJECT_NAME" ]; then
  echo "⚠️  Por favor proporciona un nombre para el proyecto."
  echo "Uso: ./crear-angular.sh nombre-proyecto"
  exit 1
fi

# Comando para crear proyecto
echo "🚀 Creando proyecto Angular llamado: $PROJECT_NAME"

# Instalar Angular CLI si no está instalado
if ! command -v ng &> /dev/null
then
    echo "🔧 Angular CLI no encontrado. Instalando..."
    npm install -g @angular/cli
else
    echo "✅ Angular CLI encontrado."
fi

# Crear el proyecto
ng new "$PROJECT_NAME" --routing --style=scss --strict

# Moverse al directorio del proyecto
cd "$PROJECT_NAME"

# Instalar Angular ESLint
echo "🔧 Instalando Angular ESLint..."
ng add @angular-eslint/schematics --skip-confirmation

# Instalar Prettier, ESLint y plugins
echo "🔧 Instalando Prettier, ESLint y plugins adicionales..."
npm install -D \
  prettier \
  prettier-eslint \
  eslint-config-prettier \
  eslint-plugin-prettier \
  @typescript-eslint/eslint-plugin \
  @typescript-eslint/parser \
  eslint-plugin-simple-import-sort \
  eslint-plugin-unused-imports \
  eslint-plugin-import \
  eslint-import-resolver-typescript \
  puppeteer \
  @eslint/compat \
  @eslint/js \
  @eslint/eslintrc

# Auditando dependencias
npm audit fix --force || echo "⚠️  Algunas vulnerabilidades no se pudieron corregir automáticamente."

# Eliminar configuración antigua de ESLint si existe
if [ -f "eslint.config.js" ]; then
  rm eslint.config.js
fi

# Crear archivo .eslintrc.json
echo "📝 Creando configuración ESLint..."
cat > eslint.config.mjs << 'EOF'
import { defineConfig, globalIgnores } from "eslint/config";
import { fixupConfigRules, fixupPluginRules, fixupConfigRules, fixupConfigRules } from "@eslint/compat";
import typescriptEslint from "@typescript-eslint/eslint-plugin";
import simpleImportSort from "eslint-plugin-simple-import-sort";
import _import from "eslint-plugin-import";
import unusedImports from "eslint-plugin-unused-imports";
import path from "node:path";
import { fileURLToPath } from "node:url";
import js from "@eslint/js";
import { FlatCompat } from "@eslint/eslintrc";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
    baseDirectory: __dirname,
    recommendedConfig: js.configs.recommended,
    allConfig: js.configs.all
});

export default defineConfig([globalIgnores(["projects/**/*"]), {
    files: ["**/*.ts"],

    extends: fixupConfigRules(compat.extends(
        "plugin:@angular-eslint/recommended",
        "plugin:@angular-eslint/template/process-inline-templates",
        "plugin:prettier/recommended",
        "plugin:@typescript-eslint/recommended",
        "plugin:import/recommended",
        "plugin:import/typescript",
    )),

    plugins: {
        "@typescript-eslint": fixupPluginRules(typescriptEslint),
        "simple-import-sort": simpleImportSort,
        import: fixupPluginRules(_import),
        "unused-imports": unusedImports,
    },

    languageOptions: {
        ecmaVersion: 5,
        sourceType: "script",

        parserOptions: {
            project: ["tsconfig.json"],
            createDefaultProgram: true,
        },
    },

    settings: {
        "import/resolver": {
            typescript: {},
        },
    },

    rules: {
        "@angular-eslint/component-class-suffix": ["error", {
            suffixes: ["Page", "Component"],
        }],

        "@angular-eslint/component-selector": ["error", {
            type: "element",
            prefix: "app",
            style: "kebab-case",
        }],

        "@angular-eslint/directive-selector": ["error", {
            type: "attribute",
            prefix: "app",
            style: "camelCase",
        }],

        "@angular-eslint/use-lifecycle-interface": ["error"],
        "@typescript-eslint/naming-convention": 0,

        "simple-import-sort/imports": ["error", {
            groups: [
                ["^\\u0000"],
                ["^@?\\w"],
                ["^\\.\\.(?!/?$)", "^\\.\\./?$"],
                ["^\\./(?=.*/)(?!/?$)", "^\\.(?!/?$)", "^\\./?$"],
                ["^.+\\.s?css$"],
            ],
        }],

        "no-use-before-define": ["error", {
            functions: false,
            classes: true,
            variables: true,
            allowNamedExports: false,
        }],

        "@typescript-eslint/member-ordering": ["error", {
            default: [
                "signature",
                "public-static-field",
                "protected-static-field",
                "private-static-field",
                "public-decorated-field",
                "protected-decorated-field",
                "private-decorated-field",
                "public-instance-field",
                "protected-instance-field",
                "private-instance-field",
                "public-abstract-field",
                "protected-abstract-field",
                "public-constructor",
                "protected-constructor",
                "private-constructor",
                "public-abstract-method",
                "protected-abstract-method",
                "public-static-method",
                "protected-static-method",
                "private-static-method",
                "public-decorated-method",
                "protected-decorated-method",
                "private-decorated-method",
                "public-instance-method",
                "protected-instance-method",
                "private-instance-method",
            ],
        }],

        "@typescript-eslint/no-confusing-non-null-assertion": "error",

        "@typescript-eslint/no-confusing-void-expression": ["error", {
            ignoreArrowShorthand: true,
        }],

        "@typescript-eslint/no-explicit-any": "warn",
        "@typescript-eslint/no-extra-non-null-assertion": "error",
        "no-unused-vars": "off",
        "unused-imports/no-unused-imports": "error",

        "unused-imports/no-unused-vars": ["warn", {
            vars: "all",
            varsIgnorePattern: "^_",
            args: "after-used",
            argsIgnorePattern: "^_",
        }],

        "import/order": "off",
    },
}, {
    files: ["**/*.html"],
    extends: fixupConfigRules(compat.extends("plugin:@angular-eslint/template/recommended")),
    rules: {},
}, {
    files: ["**/*.html"],
    ignores: ["**/*inline-template-*.component.html"],
    extends: fixupConfigRules(compat.extends("plugin:prettier/recommended")),

    rules: {
        "prettier/prettier": ["error", {
            parser: "angular",
        }],
    },
}]);
EOF

# Crear archivo .prettierrc
echo "📝 Creando configuración Prettier..."
cat > .prettierrc << 'EOF'
{
  "tabWidth": 4,
  "useTabs": false,
  "singleQuote": true,
  "semi": true,
  "bracketSpacing": true,
  "arrowParens": "avoid",
  "trailingComma": "es5",
  "bracketSameLine": true,
  "printWidth": 80
}
EOF

# Crear archivo .prettierignore
echo "📝 Creando archivo .prettierignore..."
cat > .prettierignore << 'EOF'
dist
node_modules
EOF

# Crear carpeta .vscode y settings.json
echo "📝 Configurando VSCode settings..."
mkdir -p .vscode
cat > .vscode/settings.json << 'EOF'
{
  "[html]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.codeActionsOnSave": {
      "source.fixAll.eslint": true
    },
    "editor.formatOnSave": false
  },
  "[typescript]": {
    "editor.defaultFormatter": "dbaeumer.vscode-eslint",
    "editor.codeActionsOnSave": {
      "source.fixAll.eslint": true
    },
    "editor.formatOnSave": false
  },
  "editor.suggest.snippetsPreventQuickSuggestions": false,
  "editor.inlineSuggest.enabled": true
}
EOF

# Agrega un .editorconfig
cat > .editorconfig << 'EOF'
# Editor configuration, see https://editorconfig.org
root = true

[*]
charset = utf-8
indent_style = space
indent_size = 4
insert_final_newline = true
trim_trailing_whitespace = true

# The indent size used in the `package.json` file cannot be changed
# https://github.com/npm/npm/pull/3180#issuecomment-16336516
[{*.yml,*.yaml,package.json}]
indent_style = space
indent_size = 2

[*.ts]
quote_type = single
ij_typescript_use_double_quotes = false

[*.md]
max_line_length = off
trim_trailing_whitespace = false
EOF


# Agregar script lint:fix al package.json
# Agregar script test:ci al package.json
echo "🔧 Agregando script 'lint:fix' en package.json..."
echo "🔧 Agregando script 'test:ci' en package.json..."
npx npm-add-script -k "lint:fix" -v "ng lint --fix"
npx npm-add-script -k "test:ci" -v "ng test --no-watch --no-progress --browsers=ChromeHeadless --code-coverage"

echo "📝 Creando carpetas de arquitectura limpia"
ng g c UI/main/
ng g config karma
sed -i '1i process.env.CHROME_BIN = require("puppeteer").executablePath();' karma.conf.js
mkdir src/app/config src/app/domain src/app/domain/models src/app/domain/use-cases src/app/infrastructure/ src/app/infrastructure/driven-adapter src/app/infrastructure/helpers src/app/UI/design-system src/app/UI/pages
rm src/app/app.component.html src/app/app.component.scss src/app/app.component.spec.ts src/app/app.component.ts
mv src/app/app.config.ts src/app/config/app.config.ts
mv src/app/app.routes.ts src/app/config/app.routes.ts


echo "🔧 Configurando archivo main.ts"
cat > src/main.ts << 'EOF'
import { bootstrapApplication } from '@angular/platform-browser';
import { MainComponent } from './app/UI/main/main.component';
import { appConfig } from './app/config/app.config';

bootstrapApplication(MainComponent, appConfig)
    .catch((err) => console.error(err));
EOF

cat > src/app/UI/main/main.component.html << 'EOF'
<router-outlet></router-outlet>
EOF

cat > src/app/UI/main/main.component.ts << 'EOF'
import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet],
  templateUrl: './main.component.html',
  styleUrl: './main.component.scss'
})
export class MainComponent {

}
EOF

# Crear carpeta .vscode y settings.json
echo "📝 Configurando Mapper abstracto."
mkdir src/app/infrastructure/helpers/mapper
cat > src/app/infrastructure/helpers/mapper/mapper.ts << 'EOF'
export abstract class Mapper<I, O> {
    abstract mapFromModel(param: I): O;
    abstract mapToModel(param: O): I;
}
EOF

# Mensaje final
echo "🎉 Proyecto Angular creado exitosamente con ESLint + Prettier + configuraciones de VSCode listas."
echo "📦 Extensiones de VSCode recomendadas: dbaeumer.vscode-eslint y esbenp.prettier-vscode"
echo "🚀 Puedes empezar con: cd $PROJECT_NAME && ng serve --open"

#!/bin/bash

set -e # Salir inmediatamente si un comando falla

# Leer opciones de proyecto
echo "🤖 Configurando opciones de proyecto"

# Carpeta de proyecto
echo "🔧 Carpeta de proyecto o puedes usar la actual usando (.)"
read PROJECT_FOLDER
PROJECT_FOLDER=${PROJECT_FOLDER:-.} # Usa '.' si el usuario no escribe nada

# Validar carpeta
if [ -z "$PROJECT_FOLDER" ]; then
  echo "❌ No se especificó una carpeta de proyecto. Saliendo..."
  exit 1
fi

# Nombre del proyecto
echo "🔧 Nombre del proyecto"
read PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
  echo "❌ No se especificó el nombre del proyecto. Saliendo..."
  exit 1
fi

# Package Manager
echo "🔧 Package Manager para el proyecto [npm, pnpm, yarn]"
read PACKAGE_MANAGER

# Validar package manager
if [[ "$PACKAGE_MANAGER" != "npm" && "$PACKAGE_MANAGER" != "pnpm" && "$PACKAGE_MANAGER" != "yarn" ]]; then
  echo "❌ Package manager inválido. Debe ser npm, pnpm o yarn. Saliendo..."
  exit 1
fi

# Crear carpeta si es necesario
if [ "$PROJECT_FOLDER" != "." ]; then
  echo "🔨 Creando directorio $PROJECT_FOLDER..."
  mkdir -p "$PROJECT_FOLDER" || { echo "❌ Error al crear la carpeta. Saliendo..."; exit 1; }
fi

# Cambiar a la carpeta de proyecto
cd "$PROJECT_FOLDER" || { echo "❌ No se pudo entrar a la carpeta $PROJECT_FOLDER. Saliendo..."; exit 1; }

if [ "$PACKAGE_MANAGER" = "npm" ]; then
  npm init -y
  npm pkg set name="$PROJECT_NAME"
elif [ "$PACKAGE_MANAGER" = "pnpm" ]; then
  pnpm init -y
  pnpm pkg set name="$PROJECT_NAME"
elif [ "$PACKAGE_MANAGER" = "yarn" ]; then
  yarn init -y
  yarn pkg set name "$PROJECT_NAME"
else
  echo "❌ Package manager no soportado: $PACKAGE_MANAGER"
  exit 1
fi

# Instalar Prettier, ESLint y plugins
echo "🔧 Instalando Prettier, ESLint y plugins adicionales..."

INSTALL_PACKAGES="ts-node typescript sinon jest @types/jest @types/sinon @types/node prettier prettier-eslint eslint-config-prettier eslint-plugin-prettier @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint-plugin-simple-import-sort eslint-plugin-unused-imports eslint-plugin-import eslint-import-resolver-typescript"

# Agregar script lint al package.json
# Agregar script lint:fix al package.json
# Auditando dependencias
echo "🔎 Auditando dependencias..."
echo "🔧 Agregando script 'lint' en package.json..."
echo "🔧 Agregando script 'lint:fix' en package.json..."
if [ "$PACKAGE_MANAGER" = "npm" ]; then
  npm install -D $INSTALL_PACKAGES
  npm audit fix --force || echo "⚠️  Algunas vulnerabilidades no se pudieron corregir automáticamente."
  npx npm-add-script -k "lint" -v "npx eslint ."
  npx npm-add-script -k "lint:fix" -v "npx eslint --fix --ext .ts"
elif [ "$PACKAGE_MANAGER" = "pnpm" ]; then
  pnpm add -D $INSTALL_PACKAGES
  pnpm audit || echo "⚠️  Algunas vulnerabilidades no se pudieron corregir automáticamente."
  pnpm dlx npm-add-script -k "lint" -v "pnpm exec eslint ."
  pnpm dlx npm-add-script -k "lint:fix" -v "pnpm exec eslint --fix --ext .ts"
elif [ "$PACKAGE_MANAGER" = "yarn" ]; then
  yarn add -D $INSTALL_PACKAGES
  yarn npm audit || echo "⚠️  Algunas vulnerabilidades no se pudieron corregir automáticamente."
  yarn dlx npm-add-script -k "lint" -v "yarn eslint ."
  yarn dlx npm-add-script -k "lint:fix" -v "yarn eslint --fix --ext .ts"
else
  echo "❌ Package manager no soportado: $PACKAGE_MANAGER"
  exit 1
fi


# Agregar tsconfig
echo "🚀 Agregando tsconfig.ts"
cat > tsconfig.json << 'EOF'
/* To learn more about this file see: https://angular.io/config/tsconfig. */
{
  "compileOnSave": false,
  "compilerOptions": {
    "outDir": "./dist/out-tsc",
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "esModuleInterop": true,
    "sourceMap": true,
    "declaration": false,
    "experimentalDecorators": true,
    "moduleResolution": "node",
    "importHelpers": true,
    "target": "ES2022",
    "module": "ES2022",
    "useDefineForClassFields": false,
    "lib": [
      "ES2022",
      "dom"
    ]
  }
}
EOF

cat > tsconfig.app.json << 'EOF'
/* To learn more about this file see: https://angular.io/config/tsconfig. */
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "outDir": "./out-tsc/app",
    "types": []
  },
  "files": [
    "src/main.ts"
  ],
  "include": [
    "src/**/*.d.ts"
  ]
}
EOF

cat > tsconfig.spec.json << 'EOF'
/* To learn more about this file see: https://angular.io/config/tsconfig. */
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "outDir": "./out-tsc/spec",
  },
  "include": [
    "src/**/*.spec.ts",
    "src/**/*.d.ts"
  ]
}
EOF

# Agrega un .editorconfig
cat > .editorconfig << 'EOF'
# Editor configuration, see https://editorconfig.org
root = true

[*]
charset = utf-8
indent_style = tab
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

echo "📝 Creando archivos y carpetas de clean architecture"
mkdir src src/domain src/domain/models src/domain/ports src/domain/ports/gateways src/domain/ports/utils src/domain/commands src/domain/queries src/driven-adapters src/driven-adapters/tests src/entry-points src/entry-points/tests src/libraries
cat > src/main.ts << 'EOF'
console.log("Hello World")
EOF

# Comando para crear proyecto
echo "🚀 Agregando Eslint y Prettier"

# Crear archivo .eslintrc.json
echo "📝 Creando configuración ESLint..."
cat > .eslintrc.json << 'EOF'
{
  "root": true,
  "ignorePatterns": ["projects/**/*"],
  "overrides": [
    {
      "files": ["*.ts"],
      "parserOptions": {
        "project": ["tsconfig.json"],
        "createDefaultProgram": true
      },
      "settings": {
        "import/resolver": {
          "typescript": {}
        }
      },
      "plugins": [
        "@typescript-eslint",
        "simple-import-sort",
        "import",
        "unused-imports"
      ],
      "extends": [
        "plugin:@angular-eslint/recommended",
        "plugin:@angular-eslint/template/process-inline-templates",
        "plugin:prettier/recommended",
        "plugin:@typescript-eslint/recommended",
        "plugin:import/recommended",
        "plugin:import/typescript"
      ],
      "rules": {
        "@angular-eslint/component-class-suffix": [
          "error",
          {
            "suffixes": ["Page", "Component"]
          }
        ],
        "@angular-eslint/component-selector": [
          "error",
          {
            "type": "element",
            "prefix": "app",
            "style": "kebab-case"
          }
        ],
        "@angular-eslint/directive-selector": [
          "error",
          {
            "type": "attribute",
            "prefix": "app",
            "style": "camelCase"
          }
        ],
        "@angular-eslint/use-lifecycle-interface": ["error"],
        "@typescript-eslint/naming-convention": 0,
        "simple-import-sort/imports": [
          "error",
          {
            "groups": [
              // Side effect imports: `import "./setup";`
              ["^\\\u0000"],
              // Packages: `import fs from "fs";`
              ["^@?\\\w"],
              // Parent imports. Put `..` last.
              ["^\\\.\\\.(?!/?$)", "^\\\.\\\./?$"],
              // Other relative imports. Put same-folder imports and `.` last.
              ["^\\\./(?=.*/)(?!/?$)", "^\\\.(?!/?$)", "^\\\./?$"],
              // Style imports.
              ["^.+\\\.s?css$"]
            ]
          }
        ],
        "no-use-before-define": [
          "error",
          {
            "functions": false,
            "classes": true,
            "variables": true,
            "allowNamedExports": false
          }
        ],
        "@typescript-eslint/member-ordering": [
          "error",
          {
            "default": [
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
              "private-instance-method"
            ]
          }
        ],
        "@typescript-eslint/no-confusing-non-null-assertion": "error",
        "@typescript-eslint/no-confusing-void-expression": [
          "error",
          { "ignoreArrowShorthand": true }
        ],
        "@typescript-eslint/no-explicit-any": "warn",
        "@typescript-eslint/no-extra-non-null-assertion": "error",
        "no-unused-vars": "off", // or "@typescript-eslint/no-unused-vars": "off",
        "unused-imports/no-unused-imports": "error",
        "unused-imports/no-unused-vars": [
          "warn",
          {
            "vars": "all",
            "varsIgnorePattern": "^_",
            "args": "after-used",
            "argsIgnorePattern": "^_"
          }
        ],
        "import/order": "off"
      }
    },
    {
      "files": ["*.html"],
      "extends": ["plugin:@angular-eslint/template/recommended"],
      "rules": {}
    },
    {
      "files": ["*.html"],
      "excludedFiles": ["*inline-template-*.component.html"],
      "extends": ["plugin:prettier/recommended"],
      "rules": {
        "prettier/prettier": ["error", { "parser": "angular" }]
      }
    }
  ]
}
EOF

# Crear archivo .prettierrc
echo "📝 Creando configuración Prettier..."
cat > .prettierrc << 'EOF'
{
  "tabWidth": 4,
  "useTabs": true,
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

# Mensaje final
echo "✅ Proyecto configurado en '$PROJECT_FOLDER' con nombre '$PROJECT_NAME' usando '$PACKAGE_MANAGER'"
echo "🎉 Agregado exitosamente ESLint + Prettier + configuraciones de VSCode listas."
echo "📦 Extensiones de VSCode recomendadas: dbaeumer.vscode-eslint y esbenp.prettier-vscode"
echo "🚀 Puedes empezar a desarrollar"

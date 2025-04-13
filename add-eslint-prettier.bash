#!/bin/bash

# Comando para crear proyecto
echo "🚀 Agregando Eslint y Prettier"

# Instalar Prettier y dependencias relacionadas
echo "🔧 Instalando Eslint, Prettier y dependencias de ESLint/Prettier..."
npm install prettier eslint prettier-eslint eslint-config-prettier eslint-plugin-prettier -D

# Plugins necesarios
npm install @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint-plugin-simple-import-sort eslint-plugin-unused-imports eslint-plugin-import eslint-import-resolver-typescript -D

# Auditando dependencias
npm audit fix --force

# Crear archivo .eslintrc.json
echo "📝 Creando configuración ESLint..."
cat > .eslintrc.json <<EOL
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
        "plugin:prettier/recommended",
        "plugin:@typescript-eslint/recommended",
        "plugin:import/recommended",
        "plugin:import/typescript"
      ],
      "rules": {
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
    }
  ]
}

EOL

# Crear archivo .prettierrc
echo "📝 Creando configuración Prettier..."
cat > .prettierrc <<EOL
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

EOL

# Crear archivo .prettierignore
echo "📝 Creando archivo .prettierignore..."
cat > .prettierignore <<EOL
dist
node_modules
EOL

# Crear carpeta .vscode y settings.json
echo "📝 Configurando VSCode settings..."
mkdir -p .vscode
cat > .vscode/settings.json <<EOL
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
EOL

# Agregar script lint al package.json
echo "🔧 Agregando script 'lint' en package.json..."
npx npm-add-script -k "lint" -v "npx eslint ."

# Agregar script lint:fix al package.json
echo "🔧 Agregando script 'lint:fix' en package.json..."
npx npm-add-script -k "lint:fix" -v "npx eslint --fix --ext .ts"

# Mensaje final
echo "🎉 Agregado exitosamente ESLint + Prettier + configuraciones de VSCode listas."
echo "📦 Extensiones de VSCode recomendadas: dbaeumer.vscode-eslint y esbenp.prettier-vscode"
echo "🚀 Puedes empezar a desarrollar"

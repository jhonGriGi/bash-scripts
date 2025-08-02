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
npm install -D eslint @antfu/eslint-config

# Auditando dependencias
npm audit fix --force || echo "⚠️  Algunas vulnerabilidades no se pudieron corregir automáticamente."

# Eliminar configuración antigua de ESLint si existe
if [ -f "eslint.config.js" ]; then
  rm eslint.config.js
fi

# Crear archivo .eslintrc.json
echo "📝 Creando configuración ESLint..."
cat > eslint.config.mjs << 'EOF'
// eslint.config.mjs
import antfu from '@antfu/eslint-config';

export default antfu({
    typescript: true,
    formatters: true,
    stylistic: {
        semi: true,
        indent: 4,
        quotes: 'single',
    },
    rules: {
        'unicorn/filename-case': ['error', {
            case: 'kebabCase',
            ignore: ['README.md'],
        }],
    },
});
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

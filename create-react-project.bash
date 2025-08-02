#!/bin/bash

set -e # Salir inmediatamente si un comando falla

# Leer opciones de proyecto
echo "🤖 Configurando opciones de proyecto"

# Carpeta de proyecto
echo "🔧 Carpeta de proyecto"
read PROJECT_FOLDER

# Validar carpeta
if [ -z "$PROJECT_FOLDER" ]; then
  echo "❌ No se especificó una carpeta de proyecto. Saliendo..."
  exit 1
fi

npm create vite@latest $PROJECT_FOLDER -- --template react-swc-ts
cd $PROJECT_FOLDER
npm install

# Instalar Prettier, ESLint y plugins
echo "🔧 Instalando Prettier, ESLint y plugins adicionales..."

INSTALL_PACKAGES="ts-node jest ts-jest @jest/globals @types/jest @types/node eslint @antfu/eslint-config"

npm install -D $INSTALL_PACKAGES
npm audit fix --force || echo "⚠️  Algunas vulnerabilidades no se pudieron corregir automáticamente."
npx npm-add-script -k "lint:fix" -v "npx eslint --fix ."
npx npm-add-script -k "unit" -v "npx run jest"
npx npm-add-script -k "unit:coverage" -v "npx run jest --coverage"

echo "📝 Creando archivos y carpetas de clean architecture"
mkdir src/modules src/modules/core src/modules/core/presentation src/modules/core/domain src/modules/core/domain/models src/modules/core/domain/models/either
mv src/App.tsx src/modules/core/presentation && mv src/App.css src/modules/core/presentation
rm eslint.config.js

cat > src/main.tsx << 'EOF'
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './modules/core/presentation/App.tsx'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)

EOF

# Agrega un .editorconfig
cat > .editorconfig << 'EOF'
# Editor configuration, see https://editorconfig.org
root = true

[*]
charset = utf-8
itabndent_style = space
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

cat > src/modules/core/domain/models/either/value-types.ts << 'EOF'
import { Either } from './either';

export type Ok<T> = Either<T, never>;
export type ErrorType<E> = Either<never, E>;
EOF

cat > src/modules/core/domain/models/either/either.ts << 'EOF'
import { ErrorType, Ok } from './value-types';

interface FoldExpression<R, E, T> {
	fnError: (error: E) => R;
	fnOk: (value: T) => R;
}

export class Either<T, E> {
	private constructor(
		private readonly value?: T,
		private readonly error?: E
	) {}

	static Ok<T>(value: T): Ok<T> {
		return new Either(value);
	}

	static Error<E>(error: E): ErrorType<E> {
		return new Either(null as never, error);
	}

	public isOk(): this is Ok<T> {
		return this.value !== undefined;
	}

	public isError(): this is ErrorType<E> {
		return this.error !== undefined;
	}

	public getValue(): T {
		if (!this.isOk()) {
			throw new Error('Cannot access value in a non-Ok instance');
		}

		return this.value!;
	}

	public getError(): E {
		if (!this.isError()) {
			throw new Error('Cannot access error in a non-Error instance');
		}

		return this.error!;
	}

	public fold<R>(expressions: FoldExpression<R, E, T>): R {
		return this.isError()
			? expressions.fnError(this.error!)
			: expressions.fnOk(this.value!);
	}
}
EOF

# Comando para crear proyecto
echo "🚀 Agregando Eslint y Prettier"

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

echo "📝 Configurando archivos"
cat > .gitignore << 'EOF'

# Created by https://www.toptal.com/developers/gitignore/api/osx,node,linux,windows,sam
# Edit at https://www.toptal.com/developers/gitignore?templates=osx,node,linux,windows,sam

### Linux ###
*~

# temporary files which can be created if a process still has a handle open of a deleted file
.fuse_hidden*

# KDE directory preferences
.directory

# Linux trash folder which might appear on any partition or disk
.Trash-*

# .nfs files are created when an open file is removed but is still being accessed
.nfs*

### Node ###
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# Diagnostic reports (https://nodejs.org/api/report.html)
report.[0-9]*.[0-9]*.[0-9]*.[0-9]*.json

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Directory for instrumented libs generated by jscoverage/JSCover
lib-cov

# Coverage directory used by tools like istanbul
coverage
*.lcov

# nyc test coverage
.nyc_output

# Grunt intermediate storage (https://gruntjs.com/creating-plugins#storing-task-files)
.grunt

# Bower dependency directory (https://bower.io/)
bower_components

# node-waf configuration
.lock-wscript

# Compiled binary addons (https://nodejs.org/api/addons.html)
build/Release

# Dependency directories
node_modules/
jspm_packages/

# TypeScript v1 declaration files
typings/

# TypeScript cache
*.tsbuildinfo

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Optional stylelint cache
.stylelintcache

# Microbundle cache
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env
.env.test
.env*.local

# parcel-bundler cache (https://parceljs.org/)
.cache
.parcel-cache

# Next.js build output
.next

# Nuxt.js build / generate output
.nuxt
dist

# Storybook build outputs
.out
.storybook-out
storybook-static

# rollup.js default build output
dist/

# Gatsby files
.cache/
# Comment in the public line in if your project uses Gatsby and not Next.js
# https://nextjs.org/blog/next-9-1#public-directory-support
# public

# vuepress build output
.vuepress/dist

# Serverless directories
.serverless/

# FuseBox cache
.fusebox/

# DynamoDB Local files
.dynamodb/

# TernJS port file
.tern-port

# Stores VSCode versions used for testing VSCode extensions
.vscode-test

# Temporary folders
tmp/
temp/

### OSX ###
# General
.DS_Store
.AppleDouble
.LSOverride

# Icon must end with two \r
Icon


# Thumbnails
._*

# Files that might appear in the root of a volume
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent

# Directories potentially created on remote AFP share
.AppleDB
.AppleDesktop
Network Trash Folder
Temporary Items
.apdisk

### SAM ###
# Ignore build directories for the AWS Serverless Application Model (SAM)
# Info: https://aws.amazon.com/serverless/sam/
# Docs: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-reference.html

**/.aws-sam

### Windows ###
# Windows thumbnail cache files
Thumbs.db
Thumbs.db:encryptable
ehthumbs.db
ehthumbs_vista.db

# Dump file
*.stackdump

# Folder config file
[Dd]esktop.ini

# Recycle Bin used on file shares
$RECYCLE.BIN/

# Windows Installer files
*.cab
*.msi
*.msix
*.msm
*.msp

# Windows shortcuts
*.lnk

# Jetbrains products
.idea

# Envs
env.json

# End of https://www.toptal.com/developers/gitignore/api/osx,node,linux,windows,sam
EOF

cat > .npmignore << 'EOF'
tests/*
EOF

cat > jest.config.ts << 'EOF'
/*
 * For a detailed explanation regarding each configuration property and type check, visit:
 * https://jestjs.io/docs/configuration
 */

export default {
	preset: "ts-jest",
	transform: {
		"^.+\\.ts?$": "ts-jest",
	},
	clearMocks: true,
	collectCoverage: true,
	coverageDirectory: "coverage",
	coverageProvider: "v8",
	collectCoverageFrom: ["app/**/*.{js,jsx,ts,tsx}", "!<rootDir>/node_modules/"],
	testMatch: ["**/tests/unit/**/*.test.ts"],
	modulePathIgnorePatterns: [
		"src/domain/Builders/",
		"src/domain/exceptions/",
		"src/domain/model/",
		"src/domain/ports/",
		"src/libraries",
		"src/entrypoints/schemas",
	],
	moduleNameMapper: {
		"^@domain/(.*)$": "<rootDir>/src/domain/$1",
		"^@adapters/(.*)$": "<rootDir>/src/adapters/$1",
		"^@lambda/(.*)$": "<rootDir>/src/entrypoints/$1",
		"^@schemas/(.*)$": "<rootDir>/src/entrypoints/$1",
		"^@libraries/(.*)$": "<rootDir>/src/libraries/$1",
		"^@ports/(.*)$": "<rootDir>/src/domain/ports/$1",
		"^@model/(.*)$": "<rootDir>/src/domain/model/$1",
	},
};
EOF

# Mensaje final
echo "✅ Proyecto configurado en '$PROJECT_FOLDER'"
echo "🎉 Agregado exitosamente ESLint + Prettier + configuraciones de VSCode listas."
echo "📦 Extensiones de VSCode recomendadas: dbaeumer.vscode-eslint y esbenp.prettier-vscode"
echo "🚀 Puedes empezar a desarrollar"

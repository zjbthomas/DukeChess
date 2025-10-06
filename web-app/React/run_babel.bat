call npx babel ./src --presets react-app/prod --out-dir ./babel_out/ --extensions ".js,.jsx" 

call npx terser -c -m -o ../dukechess/js-frontend/dukechess.js -- ./babel_out/dukechess.js
call npx terser -c -m -o ../chess/js-frontend/chess.js -- ./babel_out/chess.js

call npx esbuild ./babel_out/login.js ^
  --bundle ^
  --format=iife ^
  --global-name=LoginBundle ^
  --external:react ^
  --external:react-dom ^
  --minify ^
  --outfile=../global/login.js
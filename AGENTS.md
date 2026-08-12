il progetto verte a creare un xmake.lua minimale per compilare php

la compilazione sarà statica e multithread
ogni codegen necessaria dovrà essere eseguita dentro un acallback fornita dalla rule cb
possibilmente una cb per target
se la cb codegen del target dipende da comandi esterni (minilua, perl, etc) bisogna preparare i binari nel task prepare (es per perl) che verrà eseguito manualmente prima del build generale, oppure se i binari richiesti sono generati da alri target (es minilua) andranno chiamati programmaticamente tali target nella cb con le funzioni builtin di xmake

per ogni target battezziamo un singolo add_files, sul sorgente più "sensato" per fungere da cb di preparazione codegen e file di conf in c con define e parametri (es per php config.w32.h) per l'intero target, no più codegen cb per singolo target

ogni lib dipendenza avrà un suo target, non consideriamo lib separate le estensioni php, quindi non usiamo target separati per le estensioni

gli add dei source dovranno essere il più ampie possibili, idealmente es: add(in/deps/openssl/**/*.c) add(in/php-src/**/*.c), ottimizziamo la compilazione usando unity build (unità di compilazione) per gruppi di file più ampi possibili al netto dei conflitti di simboli

per ora ci concentriamo solo su build windows no multiplat
per ogni define o altro che richiede parametri di piattaform es dimensione long etc usiamo le funzioni builtin di xmake


documentiamo dentro al readme in una tabella tutti i target e per ogni target i path di origine e destinazione relativi di ogni codegen richiesto il tool e i parametri usati per l'azione e cose particolari es utilizzo si compilazioni asm, dipendenze intrecciate

portiamo il build finale di tutto gradualmente a conclusione, partendo ovviamente dalle dipendenze, un target alla volta

usiamo sempre path relativi e placeholder builtin xmake dove possibile per placeholder tipo x64/win etc platform depednent

commit prima di ogni test xmake

i comadi di build saranno:
xmake prepare (indepotente download e strazioni etc)
xmake


i codegen identificati finora sono:
os.run([[%s\bison -Wall --no-lines --output=Zend/zend_ini_parser.c -v -d Zend/zend_ini_parser.y]],bin_dir)
    os.run([[%s\bison -Wall --no-lines --output=Zend/zend_language_parser.c -v -d Zend/zend_language_parser.y]],bin_dir)
    os.run([[%s\bison -Wall --no-lines --output=sapi/phpdbg/phpdbg_parser.c -v -d sapi/phpdbg/phpdbg_parser.y]],bin_dir)
    os.run([[%s\bison -Wall --no-lines --defines ext/json/json_parser.y -o ext/json/json_parser.tab.c]],bin_dir)
    os.run([[%s\re2c --no-generation-date --case-inverted -cbdFt Zend/zend_ini_scanner_defs.h -oZend/zend_ini_scanner.c Zend/zend_ini_scanner.l]],bin_dir)
    os.run([[%s\re2c --no-generation-date --case-inverted -cbdFt Zend/zend_language_scanner_defs.h -oZend/zend_language_scanner.c Zend/zend_language_scanner.l]],bin_dir)
    os.run([[%s\re2c --no-generation-date -cbdFo sapi/phpdbg/phpdbg_lexer.c sapi/phpdbg/phpdbg_lexer.l]],bin_dir)
    os.run([[%s\re2c --no-generation-date -t ext/json/php_json_scanner_defs.h -bci -o ext/json/json_scanner.c ext/json/json_scanner.re]],bin_dir)
    os.run([[%s\re2c --no-generation-date -b -o ext/standard/var_unserializer.c ext/standard/var_unserializer.re]],bin_dir)
    os.run([[%s\re2c --no-generation-date -b -o ext/standard/url_scanner_ex.c ext/standard/url_scanner_ex.re]],bin_dir)
    os.run([[%s\re2c --no-generation-date -b -o ext/phar/phar_path_check.c ext/phar/phar_path_check.re]],bin_dir)
    os.runv(mc, {"-h", "win32", "-r", build_dir, "-x", build_dir, "win32/build/wsyslog.mc"})

    os.run([["%s\minilua.exe" ext/opcache/jit/ir/dynasm/dynasm.lua -L -D WIN=1 -o ext\opcache\jit\ir\ir_emit_x86.h ext/opcache/jit/ir/ir_x86.dasc]], build_dir)

    -- os.run([[$(builddir)\gen_ir_fold_hash < ext\opcache\jit\ir\ir_fold.h > ext\opcache\jit\ir\ir_fold_hash.h]])
    os.run([["%s\gen_ir_fold_hash.exe"]], build_dir, {
      stdin=[[ext\opcache\jit\ir\ir_fold.h]],
      stdout=[[ext\opcache\jit\ir\ir_fold_hash.h]]
    })

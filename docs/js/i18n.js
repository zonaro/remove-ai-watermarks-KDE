/* ==========================================================================
   Remove AI Watermarks — Context Menus · i18n
   Traduções (pt / en / es) + detecção de idioma + aplicação no DOM
   ========================================================================== */

(function () {
  'use strict';

  var LANGS = ['pt', 'en', 'es'];
  var DEFAULT_LANG = 'pt';
  var STORAGE_KEY = 'raiw-lang';

  var TRANSLATIONS = {
    /* ------------------------------------------------------------------ */
    /* Português                                                          */
    /* ------------------------------------------------------------------ */
    pt: {
      meta: {
        title: 'Remove AI Watermarks — Context Menus',
        description: 'Menus de contexto para remover marcas d\'água de IA diretamente do seu gerenciador de arquivos. Suporta Dolphin, Nautilus, Thunar, Nemo, Caja e PCManFM.'
      },
      nav: {
        features: 'Recursos',
        managers: 'Gerenciadores',
        install: 'Instalação',
        usage: 'Uso',
        uninstall: 'Desinstalar',
        lang: 'Idioma',
        menu: 'Menu'
      },
      hero: {
        badge: 'Multi-desktop · Open Source',
        title: 'Remova marcas d\'água de IA<br><span class="gradient-text">com um clique direito</span>',
        subtitle: 'Integra o <code>remove-ai-watermarks</code> como menu de contexto no seu gerenciador de arquivos. Identifique, limpe e processe em lote imagens com marcas de IA — direto do Dolphin, Nautilus, Thunar, Nemo, Caja ou PCManFM.',
        install: 'Instalar agora',
        viewGithub: 'Ver no GitHub',
        statManagers: 'gerenciadores',
        statModes: 'modos de limpeza',
        statLangs: 'idiomas',
        statDeps: 'dependências'
      },
      features: {
        title: 'Recursos',
        subtitle: 'Tudo o que você precisa para limpar imagens de IA, sem sair do seu gerenciador de arquivos.',
        identify: {
          title: 'Identificar',
          desc: 'Analisa a imagem e gera um relatório completo em <code>&lt;nome&gt;_ai_analysis.txt</code>, aberto automaticamente no seu editor.'
        },
        visible: {
          title: 'Remover marca visível',
          desc: 'Detecta e remove marcas visíveis conhecidas (Gemini, Doubao, Jimeng, Qwen, Kling e mais).'
        },
        metadata: {
          title: 'Remover metadados',
          desc: 'Limpa metadados de IA (C2PA, EXIF, parâmetros de geração) que identificam a imagem como gerada.'
        },
        all: {
          title: 'Remover tudo',
          desc: 'Pipeline completo: marca visível + metadados + marca invisível, em uma única operação.'
        },
        batch: {
          title: 'Processar em lote',
          desc: 'Selecione uma pasta ou várias imagens e limpe todas de uma vez. Pula automaticamente arquivos já limpos.'
        },
        multidesktop: {
          title: 'Multi-desktop',
          desc: 'Funciona em KDE, GNOME, XFCE, Cinnamon, MATE, LXDE e LXQt. O instalador detecta tudo sozinho.'
        }
      },
      managers: {
        title: 'Gerenciadores suportados',
        subtitle: 'O instalador detecta seu ambiente e instala em todos os gerenciadores compatíveis encontrados.'
      },
      install: {
        title: 'Instalação',
        subtitle: 'Primeiro instale o CLI <code>remove-ai-watermarks</code>, depois rode o instalador.',
        step1: {
          title: 'Instale o CLI',
          desc: 'O projeto é um front-end para o <a href="https://github.com/wiltodelta/remove-ai-watermarks" target="_blank" rel="noopener">remove-ai-watermarks</a> — ele precisa estar no seu <code>PATH</code>.'
        },
        step2: {
          title: 'Instale os menus de contexto',
          desc: 'O instalador detecta seu ambiente e instala em todos os gerenciadores compatíveis.',
          note: 'Para instalar em <strong>todos</strong> os gerenciadores suportados, mesmo os não detectados:'
        },
        step3: {
          title: 'Reinicie o gerenciador',
          desc: 'Para o menu aparecer, reinicie o gerenciador de arquivos uma vez.'
        }
      },
      usage: {
        title: 'Como usar',
        subtitle: 'Clique com o botão direito em uma imagem, pasta ou seleção múltipla.',
        single: {
          title: '🖼️ Imagem única',
          identify: 'Identificar',
          visible: 'Remover marca visível',
          metadata: 'Remover metadados de IA',
          all: 'Remover tudo'
        },
        multi: {
          title: '📚 Múltiplas imagens',
          batch: 'Processar em lote (visible)'
        },
        folder: {
          title: '📁 Pasta',
          batch: 'Processar em lote (visible)'
        },
        note: '💡 Os arquivos limpos são salvos <strong>ao lado do original</strong> como <code>&lt;nome&gt;_ai_cleaned.&lt;ext&gt;</code>. O modo <strong>Identificar</strong> gera <code>&lt;nome&gt;_ai_analysis.txt</code> e abre no editor padrão.'
      },
      uninstall: {
        title: 'Desinstalação',
        subtitle: 'Remove todos os menus de contexto e o script auxiliar — sem tocar nas suas imagens limpas.',
        note: 'A desinstalação <strong>não</strong> remove o CLI <code>remove-ai-watermarks</code> nem os arquivos <code>_ai_cleaned</code> que você gerou.'
      },
      footer: {
        desc: 'Um front-end open source para o <a href="https://github.com/wiltodelta/remove-ai-watermarks" target="_blank" rel="noopener">remove-ai-watermarks</a>.',
        made: 'Feito com 💜 para a comunidade Linux · <span id="year"></span>'
      },
      copy: {
        copy: 'Copiar',
        done: 'Copiado ✓',
        error: 'Erro'
      }
    },

    /* ------------------------------------------------------------------ */
    /* English                                                            */
    /* ------------------------------------------------------------------ */
    en: {
      meta: {
        title: 'Remove AI Watermarks — Context Menus',
        description: 'Context menus to remove AI watermarks right from your file manager. Supports Dolphin, Nautilus, Thunar, Nemo, Caja and PCManFM.'
      },
      nav: {
        features: 'Features',
        managers: 'File managers',
        install: 'Install',
        usage: 'Usage',
        uninstall: 'Uninstall',
        lang: 'Language',
        menu: 'Menu'
      },
      hero: {
        badge: 'Multi-desktop · Open Source',
        title: 'Remove AI watermarks<br><span class="gradient-text">with a right click</span>',
        subtitle: 'Integrates <code>remove-ai-watermarks</code> as a context menu in your file manager. Identify, clean and batch-process images with AI marks — right from Dolphin, Nautilus, Thunar, Nemo, Caja or PCManFM.',
        install: 'Install now',
        viewGithub: 'View on GitHub',
        statManagers: 'file managers',
        statModes: 'cleaning modes',
        statLangs: 'languages',
        statDeps: 'dependencies'
      },
      features: {
        title: 'Features',
        subtitle: 'Everything you need to clean AI images, without leaving your file manager.',
        identify: {
          title: 'Identify',
          desc: 'Analyzes the image and generates a full report in <code>&lt;name&gt;_ai_analysis.txt</code>, opened automatically in your editor.'
        },
        visible: {
          title: 'Remove visible mark',
          desc: 'Detects and removes known visible marks (Gemini, Doubao, Jimeng, Qwen, Kling and more).'
        },
        metadata: {
          title: 'Remove metadata',
          desc: 'Cleans AI metadata (C2PA, EXIF, generation parameters) that identify the image as generated.'
        },
        all: {
          title: 'Remove everything',
          desc: 'Full pipeline: visible mark + metadata + invisible mark, in a single operation.'
        },
        batch: {
          title: 'Batch processing',
          desc: 'Select a folder or multiple images and clean them all at once. Automatically skips already-cleaned files.'
        },
        multidesktop: {
          title: 'Multi-desktop',
          desc: 'Works on KDE, GNOME, XFCE, Cinnamon, MATE, LXDE and LXQt. The installer detects everything on its own.'
        }
      },
      managers: {
        title: 'Supported file managers',
        subtitle: 'The installer detects your environment and installs into every compatible file manager found.'
      },
      install: {
        title: 'Installation',
        subtitle: 'First install the <code>remove-ai-watermarks</code> CLI, then run the installer.',
        step1: {
          title: 'Install the CLI',
          desc: 'This project is a front-end for <a href="https://github.com/wiltodelta/remove-ai-watermarks" target="_blank" rel="noopener">remove-ai-watermarks</a> — it must be on your <code>PATH</code>.'
        },
        step2: {
          title: 'Install the context menus',
          desc: 'The installer detects your environment and installs into every compatible file manager.',
          note: 'To install into <strong>all</strong> supported file managers, even undetected ones:'
        },
        step3: {
          title: 'Restart the file manager',
          desc: 'For the menu to appear, restart your file manager once.'
        }
      },
      usage: {
        title: 'How to use',
        subtitle: 'Right-click an image, folder or multiple selection.',
        single: {
          title: '🖼️ Single image',
          identify: 'Identify',
          visible: 'Remove visible mark',
          metadata: 'Remove AI metadata',
          all: 'Remove everything'
        },
        multi: {
          title: '📚 Multiple images',
          batch: 'Batch process (visible)'
        },
        folder: {
          title: '📁 Folder',
          batch: 'Batch process (visible)'
        },
        note: '💡 Cleaned files are saved <strong>next to the original</strong> as <code>&lt;name&gt;_ai_cleaned.&lt;ext&gt;</code>. The <strong>Identify</strong> mode generates <code>&lt;name&gt;_ai_analysis.txt</code> and opens it in the default editor.'
      },
      uninstall: {
        title: 'Uninstallation',
        subtitle: 'Removes all context menus and the helper script — without touching your cleaned images.',
        note: 'Uninstalling does <strong>not</strong> remove the <code>remove-ai-watermarks</code> CLI or the <code>_ai_cleaned</code> files you generated.'
      },
      footer: {
        desc: 'An open source front-end for <a href="https://github.com/wiltodelta/remove-ai-watermarks" target="_blank" rel="noopener">remove-ai-watermarks</a>.',
        made: 'Made with 💜 for the Linux community · <span id="year"></span>'
      },
      copy: {
        copy: 'Copy',
        done: 'Copied ✓',
        error: 'Error'
      }
    },

    /* ------------------------------------------------------------------ */
    /* Español                                                            */
    /* ------------------------------------------------------------------ */
    es: {
      meta: {
        title: 'Remove AI Watermarks — Context Menus',
        description: 'Menús de contexto para eliminar marcas de agua de IA directamente desde tu gestor de archivos. Compatible con Dolphin, Nautilus, Thunar, Nemo, Caja y PCManFM.'
      },
      nav: {
        features: 'Características',
        managers: 'Gestores',
        install: 'Instalación',
        usage: 'Uso',
        uninstall: 'Desinstalar',
        lang: 'Idioma',
        menu: 'Menú'
      },
      hero: {
        badge: 'Multi-desktop · Open Source',
        title: 'Elimina marcas de agua de IA<br><span class="gradient-text">con un clic derecho</span>',
        subtitle: 'Integra <code>remove-ai-watermarks</code> como menú de contexto en tu gestor de archivos. Identifica, limpia y procesa en lote imágenes con marcas de IA — directamente desde Dolphin, Nautilus, Thunar, Nemo, Caja o PCManFM.',
        install: 'Instalar ahora',
        viewGithub: 'Ver en GitHub',
        statManagers: 'gestores',
        statModes: 'modos de limpieza',
        statLangs: 'idiomas',
        statDeps: 'dependencias'
      },
      features: {
        title: 'Características',
        subtitle: 'Todo lo que necesitas para limpiar imágenes de IA, sin salir de tu gestor de archivos.',
        identify: {
          title: 'Identificar',
          desc: 'Analiza la imagen y genera un informe completo en <code>&lt;nombre&gt;_ai_analysis.txt</code>, abierto automáticamente en tu editor.'
        },
        visible: {
          title: 'Eliminar marca visible',
          desc: 'Detecta y elimina marcas visibles conocidas (Gemini, Doubao, Jimeng, Qwen, Kling y más).'
        },
        metadata: {
          title: 'Eliminar metadatos',
          desc: 'Limpia metadatos de IA (C2PA, EXIF, parámetros de generación) que identifican la imagen como generada.'
        },
        all: {
          title: 'Eliminar todo',
          desc: 'Pipeline completo: marca visible + metadatos + marca invisible, en una sola operación.'
        },
        batch: {
          title: 'Procesar en lote',
          desc: 'Selecciona una carpeta o varias imágenes y límpialas todas a la vez. Omite automáticamente los archivos ya limpios.'
        },
        multidesktop: {
          title: 'Multi-desktop',
          desc: 'Funciona en KDE, GNOME, XFCE, Cinnamon, MATE, LXDE y LXQt. El instalador lo detecta todo por sí solo.'
        }
      },
      managers: {
        title: 'Gestores compatibles',
        subtitle: 'El instalador detecta tu entorno e instala en todos los gestores compatibles encontrados.'
      },
      install: {
        title: 'Instalación',
        subtitle: 'Primero instala el CLI <code>remove-ai-watermarks</code> y luego ejecuta el instalador.',
        step1: {
          title: 'Instala el CLI',
          desc: 'Este proyecto es un front-end para <a href="https://github.com/wiltodelta/remove-ai-watermarks" target="_blank" rel="noopener">remove-ai-watermarks</a> — debe estar en tu <code>PATH</code>.'
        },
        step2: {
          title: 'Instala los menús de contexto',
          desc: 'El instalador detecta tu entorno e instala en todos los gestores compatibles.',
          note: 'Para instalar en <strong>todos</strong> los gestores compatibles, incluso los no detectados:'
        },
        step3: {
          title: 'Reinicia el gestor',
          desc: 'Para que aparezca el menú, reinicia tu gestor de archivos una vez.'
        }
      },
      usage: {
        title: 'Cómo usar',
        subtitle: 'Haz clic derecho en una imagen, carpeta o selección múltiple.',
        single: {
          title: '🖼️ Imagen única',
          identify: 'Identificar',
          visible: 'Eliminar marca visible',
          metadata: 'Eliminar metadatos de IA',
          all: 'Eliminar todo'
        },
        multi: {
          title: '📚 Varias imágenes',
          batch: 'Procesar en lote (visible)'
        },
        folder: {
          title: '📁 Carpeta',
          batch: 'Procesar en lote (visible)'
        },
        note: '💡 Los archivos limpios se guardan <strong>junto al original</strong> como <code>&lt;nombre&gt;_ai_cleaned.&lt;ext&gt;</code>. El modo <strong>Identificar</strong> genera <code>&lt;nombre&gt;_ai_analysis.txt</code> y lo abre en el editor predeterminado.'
      },
      uninstall: {
        title: 'Desinstalación',
        subtitle: 'Elimina todos los menús de contexto y el script auxiliar — sin tocar tus imágenes limpias.',
        note: 'La desinstalación <strong>no</strong> elimina el CLI <code>remove-ai-watermarks</code> ni los archivos <code>_ai_cleaned</code> que generaste.'
      },
      footer: {
        desc: 'Un front-end de código abierto para <a href="https://github.com/wiltodelta/remove-ai-watermarks" target="_blank" rel="noopener">remove-ai-watermarks</a>.',
        made: 'Hecho con 💜 para la comunidad Linux · <span id="year"></span>'
      },
      copy: {
        copy: 'Copiar',
        done: 'Copiado ✓',
        error: 'Error'
      }
    }
  };

  /* ---------- Utilidades ---------- */

  function get(obj, path) {
    return path.split('.').reduce(function (o, k) {
      return o ? o[k] : undefined;
    }, obj);
  }

  function setMeta(attr, content) {
    var el = document.querySelector('meta[name="' + attr + '"]') ||
             document.querySelector('meta[property="' + attr + '"]');
    if (el) el.setAttribute('content', content);
  }

  function detectLang() {
    var stored = null;
    try { stored = localStorage.getItem(STORAGE_KEY); } catch (e) { /* ignore */ }
    if (stored && LANGS.indexOf(stored) !== -1) return stored;

    var nav = (navigator.language || navigator.userLanguage || '').toLowerCase();
    var code = nav.split('-')[0];
    if (LANGS.indexOf(code) !== -1) return code;
    return DEFAULT_LANG;
  }

  function applyLang(lang) {
    if (LANGS.indexOf(lang) === -1) lang = DEFAULT_LANG;
    var t = TRANSLATIONS[lang];

    // <html lang> + título + meta
    document.documentElement.lang = lang === 'pt' ? 'pt-BR' : lang;
    document.title = t.meta.title;
    setMeta('description', t.meta.description);
    setMeta('og:title', t.meta.title);
    setMeta('og:description', t.meta.description);

    // Texto simples
    document.querySelectorAll('[data-i18n]').forEach(function (el) {
      var val = get(t, el.getAttribute('data-i18n'));
      if (val !== undefined) el.textContent = val;
    });

    // Texto com HTML
    document.querySelectorAll('[data-i18n-html]').forEach(function (el) {
      var val = get(t, el.getAttribute('data-i18n-html'));
      if (val !== undefined) el.innerHTML = val;
    });

    // aria-label
    document.querySelectorAll('[data-i18n-aria]').forEach(function (el) {
      var val = get(t, el.getAttribute('data-i18n-aria'));
      if (val !== undefined) el.setAttribute('aria-label', val);
    });

    // Botões de copiar: rótulos dinâmicos
    document.querySelectorAll('.copy-btn').forEach(function (btn) {
      btn.setAttribute('data-copy-label', t.copy.copy);
      btn.setAttribute('data-copy-done', t.copy.done);
      btn.setAttribute('data-copy-error', t.copy.error);
      if (!btn.classList.contains('copied')) btn.textContent = t.copy.copy;
    });

    // Seletor de idioma: estado ativo
    document.querySelectorAll('.lang-btn').forEach(function (btn) {
      btn.classList.toggle('active', btn.getAttribute('data-lang') === lang);
    });

    try { localStorage.setItem(STORAGE_KEY, lang); } catch (e) { /* ignore */ }
    window.__raiwLang = lang;
  }

  window.RAIW_I18N = {
    LANGS: LANGS,
    detectLang: detectLang,
    applyLang: applyLang
  };
})();
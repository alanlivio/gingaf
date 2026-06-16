import * as monaco from 'monaco-editor';
import EditorWorker from 'monaco-editor/esm/vs/editor/editor.worker?worker';

// @ts-ignore
import videoNcl from '../../examples/video.ncl?raw';
// @ts-ignore
import luaCanvasNcl from '../../examples/lua_canvas.ncl?raw';
// @ts-ignore
import luaCanvasLua from '../../examples/lua_canvas.lua?raw';
// @ts-ignore
import imageNcl from '../../examples/image.ncl?raw';

self.MonacoEnvironment = {
  getWorker(_workerId: string, _label: string) {
    return new EditorWorker();
  }
};

interface Example {
  mainFile: string;
  files: Record<string, string>;
}

const examples: Record<string, Example> = {
  video: { mainFile: 'video.ncl', files: { 'video.ncl': videoNcl } },
  lua_canvas: { mainFile: 'lua_canvas.ncl', files: { 'lua_canvas.ncl': luaCanvasNcl, 'lua_canvas.lua': luaCanvasLua } },
  image: { mainFile: 'image.ncl', files: { 'image.ncl': imageNcl } },
};

const editorContainer = document.getElementById('editor-container');
const editorTabs = document.getElementById('editor-tabs');
const runBtn = document.getElementById('run-btn');
const selectEl = document.getElementById('example-select') as HTMLSelectElement;
const iframe = document.getElementById('preview-frame') as HTMLIFrameElement;

if (editorContainer && editorTabs && runBtn && selectEl && iframe) {
  let currentExample = examples['video'];
  let currentFileName = currentExample.mainFile;
  let isRunning = false;

  const editor = monaco.editor.create(editorContainer, {
    value: currentExample.files[currentFileName],
    language: 'xml',
    theme: 'vs-dark',
    minimap: { enabled: false },
    automaticLayout: true,
  });

  const renderTabs = () => {
    editorTabs.innerHTML = '';
    for (const fileName of Object.keys(currentExample.files)) {
      const tab = document.createElement('div');
      tab.className = 'tab' + (fileName === currentFileName ? ' active' : '');
      tab.textContent = fileName;
      tab.addEventListener('click', () => {
        if (!isRunning) {
          currentExample.files[currentFileName] = editor.getValue();
          currentFileName = fileName;
          editor.setValue(currentExample.files[currentFileName]);
          monaco.editor.setModelLanguage(editor.getModel()!, fileName.endsWith('.lua') ? 'lua' : 'xml');
          renderTabs();
        }
      });
      editorTabs.appendChild(tab);
    }
  };

  renderTabs();

  selectEl.addEventListener('change', () => {
    const selected = selectEl.value;
    if (examples[selected]) {
      if (isRunning) {
        runBtn.click();
      }
      currentExample = examples[selected];
      currentFileName = currentExample.mainFile;
      editor.setValue(currentExample.files[currentFileName]);
      monaco.editor.setModelLanguage(editor.getModel()!, currentFileName.endsWith('.lua') ? 'lua' : 'xml');
      renderTabs();
    }
  });

  iframe.src = 'about:blank';

  runBtn.addEventListener('click', async () => {
    if (isRunning) {
      editor.updateOptions({ readOnly: false });
      document.getElementById('editor-overlay')?.classList.add('hidden');
      runBtn.textContent = 'Run';
      iframe.src = 'about:blank';
      isRunning = false;
    } else {
      currentExample.files[currentFileName] = editor.getValue();
      
      sessionStorage.setItem('GINGA_PLAYGROUND_FILES', JSON.stringify(currentExample.files));
      sessionStorage.setItem('GINGA_PLAYGROUND_MAIN', currentExample.mainFile);
      
      editor.updateOptions({ readOnly: true });
      document.getElementById('editor-overlay')?.classList.remove('hidden');
      runBtn.textContent = 'Stop';
      iframe.src = 'player/index.html';
      isRunning = true;
    }
  });
}

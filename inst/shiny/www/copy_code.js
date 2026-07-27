function copyCodeToClipboard(elementId) {
  var el = document.getElementById(elementId);
  if (!el) {
    console.error("Elemento no encontrado: " + elementId);
    return;
  }
  var text = el.innerText || el.textContent;
  if (navigator.clipboard && window.isSecureContext) {
    navigator.clipboard.writeText(text).then(function() {
      showCopyToast();
    }).catch(function(err) {
      fallbackCopyText(text);
    });
  } else {
    fallbackCopyText(text);
  }
}

function fallbackCopyText(text) {
  var textArea = document.createElement("textarea");
  textArea.value = text;
  textArea.style.position = "fixed";
  textArea.style.left = "-999999px";
  document.body.appendChild(textArea);
  textArea.focus();
  textArea.select();
  try {
    document.execCommand('copy');
    showCopyToast();
  } catch (err) {
    alert('No se pudo copiar el código: ' + err);
  }
  document.body.removeChild(textArea);
}

function showCopyToast() {
  var toast = document.createElement("div");
  toast.innerText = "¡Código R copiado al portapapeles!";
  toast.style.position = "fixed";
  toast.style.bottom = "20px";
  toast.style.right = "20px";
  toast.style.backgroundColor = "#1b4d3e";
  toast.style.color = "#ffffff";
  toast.style.padding = "12px 24px";
  toast.style.borderRadius = "8px";
  toast.style.boxShadow = "0 4px 12px rgba(0,0,0,0.2)";
  toast.style.zIndex = "999999";
  toast.style.fontWeight = "600";
  document.body.appendChild(toast);
  setTimeout(function() {
    document.body.removeChild(toast);
  }, 2500);
}


var currentTheme = -1;
let themes = [
  { main: '#50586c', sub: '#dce2f0' },
  { main: '#343148', sub: '#D7C49E' },
  { main: '#2BAE66', sub: '#FCF6F5' },
  { main: '#603F83', sub: '#C7D3D4' },
  { main: '#755139', sub: '#F2EDD7' },
  { main: '#262223', sub: '#DDC6B6' },
  { main: '#F4EFEA', sub: '#9A161F', warning: '#2BAE66' }
];

function cycleTheme() {
  var newTheme = (currentTheme + 1) % themes.length;
  setTheme(newTheme);
}

function setTheme(index) {
  const theme = themes[index];
  const root = document.querySelector(':root');
  root.style.setProperty('--scheme-color-1', theme['main']);
  root.style.setProperty('--scheme-color-2', theme['sub']);
  root.style.setProperty('--scheme-warning-color', theme['warning'] ?? '#990000');

  currentTheme = index;
  localStorage.setItem("mv-theme", currentTheme);
}

function isValidHttpUrl(string) {
  let url;
  try {
    url = new URL(string);
  } catch (_) {
    return false;
  }
  let isValidProtocol = url.protocol === "http:" || url.protocol === "https:";
  return isValidProtocol;
}

function handleInput() {
  let sourceInput = document.getElementById("userInput").value;
  let iosSourceInput = document.getElementById("userInput2").value;

  if (
    !isValidHttpUrl(sourceInput) ||
    (iosSourceInput != "" && !isValidHttpUrl(iosSourceInput))
  ) {
    console.log(`Invalid URL input '${sourceInput}' / '${iosSourceInput}'`);
    showWarning(
      "Enter a valid URL" +
        (iosSourceInput != "" ? " or clear the optional field." : "")
    );
  } else {
    console.log(`New source ${sourceInput}`);
    const modelViewer = document.getElementById("model-viewer");
    modelViewer["src"] = sourceInput;
    modelViewer[`ios-src`] = "";
    modelViewer[`poster`] = "assets/loading.webp";

    if (iosSourceInput != "") {
      console.log(`New iOS Source ${iosSourceInput}`);
      modelViewer["ios-src"] = iosSourceInput;
    }

    const customSliderElement = document.getElementById("custom-slider-el");
    selectSliderElement(customSliderElement);
  }
}

let warningTimeoutID;

function showWarning(message) {
  const warningLabel = document.getElementById("warning-label");
  warningLabel.innerHTML = `<span class='pill-label warning'>Error: ${message}</span>`;
  warningLabel.style.display = '';
  
  /* clear warning after 3 seconds */ 
  warningTimeoutID = setTimeout(hideWarning, 3 * 1000);
}

function hideWarning() {
  const warningLabel = document.getElementById("warning-label");
  warningLabel.style.display = "none";
  clearTimeout(warningTimeoutID);
}

let sliderDataDictionary = {
  shishkebab: {
    Poster: "https://modelviewer.dev/assets/poster-shishkebab.webp",
    Model: "https://modelviewer.dev/shared-assets/models/shishkebab.glb",
  },
  chair: {
    Poster: "https://modelviewer.dev/assets/ShopifyModels/Chair.webp",
    Model: "https://modelviewer.dev/assets/ShopifyModels/Chair.glb",
  },
  mixer: {
    Poster: "https://modelviewer.dev/assets/ShopifyModels/Mixer.webp",
    Model: "https://modelviewer.dev/assets/ShopifyModels/Mixer.glb",
  },
  planter: {
    Poster: "https://modelviewer.dev/assets/ShopifyModels/GeoPlanter.webp",
    Model: "https://modelviewer.dev/assets/ShopifyModels/GeoPlanter.glb",
  },
  train: {
    Poster: "https://modelviewer.dev/assets/ShopifyModels/ToyTrain.webp",
    Model: "https://modelviewer.dev/assets/ShopifyModels/ToyTrain.glb",
  },
  canoe: {
    Poster: "https://modelviewer.dev/assets/ShopifyModels/Canoe.webp",
    Model: "https://modelviewer.dev/assets/ShopifyModels/Canoe.glb",
  },
};

function handleSliderElement(element, name) {
  const modelViewer = document.getElementById("model-viewer");
  modelViewer["src"] = sliderDataDictionary[name]["Model"];
  modelViewer["ios-src"] = "";
  modelViewer["poster"] = sliderDataDictionary[name]["Poster"];
  selectSliderElement(element);
}

function selectSliderElement(element) {
  const slides = document.querySelectorAll(".slide");
  slides.forEach((element) => {
    element.classList.remove("selected");
  });
  element.classList.add("selected");
  
  hideWarning();
}

function createSliderElements() {
  /* create elements from data source */ 
  const sliderParent = document.getElementById("slider-parent");
  for (let [key, value] of Object.entries(sliderDataDictionary)) {
    var newChild = createSliderElement(key, value["Poster"]);
    sliderParent.appendChild(newChild);
  }
  
  /* fix iOS Safari cut off right edge.. */
  const spacer = document.createElement("div");
  spacer.className = "spacer slide";
  sliderParent.appendChild(spacer);
  
  /* select first item (skip custom) */
  sliderParent.children[1].click();
}

function createSliderElement(name, poster) {
  var sliderButton = document.createElement("button");
  sliderButton.className = "slide";
  sliderButton.style = `background-image: url('${poster}');`;
  sliderButton.addEventListener("click", function (e) {
    handleSliderElement(e.target, name);
  });
  return sliderButton;
}

function bodyLoaded() {
  // setup buttons
  document.getElementById("loadButton").addEventListener("click", handleInput, false);
  document.getElementById("themeButton").addEventListener("click", cycleTheme, false);

  // setup slider
  const customSliderEl = document.getElementById("custom-slider-el");
  customSliderEl.addEventListener("click", handleInput, false);
  createSliderElements();
}

setTheme(Number(localStorage.getItem("mv-theme") ?? "0"));
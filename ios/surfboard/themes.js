
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
  index = Number(index);
  const theme = themes[index];
  const root = document.querySelector(':root');
  root.style.setProperty('--scheme-color-1', theme['main']);
  root.style.setProperty('--scheme-color-2', theme['sub']);
  root.style.setProperty('--scheme-warning-color', theme['warning'] ?? '#990000');
  document.querySelector('meta[name="theme-color"]').setAttribute('content', theme['main']);

  currentTheme = index;
  localStorage.setItem("mv-theme", currentTheme);
}

function bodyLoaded() {
  // setup buttons
  document.getElementById("themeButton").addEventListener("click", cycleTheme, false);
}

setTheme(Number(localStorage.getItem("mv-theme") ?? "0"));
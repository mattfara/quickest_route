import "../css/app.css"

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

window.onload = () => {
  eachSelected(".remove-array-item", (el) => el.onclick = removeItem)
  eachSelected(".add-array-item", (el) => el.onclick = addItem)
}

const eachSelected = (selector, fn) => {
    Array.prototype.forEach.call(document.querySelectorAll(selector), fn);
}
// 28:29 in https://alchemist.camp/episodes/ecto-array-phoenix-form
const removeItem = (event) => {
    let index = event.target.dataset.index;
    let li = event.target.parentNode;
    let ol = li.parentNode;
    ol.removeChild(li);
    Array.prototype.forEach.call(ol.children, (x,i) => 
      x.firstChild.dataset.index = i  
    );
    ol.dataset.index -= 1;
}

const addItem = ({target: {dataset}}) => {
    let container = document.getElementById(dataset.container);
    let count = container.children.length;

    container.insertAdjacentHTML("beforeend", dataset.blueprint);

    let newItem = container.lastChild;

    newItem.lastChild.onclick = removeItem;

    newItem.firstChild.dataset.index = count;

    newItem.firstChild.id += `_${count}`;
    newItem.firstChild.focus()
}
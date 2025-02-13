'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"main.dart.js": "17af65a16c621b600119636315946939",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/assets/misc/io.github.jochumdev.letscheck.metainfo.xml": "a6eb6e44b339794267e74bfeae8b371a",
"assets/assets/misc/io.github.jochumdev.letscheck.desktop": "36313c44d7fa911160f1ba70afefa0eb",
"assets/assets/js/luxon.min.js": "855ccafbd68ffbe91b78b281fa53178e",
"assets/assets/icons/LetsCheck.svg": "07d8a7f2f10e04ffce76f2e6883fef61",
"assets/assets/icons/letscheck.ico": "29fa499e18e4a3470a253111d8fa260c",
"assets/assets/icons/letscheck.png": "ece77e9b397fe276d432b22f12fca8b8",
"assets/assets/sound/slow_spring_board.mp3": "9cc67f8ca682c600b0e7568c465c0b14",
"assets/assets/fonts/OpenSans_Condensed-Light.ttf": "73e3f737e5e416273389662092a666b1",
"assets/assets/fonts/OpenSans-LightItalic.ttf": "07f95dc31e4f5c166051e95f554a8dff",
"assets/assets/fonts/OpenSans_Condensed-MediumItalic.ttf": "a684f4bc4e3d33d11a40b2f101399da6",
"assets/assets/fonts/OpenSans_SemiCondensed-ExtraBold.ttf": "58788af3238842a6438278ff581124ca",
"assets/assets/fonts/OpenSans-Regular.ttf": "931aebd37b54b3e5df2fedfce1432d52",
"assets/assets/fonts/OpenSans_Condensed-SemiBold.ttf": "2d70d77113ff88765d4a2e3e9ad8a9d9",
"assets/assets/fonts/OpenSans_SemiCondensed-MediumItalic.ttf": "c24586aed8015d848dbf63cf0d412208",
"assets/assets/fonts/OpenSans_Condensed-ExtraBold.ttf": "10af970680f2d4b8a8414e8eedcf3605",
"assets/assets/fonts/OpenSans-Light.ttf": "c87e3b21e46c872774d041a71e181e61",
"assets/assets/fonts/OpenSans_Condensed-SemiBoldItalic.ttf": "ad76c64801d7b1b8375adf4b535c9f06",
"assets/assets/fonts/OpenSans_SemiCondensed-Medium.ttf": "7c51e9756da66db9f515c8bb5ea9920f",
"assets/assets/fonts/OpenSans-ExtraBold.ttf": "f0af8434e183f500acf62135a577c739",
"assets/assets/fonts/OpenSans_Condensed-BoldItalic.ttf": "9fa8f9e4df5aca8b0e10f589a91793a2",
"assets/assets/fonts/OpenSans_Condensed-Bold.ttf": "5df2bb0a5dc244b8fe88ba3eb3ff3eda",
"assets/assets/fonts/OpenSans-SemiBoldItalic.ttf": "223ce0be939cafef0fb807eb0ea8d7de",
"assets/assets/fonts/OpenSans-Italic.ttf": "60fdf6ed7b4901c1ff534577a68d9c0c",
"assets/assets/fonts/OpenSans_Condensed-LightItalic.ttf": "cd015954b9609b30486bf93dcf0ff213",
"assets/assets/fonts/OpenSans_Condensed-Italic.ttf": "1bdd899fc93c5247e68103da20b7b26c",
"assets/assets/fonts/OpenSans_Condensed-Medium.ttf": "70e41d5efaae749f6aaa68561da7f1b1",
"assets/assets/fonts/OpenSans-ExtraBoldItalic.ttf": "ae6ca7d3e0ab887a9d9731508592303a",
"assets/assets/fonts/OpenSans-RegularItalic.ttf": "f6238deb7f40a7a03134c11fb63ad387",
"assets/assets/fonts/OpenSans_Condensed-ExtraBoldItalic.ttf": "b4b3789f2bc95af95536cb7f7f3ec1ed",
"assets/assets/fonts/OpenSans_SemiCondensed-ExtraBoldItalic.ttf": "8b3d3e856f6be6295e17e8539182084c",
"assets/assets/fonts/OpenSans_SemiCondensed-Regular.ttf": "a4524de69e40328e8bbaae81c74cf87e",
"assets/assets/fonts/OpenSans-MediumItalic.ttf": "349744a1905053fad6b9ef13c74657db",
"assets/assets/fonts/OpenSans-Bold.ttf": "0a191f83602623628320f3d3c667a276",
"assets/assets/fonts/OpenSans-BoldItalic.ttf": "3dc8fca5496b8d2ad16a9800cc8c2883",
"assets/assets/fonts/OFL.txt": "9b454a0b0f85039ba22e6baa10ce31e9",
"assets/assets/fonts/OpenSans-SemiBold.ttf": "e2ca235bf1ddc5b7a350199cf818c9c8",
"assets/assets/fonts/OpenSans_SemiCondensed-SemiBoldItalic.ttf": "92ba379a002c359ddd247eb1c32cce00",
"assets/assets/fonts/OpenSans-Medium.ttf": "dac0e601db6e3601159b4aae5c1fda39",
"assets/assets/fonts/OpenSans_Condensed-Regular.ttf": "78b69821a6c0cc6fdcd1f4c3bb768fb7",
"assets/assets/fonts/OpenSans_SemiCondensed-SemiBold.ttf": "4e5cd43941bf45121d159dc4493a9c4a",
"assets/assets/fonts/OpenSans_SemiCondensed-Light.ttf": "158d178df4e3f63ac7cf7a151a855e1e",
"assets/assets/fonts/OpenSans_SemiCondensed-LightItalic.ttf": "c2b7941c139fe149a4766fbf3d42d997",
"assets/assets/fonts/OpenSans_SemiCondensed-Bold.ttf": "f2a40b2ae2605e847aa935b7567688cd",
"assets/assets/fonts/OpenSans_SemiCondensed-BoldItalic.ttf": "e6db506e680bd887710b918b762f64f9",
"assets/assets/fonts/OpenSans_SemiCondensed-Italic.ttf": "4f1cb41e14ba244ac1ddd0208e3bd4a6",
"assets/CHANGELOG.md": "feb192ddaadc9a5e6643eb51cab85657",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "6a48250929c96ff7c3105fd47d66f22b",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "5c81144f2ca86ae798f4d9120c60049d",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "4769f3245a24c1fa9965f113ea85ec2a",
"assets/packages/flutter_js/assets/js/fetch.js": "277e0c5ec36810cbe57371a4b7e26be0",
"assets/AssetManifest.bin": "f73c9712213c5b0e3ae14a3c7617b977",
"assets/NOTICES": "fabdce68e35fb88c5cfaf687c7247831",
"assets/AssetManifest.json": "19c10f6b55c6cad29b7f20a297034099",
"assets/AssetManifest.bin.json": "4d27a63ae20064787c6e49e37df2e92a",
"assets/FontManifest.json": "3ddd9b2ab1c2ae162d46e3cc7b78ba88",
"assets/fonts/MaterialIcons-Regular.otf": "8c1647b2387c1e94e05c9cec190393c4",
"manifest.json": "6574ad0bb04d925eddacf3ce0c299a7d",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"icons/icon-512-maskable.png": "ad419bb3271cd381d28aa5757d802bbd",
"icons/icon-192-maskable.png": "32b3c16312e5717e307c1bca8abba953",
"icons/icon-192.png": "88844ec95be18c46067e2dbd485e00d0",
"icons/icon-512.png": "0cf245237611242aeaa551e8c6b3ebed",
"flutter_bootstrap.js": "a18024cf2df95cb7e04d0f362ac24a9a",
"favicon.png": "88844ec95be18c46067e2dbd485e00d0",
"version.json": "963cdcdea8305309dcba639e0d8c4fcd",
"index.html": "d975b0575fa58484e799bcf30cf000f4",
"/": "d975b0575fa58484e799bcf30cf000f4"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}

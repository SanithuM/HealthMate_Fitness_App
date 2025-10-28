// sqflite web service worker.
//
// Do not edit, this file is generated.

// Handle fetch event
self.addEventListener('fetch', (event) => {
  // console.log('sqflite_sw fetch', event);
});

// Handle activate event
self.addEventListener('activate', (event) => {
  // console.log('sqflite_sw activate', event);
  event.waitUntil(self.clients.claim());
});

// Handle install event
self.addEventListener('install', (event) => {
  // console.log('sqflite_sw install', event);
  event.waitUntil(self.skipWaiting());
});
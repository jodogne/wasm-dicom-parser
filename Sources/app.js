/**
 * Parsing DICOM using WebAssembly
 * Copyright (C) 2017 Sebastien Jodogne <s.jodogne@gmail.com>, Osimis,
 * Belgium
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Affero General Public License
 * as published by the Free Software Foundation, either version 3 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 **/


var ENTITY_MAP = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#39;',
  '/': '&#x2F;',
  '`': '&#x60;',
  '=': '&#x3D;'
};

function EscapeHtml (string) {
  // http://stackoverflow.com/a/12034334/881731
  return String(string).replace(/[&<>"'`=\/]/g, function(s) {
    return ENTITY_MAP[s];
  });
}


// This event is triggered when the user uploads a DICOM file
document.getElementById('upload').addEventListener('submit', function(e) {

  // Check whether a file has actually been selected
  var fileInput = document.getElementById('dicom');

  if ('files' in fileInput &&
      fileInput.files.length == 1) {

    // Create a reader to receive the file selected by the HTML form
    // https://developer.mozilla.org/fr/docs/Web/API/FileReader/onload
    var reader = new FileReader();
    
    reader.onload = function(event) {
      // Clear the result fields
      document.getElementById('headers').innerHTML = '';
      document.getElementById('tags').innerHTML = '';
      
      var dicom = this.result;
      var showPrivateTags = document.getElementById('private').checked;
      var showNonStringTags = document.getElementById('non-strings').checked;

      // Call the C++ function "ParseDicom()"
      if (!Module.ccall('ParseDicom', // Name of the C++ function
                        'number',     // Return value (a Boolean indicating success)
                        [             // The list of arguments
                          'array',    
                          'number',
                          'number',
                          'number'
                        ],
                        [            // The value of the arguments
                          new Uint8Array(dicom),
                          dicom.byteLength,
                          showPrivateTags,
                          showNonStringTags
                        ])) {
        // The C++ function has failed (it has returned "false")
        alert('Sorry, unable to parse to DICOM file');
      }
    };

    // Instruct JavaScript to load the file as an ArrayBuffer
    reader.readAsArrayBuffer(fileInput.files[0]);

  } else {
    alert('Please select one DICOM file');
  }

  // Prevent the actual uploading of the form
  e.preventDefault();
});



// Load the WebAssembly module and map the "stdout" and "stderr"
// streams to the JavaScript console
var Module = {
  preRun: [],
  postRun: [],
  print: function(text) {
    console.log(text);
  },
  printErr: function(text) {
    if (arguments.length > 1) {
      text = Array.prototype.slice.call(arguments).join(' ');
    }
    
    console.error(text);
  },
  totalDependencies: 0
};


if (!('WebAssembly' in window)) {
  alert('Sorry, your browser does not support WebAssembly :(');
}

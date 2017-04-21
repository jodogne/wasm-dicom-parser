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



// This is the library of the "extern" JavaScript functions that can
// be called from the C++ code

mergeInto(LibraryManager.library, {

  // The "AddTag()" function append one line to the "Headers" or
  // "Tags" section of the HTML page
  AddTag: function(isHeader, s) {
    
    // Convert the C string "const char*" to a JavaScript string, and
    // escape it to avoid HTML entities
    var content = EscapeHtml(UTF8ToString(s));

    // Select the target HTML element
    var target = isHeader ? 'headers' : 'tags';

    document.getElementById(target).innerHTML += content + '<br/>';
  }
  
});

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


#include <emscripten/emscripten.h>
#include <stdio.h>

// Include DCMTK
#include <dcmtk/dcmdata/dcfilefo.h>
#include <dcmtk/dcmdata/dcistrmb.h>
#include <dcmtk/dcmdata/dcmetinf.h>

#ifdef __cplusplus
extern "C" {
#endif

  // External function defined in "library.js" to append one tag to
  // the HTML page.
  extern void AddTag(bool isHeader,
                     const char* tag);
  
#ifdef __cplusplus
}
#endif


// Use DCMTK to parse a memory buffer containing a DICOM file. This
// code comes from Orthanc.
static DcmFileFormat* LoadFromMemoryBuffer(const void* buffer,
                                           size_t size)
{
  DcmInputBufferStream is;
  if (size > 0)
  {
    is.setBuffer(buffer, size);
  }
  is.setEos();

  std::auto_ptr<DcmFileFormat> result(new DcmFileFormat);

  result->transferInit();
  if (!result->read(is).good())
  {
    return NULL;
  }
  else
  {
    result->loadAllDataIntoMemory();
    result->transferEnd();
    return result.release();
  }
}


// Loop over the tags contained in a DICOM dataset, convert them as
// strings, and fill the HTML page with these strings.
static void SendTagsToJavascript(DcmItem* item,
                                 bool isHeader,
                                 bool showPrivateTags,
                                 bool showNonStringTags)
{
  if (item != NULL)
  {
    for (unsigned long i = 0; i < item->card(); i++)
    {
      DcmElement* element = item->getElement(i);
      if (element != NULL)
      {
        char buf[64];
        sprintf(buf, "(%04x,%04x) ", element->getGTag(), element->getETag());

        // Copy the tag to ensure const-correctness
        DcmTag tag(element->getTag());  
        std::string name = std::string(buf) + std::string(tag.getTagName()) + ": ";
      
        char* value = NULL;
        if (element != NULL &&
            (showPrivateTags || !element->getTag().isPrivate()))
        {
          if (element->isaString() &&
              element->getString(value).good() &&
              value != NULL)
          {
            std::string tag = name + std::string(value);
            AddTag(isHeader, tag.c_str());
          }
          else if (showNonStringTags)
          {
            std::string tag = name + "Not a string";
            AddTag(isHeader, tag.c_str());
          }
        }
      }
    }
  }
}


#ifdef __cplusplus
extern "C" {
#endif

  // Main function called from the JavaScript code
  bool EMSCRIPTEN_KEEPALIVE ParseDicom(const void* body,
                                       size_t length,
                                       bool showPrivateTags,
                                       bool showNonStringTags)
  {
    printf("Received DICOM file of length %d\n", length);

    std::auto_ptr<DcmFileFormat> dicom(LoadFromMemoryBuffer(body, length));
    if (dicom.get() == NULL)
    {
      return false;
    }
    else
    {
      SendTagsToJavascript(dicom->getMetaInfo(), true, showPrivateTags, showNonStringTags);
      SendTagsToJavascript(dicom->getDataset(), false, showPrivateTags, showNonStringTags);
      return true;
    }
  }
  

#ifdef __cplusplus
}
#endif

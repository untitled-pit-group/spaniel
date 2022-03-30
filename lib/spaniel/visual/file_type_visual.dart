import "package:flutter/material.dart";
import "package:spaniel/pifs/data/file.dart";

/// Defines various data for the display of a specific file type
/// (side note: I really struggled to name this)
class SPFileTypeVisual {
  final String name;
  final IconData icon;

  const SPFileTypeVisual(this.name, this.icon);
}

/// A map for all known file types and their matching visual data
const Map<PifsFileType, SPFileTypeVisual> fileTypeVisuals = {
  PifsFileType.plain: SPFileTypeVisual("filetype.plain", Icons.subject),
  PifsFileType.document: SPFileTypeVisual("filetype.document", Icons.description),
  PifsFileType.media: SPFileTypeVisual("filetype.media", Icons.perm_media),
};

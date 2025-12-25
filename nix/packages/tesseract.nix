{ pkgs }:

[
  (pkgs.tesseract.override {
    enableLatin = true;
    enableJpan = true;
    enableHans = true;
    enableHant = true;
    enableKore = true;

    enableEnglish = true;
    enableSpanish = true;
  })
]
